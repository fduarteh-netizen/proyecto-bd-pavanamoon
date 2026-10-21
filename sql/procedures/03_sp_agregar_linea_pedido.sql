-- =============================================================================
-- Archivo:      03_sp_agregar_linea_pedido.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Procedimiento sp_agregar_linea_pedido(pedido, variante,
--               presentacion, cantidad)
-- Regla de negocio (RF11, RF12, RF13):
--   Agrega una línea al pedido con el precio calculado por
--   fn_calcular_precio_linea (el usuario nunca digita el precio, se aplica
--   el descuento del tipo de cliente). Los triggers de detalle_pedido
--   validan stock, descuentan inventario, registran el kardex y recalculan
--   el total. Una variante solo puede aparecer una vez por pedido (PK).
-- Cambio E4:   bloquea la variante al inicio (FOR UPDATE) para que pedidos
--               simultáneos se serialicen sin deadlock (ver cuerpo).
-- Dependencias: fn_calcular_precio_linea, detalle_pedido, pedido,
--               trg_detalle_pedido_bi, trg_detalle_pedido_ai
-- Estándar:     S2, S3, S6, S7
-- =============================================================================

USE pavanamoon;
SET NAMES utf8mb4;  -- mensajes de negocio con acentos correctos sin importar el cliente

DROP PROCEDURE IF EXISTS sp_agregar_linea_pedido;

DELIMITER $$

CREATE PROCEDURE sp_agregar_linea_pedido(
    IN p_pedido_id       INT,
    IN p_variante_id     INT,
    IN p_presentacion_id INT,
    IN p_cantidad        INT
)
BEGIN
    DECLARE v_cliente_id INT;
    DECLARE v_variante_bloqueada INT;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a cero.';
    END IF;

    -- Concurrencia (Entrega 4): bloquear la variante ANTES de leer
    -- detalle_pedido. La verificación de "variante repetida" de abajo toma un
    -- bloqueo sobre detalle_pedido; si dos pedidos simultáneos lo tomaban
    -- primero y luego pedían la variante, se esperaban mutuamente (deadlock
    -- 1213, confirmado con SHOW ENGINE INNODB STATUS). Tomando siempre la
    -- variante primero, el segundo pedido espera al primero sin sostener
    -- nada, y luego trg_detalle_pedido_bi lee el stock ya actualizado.
    SELECT variante_id INTO v_variante_bloqueada
      FROM variante_producto WHERE variante_id = p_variante_id
       FOR UPDATE;
    IF v_variante_bloqueada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La variante indicada no existe.';
    END IF;

    SELECT cliente_id INTO v_cliente_id FROM pedido WHERE pedido_id = p_pedido_id;
    IF v_cliente_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido indicado no existe.';
    END IF;

    IF EXISTS (SELECT 1 FROM detalle_pedido
                WHERE pedido_id = p_pedido_id AND variante_id = p_variante_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esa variante ya está en el pedido.';
    END IF;

    INSERT INTO detalle_pedido (pedido_id, variante_id, presentacion_id, cantidad, precio_unitario)
    VALUES (p_pedido_id, p_variante_id, p_presentacion_id, p_cantidad,
            fn_calcular_precio_linea(p_variante_id, p_presentacion_id, v_cliente_id));
END$$

DELIMITER ;

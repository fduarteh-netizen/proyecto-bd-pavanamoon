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
-- Dependencias: fn_calcular_precio_linea, detalle_pedido, pedido,
--               trg_detalle_pedido_bi, trg_detalle_pedido_ai
-- Estándar:     S2, S3, S6, S7
-- =============================================================================

USE pavanamoon;

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

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a cero.';
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

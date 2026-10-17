-- =============================================================================
-- Archivo:      05_sp_cancelar_pedido.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Procedimiento sp_cancelar_pedido(pedido, empleado)
-- Regla de negocio (RF11, RF15, RF16):
--   Un pedido PENDIENTE puede cancelarse (el cliente desiste antes de la
--   entrega). Al cancelarlo:
--     1) cada línea regresa sus pares al stock de la variante;
--     2) cada reintegro queda en el kardex como 'cancelacion', con el
--        empleado que canceló y la referencia al pedido;
--     3) el pedido pasa a estado 'cancelado'.
--   El detalle del pedido NO se borra: se conserva como evidencia de lo
--   que se había solicitado (auditoría). Un pedido COMPLETADO no se cancela;
--   para él existe sp_registrar_devolucion. Un pedido ya cancelado no puede
--   cancelarse otra vez (evita reintegrar el stock dos veces).
--   Todo es atómico: si cualquier paso falla, ROLLBACK y no cambia nada.
-- Dependencias: pedido, detalle_pedido, presentacion_venta, variante_producto,
--               movimiento_stock (con pedido_id, ver ddl/07_ajustes_entrega4.sql)
-- Estándar:     S2, S3, S6
-- =============================================================================

USE pavanamoon;
SET NAMES utf8mb4;  -- mensajes de negocio con acentos correctos sin importar el cliente

DROP PROCEDURE IF EXISTS sp_cancelar_pedido;

DELIMITER $$

CREATE PROCEDURE sp_cancelar_pedido(
    IN p_pedido_id   INT,
    IN p_empleado_id INT
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Bloquea el pedido: dos cancelaciones simultáneas no pueden reintegrar dos veces.
    SELECT estado INTO v_estado FROM pedido WHERE pedido_id = p_pedido_id FOR UPDATE;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no existe.';
    END IF;

    IF v_estado <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo se pueden cancelar pedidos pendientes (para completados use devolución).';
    END IF;

    -- 1) Reintegrar al stock los pares de cada línea.
    UPDATE variante_producto vp
      JOIN detalle_pedido     dp ON dp.variante_id     = vp.variante_id
      JOIN presentacion_venta pv ON pv.presentacion_id = dp.presentacion_id
       SET vp.stock_actual = vp.stock_actual + dp.cantidad * pv.cantidad_pares
     WHERE dp.pedido_id = p_pedido_id;

    -- 2) Dejar cada reintegro en el kardex.
    INSERT INTO movimiento_stock (variante_id, empleado_id, tipo_movimiento, cantidad, pedido_id)
    SELECT dp.variante_id, p_empleado_id, 'cancelacion', dp.cantidad * pv.cantidad_pares, p_pedido_id
      FROM detalle_pedido dp
      JOIN presentacion_venta pv ON pv.presentacion_id = dp.presentacion_id
     WHERE dp.pedido_id = p_pedido_id;

    -- 3) Cambiar el estado.
    UPDATE pedido SET estado = 'cancelado' WHERE pedido_id = p_pedido_id;

    COMMIT;
END$$

DELIMITER ;

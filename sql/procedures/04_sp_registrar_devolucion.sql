-- =============================================================================
-- Archivo:      04_sp_registrar_devolucion.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Procedimiento sp_registrar_devolucion(pedido, variante, pares,
--               empleado)
-- Regla de negocio (RF17, RF15):
--   Un cliente solo puede devolver pares de una variante que efectivamente
--   compró en un pedido COMPLETADO, y nunca más pares de los vendidos en esa
--   línea. La devolución regresa los pares al stock y queda en el kardex
--   como 'devolucion_cliente'. Es transaccional: si algo falla, no se toca
--   ni el stock ni el kardex (ROLLBACK + RESIGNAL del error original).
-- Dependencias: pedido, detalle_pedido, presentacion_venta, variante_producto,
--               movimiento_stock
-- Estándar:     S2, S3, S6
-- =============================================================================

USE pavanamoon;

DROP PROCEDURE IF EXISTS sp_registrar_devolucion;

DELIMITER $$

CREATE PROCEDURE sp_registrar_devolucion(
    IN p_pedido_id   INT,
    IN p_variante_id INT,
    IN p_pares       INT,
    IN p_empleado_id INT
)
BEGIN
    DECLARE v_estado        VARCHAR(20);
    DECLARE v_pares_vendidos INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM pedido WHERE pedido_id = p_pedido_id;
    IF v_estado IS NULL OR v_estado <> 'completado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo se aceptan devoluciones de pedidos completados.';
    END IF;

    SELECT dp.cantidad * pv.cantidad_pares INTO v_pares_vendidos
      FROM detalle_pedido dp
      JOIN presentacion_venta pv ON pv.presentacion_id = dp.presentacion_id
     WHERE dp.pedido_id = p_pedido_id AND dp.variante_id = p_variante_id;

    IF v_pares_vendidos IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La variante no pertenece a ese pedido.';
    END IF;

    IF p_pares IS NULL OR p_pares <= 0 OR p_pares > v_pares_vendidos THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cantidad a devolver inválida (mayor a lo vendido o <= 0).';
    END IF;

    UPDATE variante_producto
       SET stock_actual = stock_actual + p_pares
     WHERE variante_id = p_variante_id;

    INSERT INTO movimiento_stock (variante_id, empleado_id, tipo_movimiento, cantidad)
    VALUES (p_variante_id, p_empleado_id, 'devolucion_cliente', p_pares);

    COMMIT;
END$$

DELIMITER ;

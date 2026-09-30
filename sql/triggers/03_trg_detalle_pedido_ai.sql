-- =============================================================================
-- Archivo:      03_trg_detalle_pedido_ai.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Trigger AFTER INSERT sobre detalle_pedido.
-- Regla de negocio (RF12, RF15, RF16):
--   Al vender una línea: (1) se descuentan del stock los pares vendidos,
--   (2) se registra la salida en el kardex con el vendedor del pedido como
--   responsable y (3) se recalcula pedido.total_pedido como la suma de los
--   subtotales (columna generada). Así el total nunca queda desincronizado
--   del detalle (RF12: cálculo automático del total).
-- Dependencias: detalle_pedido, pedido, presentacion_venta, variante_producto,
--               movimiento_stock, trg_detalle_pedido_bi (valida antes)
-- Estándar:     S2, S3, S6, S7
-- =============================================================================

USE pavanamoon;

DROP TRIGGER IF EXISTS trg_detalle_pedido_ai;

DELIMITER $$

CREATE TRIGGER trg_detalle_pedido_ai
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_pares       INT;
    DECLARE v_empleado_id INT;

    SELECT NEW.cantidad * cantidad_pares INTO v_pares
      FROM presentacion_venta WHERE presentacion_id = NEW.presentacion_id;

    SELECT empleado_id INTO v_empleado_id FROM pedido WHERE pedido_id = NEW.pedido_id;

    -- 1) Descontar pares vendidos.
    UPDATE variante_producto
       SET stock_actual = stock_actual - v_pares
     WHERE variante_id = NEW.variante_id;

    -- 2) Registrar la salida en el kardex.
    INSERT INTO movimiento_stock (variante_id, empleado_id, tipo_movimiento, cantidad)
    VALUES (NEW.variante_id, v_empleado_id, 'salida', v_pares);

    -- 3) Recalcular el total del pedido.
    UPDATE pedido
       SET total_pedido = (SELECT COALESCE(SUM(subtotal), 0)
                             FROM detalle_pedido WHERE pedido_id = NEW.pedido_id)
     WHERE pedido_id = NEW.pedido_id;
END$$

DELIMITER ;

-- =============================================================================
-- Archivo:      01_trg_detalle_ingreso_ai.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Trigger AFTER INSERT sobre detalle_ingreso.
-- Regla de negocio (RF08, RF15, RF16):
--   Cuando llega mercadería en un furgón y se registra una línea de ingreso,
--   el inventario de esa variante DEBE aumentar en la misma cantidad de pares,
--   y el movimiento DEBE quedar en el kardex con fecha y responsable. Hacerlo
--   en la BD (y no en la app) garantiza que ningún ingreso quede sin reflejarse
--   en el stock, sin importar desde dónde se inserte (web, Workbench, script).
--   El responsable del movimiento es el empleado que registró el ingreso.
-- Dependencias: detalle_ingreso, ingreso_mercaderia, variante_producto,
--               movimiento_stock
-- Estándar:     S2, S3, S6
-- =============================================================================

USE pavanamoon;

DROP TRIGGER IF EXISTS trg_detalle_ingreso_ai;

DELIMITER $$

CREATE TRIGGER trg_detalle_ingreso_ai
AFTER INSERT ON detalle_ingreso
FOR EACH ROW
BEGIN
    DECLARE v_empleado_id INT;

    SELECT empleado_id INTO v_empleado_id
      FROM ingreso_mercaderia
     WHERE ingreso_id = NEW.ingreso_id;

    -- 1) Sumar los pares recibidos al stock de la variante.
    UPDATE variante_producto
       SET stock_actual = stock_actual + NEW.cantidad
     WHERE variante_id = NEW.variante_id;

    -- 2) Registrar la entrada en el kardex (fecha automática, RD06).
    INSERT INTO movimiento_stock (variante_id, empleado_id, tipo_movimiento, cantidad)
    VALUES (NEW.variante_id, v_empleado_id, 'entrada', NEW.cantidad);
END$$

DELIMITER ;

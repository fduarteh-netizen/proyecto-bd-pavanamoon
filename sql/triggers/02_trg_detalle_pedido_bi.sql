-- =============================================================================
-- Archivo:      02_trg_detalle_pedido_bi.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Trigger BEFORE INSERT sobre detalle_pedido.
-- Regla de negocio (RD03, RF11):
--   No se puede vender más pares de los que hay en bodega, ni agregar líneas
--   a un pedido cancelado o ya completado. Los pares que se venden son
--   cantidad * presentacion_venta.cantidad_pares (ej.: 2 cajas = 24 pares).
--   Si no alcanza el stock se rechaza la línea con un mensaje de negocio
--   claro (SQLSTATE 45000) ANTES de tocar el inventario, en lugar de dejar
--   que falle el CHECK ck_variante_stock_actual con un error técnico.
-- Dependencias: detalle_pedido, pedido, presentacion_venta, variante_producto
-- Estándar:     S2, S3, S6
-- =============================================================================

USE pavanamoon;

DROP TRIGGER IF EXISTS trg_detalle_pedido_bi;

DELIMITER $$

CREATE TRIGGER trg_detalle_pedido_bi
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_estado        VARCHAR(20);
    DECLARE v_pares_por_pres INT;
    DECLARE v_stock         INT;

    SELECT estado INTO v_estado FROM pedido WHERE pedido_id = NEW.pedido_id;
    IF v_estado <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo se pueden agregar productos a pedidos pendientes.';
    END IF;

    SELECT cantidad_pares INTO v_pares_por_pres
      FROM presentacion_venta WHERE presentacion_id = NEW.presentacion_id;

    SELECT stock_actual INTO v_stock
      FROM variante_producto WHERE variante_id = NEW.variante_id;

    IF v_stock < NEW.cantidad * v_pares_por_pres THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock insuficiente para la variante solicitada.';
    END IF;
END$$

DELIMITER ;

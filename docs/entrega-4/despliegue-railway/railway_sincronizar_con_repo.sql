-- =============================================================================
-- Archivo:      railway_sincronizar_con_repo.sql
-- Autor:        Equipo Pavanamoon (preparado con asistencia de IA, ver bitácora)
-- Descripción:  Deja los objetos programados de la base `railway` (producción)
--               IGUALES a los del repositorio (main 28f1176).
--               NO toca tablas, columnas, restricciones ni datos.
--
-- Motivo: Railway se instaló desde un dump de la base local, que conservaba
-- objetos de versiones anteriores que no existen en sql/. Consecuencias
-- comprobadas: el filtro "Historial por cliente" (RF14) responde HTTP 500
-- y las columnas Vendedor y Pares de /pedidos salen vacías.
--
-- QUÉ HACE, EN ESTE ORDEN
--   A) ELIMINA 10 objetos que no existen en el repositorio (la app no los usa):
--        vistas:          vw_kardex_movimientos, vw_stock_bajo_minimo,
--                         vw_ventas_por_categoria
--        procedimientos:  sp_agregar_variante_ingreso, sp_agregar_variante_pedido,
--                         sp_cambiar_estado_pedido (cancela SIN devolver stock),
--                         sp_completar_ingreso, sp_registrar_ingreso
--        función:         fn_calcular_total_pedido
--        trigger:         trg_registrar_entrada_ingreso (mismo cuerpo que
--                         trg_detalle_ingreso_ai; se reemplaza por el del repo)
--   B) CREA 1 trigger:   trg_detalle_ingreso_ai
--                        (copia de sql/triggers/01_trg_detalle_ingreso_ai.sql)
--   C) REEMPLAZA 1 vista: vw_pedidos_resumen
--                        (copia de sql/views/02_vw_pedidos_resumen.sql)
--   D) REEMPLAZA 1 procedimiento: sp_crear_pedido
--                        (copia de sql/procedures/02_sp_crear_pedido.sql)
--   E) No modifica: fn_calcular_precio_linea, sp_agregar_linea_pedido,
--      sp_registrar_devolucion, sp_cancelar_pedido, vw_stock_variantes,
--      vw_kardex, vw_ingresos_detalle, vw_ventas_diarias, vw_ventas_por_modelo,
--      trg_detalle_pedido_bi, trg_detalle_pedido_ai (ya son idénticos al repo).
--
-- Resultado esperado: 19 tablas, 6 vistas, 1 función, 4 procedimientos,
-- 3 triggers (consulta final de este archivo y railway_verificar.sql).
--
-- ANTES DE EJECUTAR (ver GUIA_SINCRONIZACION_RAILWAY.md):
--   1. Respaldo completo comprobado.
--   2. railway_verificar.sql con veredicto "ESTADO ANTERIOR".
--   3. Nadie usando la app: entre el paso A y el B hay un instante sin
--      trigger de ingresos, y en el paso D sin sp_crear_pedido.
-- Es repetible: todo usa IF EXISTS / OR REPLACE. Si se interrumpe, se
-- vuelve a ejecutar completo. DDL en MySQL no es transaccional (no hay
-- ROLLBACK); la vuelta atrás es railway_revertir_sincronizacion.sql o el
-- respaldo.
-- =============================================================================

USE railway;
SET NAMES utf8mb4;

-- A) Objetos que no existen en el repositorio ----------------------------------
DROP VIEW IF EXISTS vw_kardex_movimientos;
DROP VIEW IF EXISTS vw_stock_bajo_minimo;
DROP VIEW IF EXISTS vw_ventas_por_categoria;
DROP PROCEDURE IF EXISTS sp_agregar_variante_ingreso;
DROP PROCEDURE IF EXISTS sp_agregar_variante_pedido;
DROP PROCEDURE IF EXISTS sp_cambiar_estado_pedido;
DROP PROCEDURE IF EXISTS sp_completar_ingreso;
DROP PROCEDURE IF EXISTS sp_registrar_ingreso;
DROP FUNCTION  IF EXISTS fn_calcular_total_pedido;
DROP TRIGGER   IF EXISTS trg_registrar_entrada_ingreso;

-- =============================================================================
-- B) Copia sin cambios de sql/triggers/01_trg_detalle_ingreso_ai.sql
--    (único cambio: 'USE pavanamoon;' -> 'USE railway;')
-- =============================================================================
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

USE railway;
SET NAMES utf8mb4;  -- mensajes de negocio con acentos correctos sin importar el cliente

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

-- =============================================================================
-- C) Copia sin cambios de sql/views/02_vw_pedidos_resumen.sql
--    (único cambio: 'USE pavanamoon;' -> 'USE railway;')
-- =============================================================================
-- =============================================================================
-- Archivo:      02_vw_pedidos_resumen.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Resumen de pedidos con cliente, tipo de cliente, vendedor,
--               número de líneas y pares totales. Regla de negocio: RF14
--               (historial de pedidos por cliente) y base para reportes de
--               ventas a mayoristas. El total se toma de pedido.total_pedido,
--               que mantiene el trigger trg_detalle_pedido_ai.
-- Dependencias: pedido, cliente, tipo_cliente, empleado, detalle_pedido,
--               presentacion_venta
-- Estándar:     S1, S2, S3, S7
-- =============================================================================

USE railway;
SET NAMES utf8mb4;  -- mensajes de negocio con acentos correctos sin importar el cliente

CREATE OR REPLACE VIEW vw_pedidos_resumen AS
SELECT
    pe.pedido_id,
    pe.fecha_pedido,
    pe.estado,
    cl.cliente_id,
    cl.nombre_cliente,
    cl.nit,
    tc.nombre                                   AS tipo_cliente,
    em.empleado_id,
    em.nombres_apellidos                        AS vendedor,
    COUNT(dp.variante_id)                       AS lineas,
    COALESCE(SUM(dp.cantidad * pv.cantidad_pares), 0) AS pares_totales,
    pe.total_pedido
FROM pedido pe
JOIN cliente      cl ON cl.cliente_id      = pe.cliente_id
JOIN tipo_cliente tc ON tc.tipo_cliente_id = cl.tipo_cliente_id
JOIN empleado     em ON em.empleado_id     = pe.empleado_id
LEFT JOIN detalle_pedido     dp ON dp.pedido_id       = pe.pedido_id
LEFT JOIN presentacion_venta pv ON pv.presentacion_id = dp.presentacion_id
GROUP BY pe.pedido_id, pe.fecha_pedido, pe.estado, cl.cliente_id, cl.nombre_cliente,
         cl.nit, tc.nombre, em.empleado_id, em.nombres_apellidos, pe.total_pedido;

-- =============================================================================
-- D) Copia sin cambios de sql/procedures/02_sp_crear_pedido.sql
--    (único cambio: 'USE pavanamoon;' -> 'USE railway;')
-- =============================================================================
-- =============================================================================
-- Archivo:      02_sp_crear_pedido.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Procedimiento sp_crear_pedido(cliente, empleado, OUT pedido_id)
-- Regla de negocio (RF11, RD04):
--   Todo pedido nace en estado 'pendiente', con total 0, asociado a un
--   cliente y a un vendedor con usuario ACTIVO. Centralizar la creación en
--   la BD impide pedidos "huérfanos" o hechos por empleados dados de baja.
--   No abre transacción propia: la app lo invoca dentro de su transacción
--   junto con sp_agregar_linea_pedido (todo o nada).
-- Dependencias: pedido, cliente, usuario
-- Estándar:     S2, S3, S6
-- =============================================================================

USE railway;
SET NAMES utf8mb4;  -- mensajes de negocio con acentos correctos sin importar el cliente

DROP PROCEDURE IF EXISTS sp_crear_pedido;

DELIMITER $$

CREATE PROCEDURE sp_crear_pedido(
    IN  p_cliente_id  INT,
    IN  p_empleado_id INT,
    OUT p_pedido_id   INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cliente WHERE cliente_id = p_cliente_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente indicado no existe.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM usuario
                    WHERE empleado_id = p_empleado_id AND estado = 'activo') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El vendedor no tiene un usuario activo.';
    END IF;

    INSERT INTO pedido (cliente_id, empleado_id, total_pedido, estado)
    VALUES (p_cliente_id, p_empleado_id, 0, 'pendiente');

    SET p_pedido_id = LAST_INSERT_ID();
END$$

DELIMITER ;

-- =============================================================================
-- Verificación rápida. Esperado: 19 | 6 | 1 | 4 | 3
-- (la verificación completa está en railway_verificar.sql)
-- =============================================================================
SELECT
  (SELECT COUNT(*) FROM information_schema.tables   WHERE table_schema = 'railway' AND table_type = 'BASE TABLE') AS tablas,
  (SELECT COUNT(*) FROM information_schema.views    WHERE table_schema = 'railway')                                AS vistas,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_type = 'FUNCTION')  AS funciones,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_type = 'PROCEDURE') AS procedimientos,
  (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'railway')                              AS triggers;

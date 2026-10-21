-- =============================================================================
-- Archivo:      entrega4_casos_bd.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Casos de prueba CP4-01 a CP4-07 (objetos SQL de la Entrega 4:
--               referencia pedido en kardex, devolución acumulada,
--               cancelación de pedidos y vistas de reportes).
--               Ejecutar DESPUÉS de instalar todo según INSTALL.md:
--                   mysql -t --force -u root -p < este_archivo
--               (--force: CP4-01c, CP4-03, CP4-04 y CP4-06 fallan A PROPÓSITO)
--               Crea sus propios pedidos de prueba, así no depende de ids fijos.
-- Dependencias: sql/ddl (incluye 07_ajustes_entrega4), sql/dml, sql/views,
--               sql/triggers, sql/procedures
-- =============================================================================
USE pavanamoon;
SET NAMES utf8mb4;

SET @cli_ind  = (SELECT MIN(cliente_id) FROM cliente WHERE tipo_cliente_id = 1);
SET @vend     = (SELECT MIN(empleado_id) FROM usuario u JOIN rol r ON r.rol_id = u.rol_id WHERE r.nombre_rol = 'vendedor');
SET @unidad   = (SELECT presentacion_id FROM presentacion_venta WHERE cantidad_pares = 1 LIMIT 1);
SET @var      = (SELECT variante_id FROM variante_producto ORDER BY stock_actual DESC, variante_id LIMIT 1);
SET @var2     = (SELECT variante_id FROM variante_producto WHERE variante_id <> @var ORDER BY stock_actual DESC, variante_id LIMIT 1);

SELECT '=== Datos usados por las pruebas ===' AS '';
SELECT @cli_ind AS cliente_individual, @vend AS empleado_vendedor, @unidad AS presentacion_unidad,
       @var AS variante_a, @var2 AS variante_b;

-- ---------------------------------------------------------------------------
SELECT '=== CP4-01 Devolución acumulada: vendidos 3, devolver 2 + 1 OK, el 3.º intento debe fallar ===' AS '';
CALL sp_crear_pedido(@cli_ind, @vend, @pd);
CALL sp_agregar_linea_pedido(@pd, @var, @unidad, 3);
UPDATE pedido SET estado = 'completado' WHERE pedido_id = @pd;
SET @stock_tras_venta = (SELECT stock_actual FROM variante_producto WHERE variante_id = @var);

SELECT 'CP4-01a devolver 2 (debe pasar)' AS '';
CALL sp_registrar_devolucion(@pd, @var, 2, @vend);
SELECT 'CP4-01b devolver 1 (debe pasar, completa los 3)' AS '';
CALL sp_registrar_devolucion(@pd, @var, 1, @vend);
SELECT 'CP4-01c devolver 1 más (DEBE FALLAR: ya se devolvió todo)' AS '';
CALL sp_registrar_devolucion(@pd, @var, 1, @vend);

SELECT @stock_tras_venta AS stock_tras_venta,
       stock_actual      AS stock_final_esperado_mas_3
  FROM variante_producto WHERE variante_id = @var;
SELECT tipo_movimiento, SUM(cantidad) AS pares
  FROM movimiento_stock WHERE pedido_id = @pd GROUP BY tipo_movimiento;

-- ---------------------------------------------------------------------------
SELECT '=== CP4-02 sp_cancelar_pedido: pedido pendiente de 2 líneas reintegra el stock ===' AS '';
SET @sa = (SELECT stock_actual FROM variante_producto WHERE variante_id = @var);
SET @sb = (SELECT stock_actual FROM variante_producto WHERE variante_id = @var2);
CALL sp_crear_pedido(@cli_ind, @vend, @pc);
CALL sp_agregar_linea_pedido(@pc, @var,  @unidad, 2);
CALL sp_agregar_linea_pedido(@pc, @var2, @unidad, 4);
SELECT 'Tras crear el pedido (stock baja 2 y 4)' AS '',
       (SELECT stock_actual FROM variante_producto WHERE variante_id = @var)  AS stock_a,
       (SELECT stock_actual FROM variante_producto WHERE variante_id = @var2) AS stock_b;
CALL sp_cancelar_pedido(@pc, @vend);
SELECT @sa AS stock_a_original,
       (SELECT stock_actual FROM variante_producto WHERE variante_id = @var)  AS stock_a_final_esperado_igual,
       @sb AS stock_b_original,
       (SELECT stock_actual FROM variante_producto WHERE variante_id = @var2) AS stock_b_final_esperado_igual,
       (SELECT estado FROM pedido WHERE pedido_id = @pc) AS estado_esperado_cancelado;
SELECT tipo_movimiento, variante_id, cantidad, pedido_id
  FROM vw_kardex WHERE pedido_id = @pc ORDER BY movimiento_id;
SELECT COUNT(*) AS lineas_conservadas_esperado_2 FROM detalle_pedido WHERE pedido_id = @pc;

-- ---------------------------------------------------------------------------
SELECT '=== CP4-03 Cancelar dos veces el mismo pedido (DEBE FALLAR) ===' AS '';
CALL sp_cancelar_pedido(@pc, @vend);

-- ---------------------------------------------------------------------------
SELECT '=== CP4-04 Cancelar un pedido completado (DEBE FALLAR: se usa devolución) ===' AS '';
CALL sp_cancelar_pedido(@pd, @vend);

-- ---------------------------------------------------------------------------
SELECT '=== CP4-05 Vistas de reportes cuadran con las tablas base ===' AS '';
SELECT (SELECT SUM(monto_vendido) FROM vw_ventas_diarias)                       AS monto_vista_diaria,
       (SELECT SUM(monto_vendido) FROM vw_ventas_por_modelo)                    AS monto_vista_modelo,
       (SELECT SUM(total_pedido) FROM pedido WHERE estado = 'completado')       AS monto_tabla_pedido;
SELECT (SELECT SUM(pares_devueltos) FROM vw_ventas_por_modelo)                  AS devueltos_vista,
       (SELECT SUM(cantidad) FROM movimiento_stock WHERE tipo_movimiento = 'devolucion_cliente') AS devueltos_kardex;
SELECT modelo, pares_vendidos, pares_devueltos, pares_netos
  FROM vw_ventas_por_modelo ORDER BY pares_netos DESC, modelo LIMIT 5;

-- ---------------------------------------------------------------------------
SELECT '=== CP4-06 FK fk_movimiento_pedido ON DELETE RESTRICT: borrar pedido con kardex (DEBE FALLAR) ===' AS '';
DELETE FROM pedido WHERE pedido_id = @pc;
SELECT COUNT(*) AS pedido_sigue_existiendo_esperado_1 FROM pedido WHERE pedido_id = @pc;

-- ---------------------------------------------------------------------------
SELECT '=== CP4-07 Consistencia global: stock = suma del kardex (debe devolver 0 filas) ===' AS '';
SELECT v.variante_id, v.stock_actual, SUM(k.efecto_stock) AS kardex
  FROM variante_producto v JOIN vw_kardex k ON k.variante_id = v.variante_id
 GROUP BY v.variante_id, v.stock_actual
HAVING v.stock_actual <> SUM(k.efecto_stock);
SELECT 'FIN CP4' AS '';

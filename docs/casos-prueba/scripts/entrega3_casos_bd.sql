-- =============================================================================
-- Archivo:      entrega3_casos_bd.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Casos de prueba CP3-01 a CP3-05 (vistas, triggers,
--               procedimientos). Ejecutar DESPUÉS de instalar todo según
--               INSTALL.md. Usa la variante 1, cliente mayorista e individual
--               de los datos de prueba. Se ejecuta con: mysql -t -u root -p < este_archivo
-- Dependencias: sql/ddl, sql/dml, sql/views, sql/triggers, sql/procedures
-- =============================================================================
USE pavanamoon;

SELECT '=== Conteo de registros por tabla principal (req. 7: >= 50) ===' AS '';
SELECT 'empleado' tabla, COUNT(*) n FROM empleado UNION ALL SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL SELECT 'cliente', COUNT(*) FROM cliente UNION ALL SELECT 'producto', COUNT(*) FROM producto
UNION ALL SELECT 'variante_producto', COUNT(*) FROM variante_producto UNION ALL SELECT 'furgon', COUNT(*) FROM furgon
UNION ALL SELECT 'ingreso_mercaderia', COUNT(*) FROM ingreso_mercaderia UNION ALL SELECT 'pedido', COUNT(*) FROM pedido
UNION ALL SELECT 'movimiento_stock', COUNT(*) FROM movimiento_stock;

SELECT '=== Objetos creados ===' AS '';
SELECT TABLE_NAME AS vista FROM information_schema.VIEWS WHERE TABLE_SCHEMA='pavanamoon';
SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING, EVENT_OBJECT_TABLE FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='pavanamoon';
SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='pavanamoon';

SELECT '=== Consistencia: stock = kardex (debe devolver 0 filas) ===' AS '';
SELECT v.variante_id, v.stock_actual, SUM(k.efecto_stock) kardex
  FROM variante_producto v JOIN vw_kardex k ON k.variante_id = v.variante_id
 GROUP BY v.variante_id, v.stock_actual HAVING v.stock_actual <> SUM(k.efecto_stock);

-- ---------------------------------------------------------------------------
SELECT '=== CP3-01 Trigger trg_detalle_ingreso_ai: ingreso de 20 pares a variante 1 ===' AS '';
SELECT stock_actual AS stock_antes FROM variante_producto WHERE variante_id = 1;
SELECT COUNT(*) AS movimientos_antes FROM movimiento_stock WHERE variante_id = 1;
INSERT INTO ingreso_mercaderia (furgon_id, empleado_id, bodega_destino) VALUES (1, 2, 'Bodega Central Xela');
INSERT INTO detalle_ingreso (ingreso_id, variante_id, cantidad, costo_unitario) VALUES (LAST_INSERT_ID(), 1, 20, 90.00);
SELECT stock_actual AS stock_despues_esperado_mas_20 FROM variante_producto WHERE variante_id = 1;
SELECT tipo_movimiento, cantidad, responsable FROM vw_kardex WHERE variante_id = 1 ORDER BY movimiento_id DESC LIMIT 1;

-- ---------------------------------------------------------------------------
SELECT '=== CP3-02 fn_calcular_precio_linea: individual x unidad vs mayorista x caja ===' AS '';
SET @cli_ind = (SELECT MIN(cliente_id) FROM cliente WHERE tipo_cliente_id = 1);
SET @cli_may = (SELECT MIN(cliente_id) FROM cliente WHERE tipo_cliente_id = 2);
SELECT p.precio_venta AS precio_par,
       fn_calcular_precio_linea(1, 1, @cli_ind) AS individual_unidad_esperado_precio_par,
       fn_calcular_precio_linea(1, 2, @cli_may) AS mayorista_caja_esperado_12x_menos_15pct,
       ROUND(p.precio_venta * 12 * 0.85, 2)     AS calculo_manual
  FROM variante_producto v JOIN producto p ON p.producto_id = v.producto_id WHERE v.variante_id = 1;

-- ---------------------------------------------------------------------------
SELECT '=== CP3-03 sp_crear_pedido + sp_agregar_linea_pedido (mayorista, 1 caja) ===' AS '';
SET @stock_antes = (SELECT stock_actual FROM variante_producto WHERE variante_id = 1);
CALL sp_crear_pedido(@cli_may, 3, @pid);
CALL sp_agregar_linea_pedido(@pid, 1, 2, 1);
SELECT pedido_id, estado, tipo_cliente, pares_totales, total_pedido FROM vw_pedidos_resumen WHERE pedido_id = @pid;
SELECT @stock_antes AS stock_antes, stock_actual AS stock_despues_esperado_menos_12 FROM variante_producto WHERE variante_id = 1;
SELECT tipo_movimiento, cantidad FROM movimiento_stock WHERE variante_id = 1 ORDER BY movimiento_id DESC LIMIT 1;

-- ---------------------------------------------------------------------------
SELECT '=== CP3-04 trg_detalle_pedido_bi: vender más de lo disponible (debe fallar) ===' AS '';
SET @stock_antes = (SELECT stock_actual FROM variante_producto WHERE variante_id = 2);
CALL sp_crear_pedido(@cli_ind, 3, @pid2);
-- Se espera: ERROR 1644 (45000): Stock insuficiente para la variante solicitada.
CALL sp_agregar_linea_pedido(@pid2, 2, 1, 99999);
SELECT @stock_antes AS stock_antes, stock_actual AS stock_despues_sin_cambios FROM variante_producto WHERE variante_id = 2;
SELECT COUNT(*) AS lineas_insertadas_esperado_0 FROM detalle_pedido WHERE pedido_id = @pid2;

-- ---------------------------------------------------------------------------
SELECT '=== CP3-05 sp_registrar_devolucion ===' AS '';
UPDATE pedido SET estado = 'completado' WHERE pedido_id = @pid;
-- (a) devolver más de lo vendido -> ERROR 45000, sin cambios
CALL sp_registrar_devolucion(@pid, 1, 50, 3);
SET @stock_antes = (SELECT stock_actual FROM variante_producto WHERE variante_id = 1);
-- (b) devolución válida de 2 pares -> stock +2 y movimiento devolucion_cliente
CALL sp_registrar_devolucion(@pid, 1, 2, 3);
SELECT @stock_antes AS stock_antes, stock_actual AS stock_despues_esperado_mas_2 FROM variante_producto WHERE variante_id = 1;
SELECT tipo_movimiento, cantidad FROM movimiento_stock WHERE variante_id = 1 ORDER BY movimiento_id DESC LIMIT 1;

-- Limpieza del pedido vacío de CP3-04
DELETE FROM pedido WHERE pedido_id = @pid2;

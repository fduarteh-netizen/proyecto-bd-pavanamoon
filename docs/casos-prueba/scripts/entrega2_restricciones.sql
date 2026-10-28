-- =============================================================================
-- Archivo:      entrega2_restricciones.sql
-- Autor:        Equipo Pavanamoon (preparado con asistencia de IA, ver bitácora)
-- Descripción:  Casos CP-01 a CP-10 de la Entrega 2 (CASOS_PRUEBA.md, parte 2):
--               restricciones de integridad ejecutadas directamente en SQL.
--               Los casos que deben fallar muestran su ERROR; usar --force:
--                 mysql -t --force -u root < docs/casos-prueba/scripts/entrega2_restricciones.sql
-- Dependencias: base pavanamoon instalada (INSTALL.md)
-- =============================================================================
USE pavanamoon;
SET NAMES utf8mb4;

SELECT 'CP-01 cliente con NIT nuevo (debe pasar)' AS caso;
INSERT INTO cliente (tipo_cliente_id, nombre_cliente, nit) VALUES (1, 'Cliente CP-01', '9990001');
SELECT cliente_id, nombre_cliente, nit FROM cliente WHERE nit = '9990001';

SELECT 'CP-02 cliente con NIT repetido (debe fallar: uq_cliente_nit)' AS caso;
INSERT INTO cliente (tipo_cliente_id, nombre_cliente, nit) VALUES (1, 'Cliente CP-02', '9990001');

SELECT 'CP-03 producto con precio -10 (debe fallar: ck_producto_precio)' AS caso;
INSERT INTO producto (categoria_id, modelo, tipo_suela, precio_venta) VALUES (1, 'Modelo CP-03', 'Hule', -10);

SELECT 'CP-04 producto con categoria 999 (debe fallar: fk_producto_categoria)' AS caso;
INSERT INTO producto (categoria_id, modelo, tipo_suela, precio_venta) VALUES (999, 'Modelo CP-04', 'Hule', 100);

SELECT 'CP-05 variante con stock -5 (debe fallar: ck_variante_stock_actual)' AS caso;
INSERT INTO producto (categoria_id, modelo, tipo_suela, precio_venta) VALUES (1, 'Modelo CP-05', 'Hule', 100);
SET @prod = LAST_INSERT_ID();
INSERT INTO variante_producto (producto_id, talla_id, color_id, sku, stock_actual, stock_minimo) VALUES (@prod, 1, 1, 'SKU-E2-CP05', -5, 1);

SELECT 'CP-06 variante válida con stock 10 (debe pasar)' AS caso;
INSERT INTO variante_producto (producto_id, talla_id, color_id, sku, stock_actual, stock_minimo) VALUES (@prod, 1, 1, 'SKU-E2-TEST-001', 10, 1);
SELECT variante_id, sku, stock_actual FROM variante_producto WHERE sku = 'SKU-E2-TEST-001';

SELECT 'CP-07 variante con el mismo SKU (debe fallar: uq_variante_sku)' AS caso;
INSERT INTO variante_producto (producto_id, talla_id, color_id, sku, stock_actual, stock_minimo) VALUES (@prod, 2, 1, 'SKU-E2-TEST-001', 0, 1);

SELECT 'CP-08 variante con la misma combinación producto-talla-color (debe fallar: uq_variante_combinacion)' AS caso;
INSERT INTO variante_producto (producto_id, talla_id, color_id, sku, stock_actual, stock_minimo) VALUES (@prod, 1, 1, 'SKU-E2-OTRO', 0, 1);

SELECT 'CP-09 borrar una categoría con productos (debe fallar: FK ON DELETE RESTRICT)' AS caso;
DELETE FROM categoria WHERE categoria_id = 1;
SELECT COUNT(*) AS categoria_1_sigue_existiendo FROM categoria WHERE categoria_id = 1;

SELECT 'CP-10 detalle_ingreso 10 x 85.50: subtotal generado = 855.00 (debe pasar)' AS caso;
-- La variante se lee antes: el trigger de detalle_ingreso actualiza variante_producto,
-- y MySQL no permite leer esa misma tabla dentro del INSERT que dispara el trigger.
SET @var = (SELECT variante_id FROM variante_producto WHERE sku = 'SKU-E2-TEST-001');
INSERT INTO ingreso_mercaderia (furgon_id, empleado_id, bodega_destino, estado) VALUES ((SELECT MIN(furgon_id) FROM furgon), 1, 'Bodega CP-10', 'completado');
SET @ing = LAST_INSERT_ID();
INSERT INTO detalle_ingreso (ingreso_id, variante_id, cantidad, costo_unitario) VALUES (@ing, @var, 10, 85.50);
SELECT cantidad, costo_unitario, subtotal FROM detalle_ingreso WHERE ingreso_id = @ing AND variante_id = @var;

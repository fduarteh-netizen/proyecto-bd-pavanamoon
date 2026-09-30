-- =============================================================================
-- Archivo:      01_fn_calcular_precio_linea.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Función fn_calcular_precio_linea(variante, presentacion, cliente)
-- Regla de negocio (RF13, S7):
--   El precio de una línea de pedido NO se digita a mano: se calcula como
--     producto.precio_venta (precio por par)
--       * presentacion_venta.cantidad_pares   (1 = unidad, 12 = caja)
--       * (1 - tipo_cliente.porcentaje_descuento / 100)
--   Así el mayorista recibe automáticamente su descuento y el precio vive en
--   un solo lugar (producto), sin duplicarlo en presentacion_venta.
-- Dependencias: variante_producto, producto, presentacion_venta, cliente,
--               tipo_cliente (columna porcentaje_descuento, ddl/06)
-- Estándar:     S2, S3, S6, S7
-- =============================================================================

USE pavanamoon;

DROP FUNCTION IF EXISTS fn_calcular_precio_linea;

DELIMITER $$

CREATE FUNCTION fn_calcular_precio_linea(
    p_variante_id     INT,
    p_presentacion_id INT,
    p_cliente_id      INT
)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_precio_par  DECIMAL(10,2);
    DECLARE v_pares       INT;
    DECLARE v_descuento   DECIMAL(5,2);

    SELECT p.precio_venta INTO v_precio_par
      FROM variante_producto vp
      JOIN producto p ON p.producto_id = vp.producto_id
     WHERE vp.variante_id = p_variante_id;

    SELECT cantidad_pares INTO v_pares
      FROM presentacion_venta WHERE presentacion_id = p_presentacion_id;

    SELECT tc.porcentaje_descuento INTO v_descuento
      FROM cliente c
      JOIN tipo_cliente tc ON tc.tipo_cliente_id = c.tipo_cliente_id
     WHERE c.cliente_id = p_cliente_id;

    RETURN ROUND(v_precio_par * v_pares * (1 - v_descuento / 100), 2);
END$$

DELIMITER ;

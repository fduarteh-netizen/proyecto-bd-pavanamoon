-- =============================================================================
-- Archivo:      01_vw_stock_variantes.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Vista de inventario por variante (producto + talla + color)
--               con bandera de alerta cuando stock_actual <= stock_minimo.
--               Regla de negocio: RF03 (consultar stock en tiempo real) y
--               RF04 (identificar variantes bajo el umbral mínimo). Evita que
--               la app repita el JOIN de 5 tablas en cada pantalla.
-- Dependencias: variante_producto, producto, categoria, talla, color
-- Estándar:     S1, S2, S3, S7 (la alerta se calcula, no se almacena)
-- =============================================================================

USE pavanamoon;

CREATE OR REPLACE VIEW vw_stock_variantes AS
SELECT
    vp.variante_id,
    vp.sku,
    p.producto_id,
    p.modelo,
    c.nombre_categoria                         AS categoria,
    p.tipo_suela,
    t.valor_talla                              AS talla,
    co.nombre_color                            AS color,
    p.precio_venta,
    vp.stock_actual,
    vp.stock_minimo,
    (vp.stock_actual <= vp.stock_minimo)       AS alerta_stock_bajo
FROM variante_producto vp
JOIN producto  p  ON p.producto_id   = vp.producto_id
JOIN categoria c  ON c.categoria_id  = p.categoria_id
JOIN talla     t  ON t.talla_id      = vp.talla_id
JOIN color     co ON co.color_id     = vp.color_id;

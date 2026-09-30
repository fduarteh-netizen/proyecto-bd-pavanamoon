-- =============================================================================
-- Archivo:      03_vw_kardex.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Kardex legible: cada movimiento de stock con la variante
--               (SKU, modelo, talla, color), el responsable y el efecto con
--               signo sobre el inventario (+ entrada/devolución, - salida).
--               Regla de negocio: RF16 (historial auditable por variante) y
--               RF18 (reporte por variante y rango de fechas: la app filtra
--               esta vista con WHERE parametrizado).
-- Dependencias: movimiento_stock, variante_producto, producto, talla, color,
--               empleado
-- Estándar:     S1, S2, S3, S7
-- =============================================================================

USE pavanamoon;

CREATE OR REPLACE VIEW vw_kardex AS
SELECT
    ms.movimiento_id,
    ms.fecha_movimiento,
    ms.tipo_movimiento,
    ms.cantidad,
    CASE
        WHEN ms.tipo_movimiento IN ('entrada', 'devolucion_cliente') THEN  ms.cantidad
        WHEN ms.tipo_movimiento = 'salida'                            THEN -ms.cantidad
        ELSE 0
    END                                  AS efecto_stock,
    vp.variante_id,
    vp.sku,
    p.modelo,
    t.valor_talla                        AS talla,
    co.nombre_color                      AS color,
    em.nombres_apellidos                 AS responsable
FROM movimiento_stock ms
JOIN variante_producto vp ON vp.variante_id = ms.variante_id
JOIN producto          p  ON p.producto_id  = vp.producto_id
JOIN talla             t  ON t.talla_id     = vp.talla_id
JOIN color             co ON co.color_id    = vp.color_id
JOIN empleado          em ON em.empleado_id = ms.empleado_id;

-- =============================================================================
-- Archivo:      06_vw_ventas_por_modelo.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Desempeño de venta por modelo de calzado (reporte de
--               productos más vendidos). Por cada modelo:
--                 - pares vendidos y monto en pedidos COMPLETADOS;
--                 - pares devueltos por clientes (kardex, tipo
--                   'devolucion_cliente');
--                 - pares netos = vendidos - devueltos.
--               Incluye modelos sin ventas (LEFT JOIN) para que el reporte
--               también muestre lo que no rota. El orden (top N) lo define
--               la app con ORDER BY / LIMIT parametrizado.
-- Dependencias: producto, categoria, variante_producto, detalle_pedido,
--               pedido, presentacion_venta, movimiento_stock
-- Estándar:     S1, S2, S3, S7
-- =============================================================================

USE pavanamoon;
SET NAMES utf8mb4;

CREATE OR REPLACE VIEW vw_ventas_por_modelo AS
SELECT
    p.producto_id,
    p.modelo,
    c.nombre_categoria                                AS categoria,
    p.tipo_suela,
    COALESCE(v.pares_vendidos, 0)                     AS pares_vendidos,
    COALESCE(v.monto_vendido, 0)                      AS monto_vendido,
    COALESCE(d.pares_devueltos, 0)                    AS pares_devueltos,
    COALESCE(v.pares_vendidos, 0) - COALESCE(d.pares_devueltos, 0) AS pares_netos
FROM producto p
JOIN categoria c ON c.categoria_id = p.categoria_id
LEFT JOIN (
    SELECT vp.producto_id,
           SUM(dp.cantidad * pv.cantidad_pares) AS pares_vendidos,
           SUM(dp.subtotal)                     AS monto_vendido
      FROM detalle_pedido dp
      JOIN pedido             pe ON pe.pedido_id       = dp.pedido_id
      JOIN presentacion_venta pv ON pv.presentacion_id = dp.presentacion_id
      JOIN variante_producto  vp ON vp.variante_id     = dp.variante_id
     WHERE pe.estado = 'completado'
     GROUP BY vp.producto_id
) v ON v.producto_id = p.producto_id
LEFT JOIN (
    SELECT vp.producto_id, SUM(ms.cantidad) AS pares_devueltos
      FROM movimiento_stock ms
      JOIN variante_producto vp ON vp.variante_id = ms.variante_id
     WHERE ms.tipo_movimiento = 'devolucion_cliente'
     GROUP BY vp.producto_id
) d ON d.producto_id = p.producto_id;

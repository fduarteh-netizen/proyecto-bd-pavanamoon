-- =============================================================================
-- Archivo:      05_vw_ventas_diarias.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Ventas consolidadas por día (reporte de ventas por periodo).
--               Regla de negocio: una venta cuenta solo cuando el pedido está
--               COMPLETADO (entregado). Los pendientes aún pueden cancelarse y
--               los cancelados nunca generaron ingreso, por eso se excluyen.
--               La app filtra por rango de fechas con WHERE parametrizado y
--               puede agrupar por mes sobre esta misma vista.
--               El total se suma desde pedido.total_pedido (ya calculado por
--               trg_detalle_pedido_ai) y los pares desde el detalle; se usan
--               subconsultas separadas para que el JOIN con el detalle no
--               duplique los totales.
-- Dependencias: pedido, detalle_pedido, presentacion_venta
-- Estándar:     S1, S2, S3, S7 (nada se almacena: todo se calcula al consultar)
-- =============================================================================

USE pavanamoon;
SET NAMES utf8mb4;

CREATE OR REPLACE VIEW vw_ventas_diarias AS
SELECT
    t.fecha,
    t.pedidos,
    COALESCE(pr.pares, 0)            AS pares_vendidos,
    t.monto                          AS monto_vendido,
    ROUND(t.monto / t.pedidos, 2)    AS ticket_promedio
FROM (
    SELECT DATE(fecha_pedido) AS fecha,
           COUNT(*)           AS pedidos,
           SUM(total_pedido)  AS monto
      FROM pedido
     WHERE estado = 'completado'
     GROUP BY DATE(fecha_pedido)
) t
LEFT JOIN (
    SELECT DATE(pe.fecha_pedido)               AS fecha,
           SUM(dp.cantidad * pv.cantidad_pares) AS pares
      FROM pedido pe
      JOIN detalle_pedido     dp ON dp.pedido_id       = pe.pedido_id
      JOIN presentacion_venta pv ON pv.presentacion_id = dp.presentacion_id
     WHERE pe.estado = 'completado'
     GROUP BY DATE(pe.fecha_pedido)
) pr ON pr.fecha = t.fecha;

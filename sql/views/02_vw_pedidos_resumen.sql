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

USE pavanamoon;

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

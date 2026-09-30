-- =============================================================================
-- Archivo:      04_vw_ingresos_detalle.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Historial de ingresos de mercadería por furgón, con número
--               de líneas, pares recibidos y costo total del ingreso.
--               Regla de negocio: RF09 (historial de ingresos filtrable por
--               fecha, bodega o número de furgón).
-- Dependencias: ingreso_mercaderia, furgon, empleado, detalle_ingreso
-- Estándar:     S1, S2, S3, S7 (el costo total se calcula, no se almacena)
-- =============================================================================

USE pavanamoon;

CREATE OR REPLACE VIEW vw_ingresos_detalle AS
SELECT
    im.ingreso_id,
    im.fecha_ingreso,
    im.bodega_destino,
    im.estado,
    f.furgon_id,
    f.numero_furgon,
    em.nombres_apellidos                 AS responsable,
    COUNT(di.variante_id)                AS lineas,
    COALESCE(SUM(di.cantidad), 0)        AS pares_recibidos,
    COALESCE(SUM(di.subtotal), 0)        AS costo_total
FROM ingreso_mercaderia im
JOIN furgon   f  ON f.furgon_id    = im.furgon_id
JOIN empleado em ON em.empleado_id = im.empleado_id
LEFT JOIN detalle_ingreso di ON di.ingreso_id = im.ingreso_id
GROUP BY im.ingreso_id, im.fecha_ingreso, im.bodega_destino, im.estado,
         f.furgon_id, f.numero_furgon, em.nombres_apellidos;

# sql/views

Vistas de la base `pavanamoon`. Un `CREATE OR REPLACE VIEW` por archivo
(estándar S2), con encabezado (S3). Ninguna almacena datos: todo se calcula
al consultar (S7). Se instalan después de `sql/dml` (ver `INSTALL.md`).

| Archivo | Vista | Qué devuelve | Requerimiento | Desde |
|---|---|---|---|---|
| `01_vw_stock_variantes.sql` | `vw_stock_variantes` | Stock por variante (modelo, categoría, talla, color) con `alerta_stock_bajo` cuando `stock_actual <= stock_minimo` | RF03, RF04 | E3 |
| `02_vw_pedidos_resumen.sql` | `vw_pedidos_resumen` | Pedido con cliente (`cliente_id`, NIT, tipo), vendedor, líneas, pares totales, total y estado. La usan `/pedidos` y el filtro por cliente | RF14 | E3 |
| `03_vw_kardex.sql` | `vw_kardex` | Cada movimiento con variante legible, responsable, `pedido_id` de origen y `efecto_stock` con signo (+ entrada, devolución y cancelación; − salida) | RF16, RF18 | E3, cambio E4 |
| `04_vw_ingresos_detalle.sql` | `vw_ingresos_detalle` | Ingreso por furgón con líneas, pares recibidos y costo total | RF09 | E3 |
| `05_vw_ventas_diarias.sql` | `vw_ventas_diarias` | Ventas por día: solo pedidos `completado` (los pendientes pueden cancelarse y los cancelados no generaron ingreso) | Reportes de ventas | E4 |
| `06_vw_ventas_por_modelo.sql` | `vw_ventas_por_modelo` | Por modelo: pares vendidos y monto (completados), pares devueltos (kardex) y netos; incluye modelos sin ventas | Reportes de ventas | E4 |

**Comprobación:** `CP4-05` verifica que las vistas de reportes cuadran con
`pedido` y `movimiento_stock`, y `CP4-07` usa `vw_kardex` para comprobar
que stock = suma del kardex.

**En Railway** el esquema se llama `railway`. Estas 6 son las únicas vistas
que deben existir allí; `docs/entrega-4/despliegue-railway/railway_verificar.sql`
lo comprueba.

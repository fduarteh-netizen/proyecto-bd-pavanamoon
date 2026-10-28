# sql/triggers

Triggers de la base `pavanamoon`. Un trigger por archivo (estándar S2), con
encabezado (S3) y su regla de negocio explicada (S6). Se instalan después de
`sql/views` (ver `INSTALL.md`).

| Archivo | Trigger | Evento | Regla de negocio | Requerimiento | Desde |
|---|---|---|---|---|---|
| `01_trg_detalle_ingreso_ai.sql` | `trg_detalle_ingreso_ai` | AFTER INSERT `detalle_ingreso` | Toda mercadería recibida suma al stock y queda en el kardex como `entrada`, con el empleado del ingreso como responsable | RF08, RF15, RF16 | E3 |
| `02_trg_detalle_pedido_bi.sql` | `trg_detalle_pedido_bi` | BEFORE INSERT `detalle_pedido` | No se venden más pares de los que hay (cantidad × pares de la presentación) ni se agregan líneas a un pedido que no esté `pendiente`; rechaza con `SIGNAL 45000`. **E4:** lee el stock con `FOR UPDATE` | RD03, RF11 | E3, cambio E4 |
| `03_trg_detalle_pedido_ai.sql` | `trg_detalle_pedido_ai` | AFTER INSERT `detalle_pedido` | Descuenta los pares, registra la `salida` en el kardex (**E4:** con `pedido_id`) y recalcula `pedido.total_pedido` | RF12, RF15, RF16 | E3, cambio E4 |

**¿Por qué en triggers y no en la app?** Porque la regla debe cumplirse sin
importar desde dónde se inserte (web, Workbench o un script).

**Nombre en otras bases.** Una versión anterior llamaba
`trg_registrar_entrada_ingreso` al trigger de ingresos (con el mismo
cuerpo). El nombre correcto es `trg_detalle_ingreso_ai`.

**Comprobación:** CP3-01, CP3-03, CP3-04, CP4-07, INT-01 a INT-04.

# sql/procedures

Función y procedimientos almacenados de la base `pavanamoon`. Una rutina por
archivo (estándar S2), con encabezado (S3) y su regla de negocio explicada
(S6). Se instalan después de `sql/triggers` (ver `INSTALL.md`).

| Archivo | Rutina | Regla de negocio | Requerimiento | Desde |
|---|---|---|---|---|
| `01_fn_calcular_precio_linea.sql` | `fn_calcular_precio_linea(variante, presentacion, cliente)` | Precio = precio por par × pares de la presentación × (1 − descuento del tipo de cliente). El usuario nunca digita el precio | RF13 | E3 |
| `02_sp_crear_pedido.sql` | `sp_crear_pedido(cliente, empleado, OUT pedido_id)` | El pedido nace `pendiente` con total 0; el cliente debe existir y el vendedor debe tener un usuario **activo**. No abre transacción propia: la app lo llama dentro de la suya | RF11, RD04 | E3 |
| `03_sp_agregar_linea_pedido.sql` | `sp_agregar_linea_pedido(pedido, variante, presentacion, cantidad)` | Inserta la línea con el precio de la función; los triggers validan y descuentan stock. **E4:** bloquea la variante (`FOR UPDATE`) para serializar pedidos simultáneos sin deadlock | RF11–RF13, RD03 | E3, cambio E4 |
| `04_sp_registrar_devolucion.sql` | `sp_registrar_devolucion(pedido, variante, pares, empleado)` | Solo pedidos `completado` y variantes compradas. **E4:** disponible = vendido − ya devuelto (antes se podía devolver la misma línea varias veces); bloquea el pedido. Transaccional (`ROLLBACK` + `RESIGNAL`) | RF17, RF15 | E3, cambio E4 |
| `05_sp_cancelar_pedido.sql` | `sp_cancelar_pedido(pedido, empleado)` | Solo pedidos `pendiente`: cada línea vuelve al stock como `cancelacion` con referencia al pedido; el detalle se conserva; no se cancela dos veces; atómico | RF11, RF15, RF16 | E4 |

**Seguridad:** `rol_vendedor` tiene `EXECUTE` sobre las rutinas de pedidos,
incluida `sp_cancelar_pedido` (`sql/security/02_privilegios_entrega4.sql`),
pero no `INSERT` directo sobre `pedido` ni `detalle_pedido`.

**Rutinas que no existen en el repositorio.** `fn_calcular_total_pedido`,
`sp_agregar_variante_ingreso`, `sp_agregar_variante_pedido`,
`sp_cambiar_estado_pedido`, `sp_completar_ingreso` y `sp_registrar_ingreso`
son de versiones anteriores. Si aparecen en una base, esa base no se instaló
desde `sql/` (ver `docs/entrega-4/ENTREGA4_IMPLEMENTACION.md`, sección 4.2).

**Comprobación:** CP3-02, CP3-03, CP3-05, CP4-01 a CP4-04 e INT-03 a INT-06.

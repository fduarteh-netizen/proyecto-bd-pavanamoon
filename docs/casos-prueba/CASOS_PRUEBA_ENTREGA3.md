# Casos de Prueba — Entrega 3
## Proyecto Pavanamoon

Pruebas ejecutadas de verdad contra **MySQL 8.0.46** y la aplicación web
corriendo localmente (Node.js), sobre una base instalada **desde cero** con el
orden de `INSTALL.md`. Los scripts son reproducibles:

| Script | Casos | Salida real |
|---|---|---|
| [`scripts/entrega3_casos_bd.sql`](./scripts/entrega3_casos_bd.sql) | CP3-01 a CP3-05 | [`evidencias/entrega3_casos_bd.txt`](./evidencias/entrega3_casos_bd.txt) |
| [`scripts/entrega3_casos_seguridad.sh`](./scripts/entrega3_casos_seguridad.sh) | CP3-06, CP3-07 | [`evidencias/entrega3_casos_seguridad.txt`](./evidencias/entrega3_casos_seguridad.txt) |
| [`scripts/entrega3_casos_web.sh`](./scripts/entrega3_casos_web.sh) | CP3-08 | [`evidencias/entrega3_casos_web.txt`](./evidencias/entrega3_casos_web.txt) |

Instalación completa sin errores: [`evidencias/entrega3_instalacion_desde_cero.txt`](./evidencias/entrega3_instalacion_desde_cero.txt).

---

## Casos de prueba

| Caso | Objeto probado | Acción | Resultado esperado | Resultado obtenido |
|---|---|---|---|---|
| **CP3-01** | `trg_detalle_ingreso_ai` | Insertar un ingreso de 20 pares a la variante 1 | Stock +20 y 1 movimiento `entrada` con el responsable del ingreso | ✅ PASA — stock 48 → 68; kardex: `entrada 20` |
| **CP3-02** | `fn_calcular_precio_linea` | Precio de variante de Q260/par: individual × unidad y mayorista × caja | Q260.00 y Q260 × 12 × 0.85 = Q2,652.00 | ✅ PASA — 260.00 y 2652.00 (igual al cálculo manual) |
| **CP3-03** | `sp_crear_pedido` + `sp_agregar_linea_pedido` + `trg_detalle_pedido_ai` | Pedido de mayorista, 1 caja de la variante 1 | Pedido `pendiente`, total Q2,652.00 calculado por trigger, stock −12, movimiento `salida 12` | ✅ PASA — total 2652.00; stock 68 → 56; kardex `salida 12` |
| **CP3-04** | `trg_detalle_pedido_bi` | Agregar 99,999 pares de la variante 2 | Rechazo con `ERROR 1644 (45000) Stock insuficiente…`, stock sin cambios, 0 líneas | ✅ PASA — error de negocio; stock 36 → 36; 0 líneas |
| **CP3-05** | `sp_registrar_devolucion` | (a) devolver 50 pares de un pedido con 12 vendidos; (b) devolver 2 pares | (a) rechazo y ROLLBACK; (b) stock +2 y movimiento `devolucion_cliente` | ✅ PASA — (a) `Cantidad a devolver inválida…`; (b) stock 56 → 58, kardex `devolucion_cliente 2` |
| **CP3-06** | `rol_vendedor` | Con `pvm_ventas`: leer clientes, leer `usuario`, insertar furgón, modificar stock, borrar cliente, crear pedido por procedimiento | Solo lee clientes y crea pedidos vía `CALL`; lo demás `ERROR 1142` | ✅ PASA — 60 clientes visibles; `usuario`, `furgon`, `variante_producto` y `DELETE` denegados; `CALL sp_crear_pedido` permitido |
| **CP3-07** | `rol_bodeguero` / `rol_administrador` | Con `pvm_bodega`: leer clientes/pedidos, insertar furgón, borrar furgón. Con `pvm_admin`: borrar | Bodega: clientes/pedidos denegados, INSERT furgón permitido, DELETE denegado. Admin: DELETE permitido | ✅ PASA — exactamente lo esperado |
| **CP3-08** | App web: control por rol + flujos | (a) matriz de rutas por rol, (b) menú por rol, (c) pedido web mayorista, (d) pedido web sin stock, (e) ingreso web, (f) URL manual prohibida | (a) 403 donde no hay permiso; (c) stock −12; (d) mensaje de negocio y ningún pedido creado; (e) stock +30; (f) 403 con mensaje | ✅ PASA — ver tabla de rutas abajo |

**8/8 casos exitosos.** Además, la verificación de consistencia
stock = kardex devuelve 0 filas con inconsistencia.

### CP3-08 (a) — Matriz de rutas por rol (HTTP obtenido)

| Módulo | admin | bodega | ventas |
|---|---|---|---|
| productos | 200 | 200 | 403 |
| inventario | 200 | 200 | 200 |
| furgones | 200 | 200 | 403 |
| ingresos | 200 | 200 | 403 |
| clientes | 200 | 403 | 200 |
| pedidos | 200 | 403 | 200 |
| kardex | 200 | 200 | 403 |

Capturas: `evidencias/e3_05_home_vendedor.png`, `e3_06_vendedor_403.png`,
`e3_08_home_bodeguero.png`, `e3_03_pedido_detalle.png`, `e3_09_ingreso_detalle.png`.

---

## Matriz de trazabilidad (requerimiento → implementación → prueba)

| Requerimiento | Implementación BD | Implementación web | Prueba |
|---|---|---|---|
| RF01, RF05, RD01 — Productos por categoría / precio | `producto`, `categoria`, `ck_producto_precio` | `/productos` | CP-03, CP-04 (E2) |
| RF02, RD02 — Variantes únicas talla+color | `variante_producto`, `uq_variante_combinacion` | `/inventario/nueva` | CP-07, CP-08 (E2) |
| RF03 — Stock en tiempo real | `vw_stock_variantes` | `/inventario` | CP3-01, CP3-03 |
| RF04 — Alerta de stock mínimo | `vw_stock_variantes.alerta_stock_bajo` | `/inventario?alertas=1` | CP3-08 (captura e3_02) |
| RF06 — Furgones | `furgon` | `/furgones` (CRUD) | CP3-07, CP3-08 |
| RF07, RD05 — Ingreso con furgón, bodega, responsable | `ingreso_mercaderia` | `/ingresos/nuevo` (responsable = sesión) | CP3-08 (e) |
| RF08 — Detalle de ingreso actualiza stock | `trg_detalle_ingreso_ai` | `/ingresos` | CP3-01, CP3-08 (e) |
| RF09 — Historial de ingresos | `vw_ingresos_detalle` | `/ingresos` | CP3-08 (captura e3_09) |
| RF10, RD07 — Clientes, NIT único | `cliente`, `uq_cliente_nit` | `/clientes` | CP-01, CP-02 (E2) |
| RF11, RD04 — Pedido con cliente y vendedor | `sp_crear_pedido`, `sp_agregar_linea_pedido` | `/pedidos/nuevo` | CP3-03, CP3-08 (c) |
| RF12 — Total automático | `trg_detalle_pedido_ai` | `/pedidos/:id` | CP3-03 |
| RF13 — Descuento mayorista | `fn_calcular_precio_linea`, `tipo_cliente.porcentaje_descuento` | precio calculado por la BD | CP3-02, CP3-03 |
| RD03 — Stock nunca negativo | `trg_detalle_pedido_bi` + `ck_variante_stock_actual` | mensaje en formulario | CP3-04, CP3-08 (d) |
| RF14 — Historial por cliente | `vw_pedidos_resumen` | `/pedidos?cliente=` | CP3-08 |
| RF15, RF16, RD06 — Kardex con fecha y responsable | `movimiento_stock`, triggers, `vw_kardex` | `/kardex` | CP3-01, CP3-03, CP3-05 |
| RF17 — Devoluciones | `sp_registrar_devolucion` | `/pedidos/:id` (devolución) | CP3-05 |
| RF18 — Reporte por variante y fechas | `vw_kardex` | `/kardex?sku=&desde=&hasta=` | CP3-08 (captura e3_04) |
| RF19, RD09 — 3 roles | `rol` + roles MySQL (`sql/security`) | `config/permisos.js` | CP3-06, CP3-07 |
| RF20, RD08 — Autenticación, username único | `usuario`, bcrypt | `/login` | E2 (casos web) |
| RF21 — Operaciones según rol | `GRANT` diferenciados | `requireRole`, menú filtrado | CP3-06, CP3-07, CP3-08 |
| Sección 5 req. 7 — ≥ 50 registros | `sql/dml/01_datos_prueba.sql` | — | conteo en `entrega3_casos_bd.txt` |

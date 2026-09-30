# Entrega 3 — Implementación avanzada, seguridad y pruebas
## Proyecto Pavanamoon

Este documento resume lo implementado en la Entrega 3 y justifica cada objeto
de base de datos con su regla de negocio (estándar S6). Todo fue ejecutado
desde cero contra **MySQL 8.0** real (ver
[`casos-prueba/evidencias/entrega3_instalacion_desde_cero.txt`](../casos-prueba/evidencias/entrega3_instalacion_desde_cero.txt)).

## 1. Resumen de productos entregados

| Producto (guía, Sección 11) | Ubicación | Estado |
|---|---|---|
| DML (≥ 50 registros por tabla principal) | `sql/dml/01_datos_prueba.sql` | ✅ |
| Vistas | `sql/views/01..04` (4 vistas) | ✅ |
| Triggers (mínimo 2) | `sql/triggers/01..03` (3 triggers) | ✅ |
| Procedimientos / funciones (mínimo 2) | `sql/procedures/01..04` (1 función + 3 procedimientos) | ✅ |
| Seguridad: 3 roles en BD | `sql/security/01_roles_privilegios.sql` | ✅ |
| 8 casos de prueba + matriz de trazabilidad | [`casos-prueba/CASOS_PRUEBA_ENTREGA3.md`](../casos-prueba/CASOS_PRUEBA_ENTREGA3.md) | ✅ 8/8 |
| Web ≈70%: módulos principales + control por rol | `web/` — ver [`AVANCE_WEB.md`](./AVANCE_WEB.md) | ✅ 7 módulos |

Ajuste de esquema: `sql/ddl/06_ajustes_entrega3.sql` agrega
`tipo_cliente.porcentaje_descuento` (RF13). El comentario del DDL original ya
decía que `TIPO_CLIENTE` centraliza el descuento, pero la columna no existía.
Se hizo con `ALTER TABLE` en un script nuevo para que el cambio quede
trazable por entrega en lugar de reescribir el script de la Entrega 2.

## 2. Datos de prueba (DML)

`sql/dml/01_datos_prueba.sql` es generado con semilla fija (reproducible) y
cumple el requisito 7 de la Sección 5:

| Tabla principal | Registros |
|---|---|
| empleado | 56 |
| usuario | 53 |
| cliente | 60 |
| producto | 55 |
| variante_producto | 165 |
| furgon | 55 |
| ingreso_mercaderia | 60 (+ 179 líneas de detalle) |
| pedido | 60 (+ 106 líneas de detalle) |
| movimiento_stock | 291 |

Los datos son **consistentes**: `stock_actual` de cada variante es exactamente
la suma de su kardex (entradas + devoluciones − salidas) y `total_pedido` es la
suma de los subtotales. La consulta de verificación está en
`casos-prueba/scripts/entrega3_casos_bd.sql` y devuelve 0 inconsistencias.

Usuarios de prueba de la app (solo ambiente local, R6):

| Usuario | Contraseña | Rol |
|---|---|---|
| `admin` | `Admin#2026` | administrador |
| `bodega` | `Bodega#2026` | bodeguero |
| `ventas` | `Ventas#2026` | vendedor |

> **Orden importa:** el DML se ejecuta antes de los triggers (INSTALL.md). Si
> los triggers ya existieran, los INSERT históricos volverían a mover el stock.

## 3. Vistas

| Vista | Regla de negocio | Requerimiento |
|---|---|---|
| `vw_stock_variantes` | Stock por variante con bandera `alerta_stock_bajo` (stock ≤ mínimo). La alerta se calcula, no se guarda (S7). | RF03, RF04 |
| `vw_pedidos_resumen` | Pedido con cliente, tipo de cliente, vendedor, líneas y pares totales. | RF14 |
| `vw_kardex` | Movimiento con variante legible, responsable y efecto con signo (+/−) sobre el stock. | RF16, RF18 |
| `vw_ingresos_detalle` | Ingreso por furgón con pares recibidos y costo total calculado. | RF09 |

## 4. Triggers

| Trigger | Evento | Regla de negocio |
|---|---|---|
| `trg_detalle_ingreso_ai` | AFTER INSERT `detalle_ingreso` | Toda mercadería recibida suma al stock y queda en el kardex como `entrada`, con el empleado que registró el ingreso como responsable (RF08, RF15). |
| `trg_detalle_pedido_bi` | BEFORE INSERT `detalle_pedido` | No se puede vender más pares de los que hay (cantidad × pares de la presentación), ni agregar líneas a un pedido que no esté `pendiente`. Rechaza con `SIGNAL 45000` y mensaje de negocio (RD03). |
| `trg_detalle_pedido_ai` | AFTER INSERT `detalle_pedido` | Descuenta los pares vendidos, registra la `salida` en el kardex y recalcula `pedido.total_pedido` (RF12, RF15). |

**¿Por qué en triggers y no en la app?** Porque la regla debe cumplirse sin
importar desde dónde se inserte (app web, Workbench, un script). Si la app
fuera la única responsable, un INSERT manual dejaría el stock desincronizado.

## 5. Función y procedimientos

| Objeto | Regla de negocio | Requerimiento |
|---|---|---|
| `fn_calcular_precio_linea(variante, presentacion, cliente)` | Precio = precio por par × pares de la presentación × (1 − descuento del tipo de cliente). El usuario nunca digita el precio. Ej.: variante de Q260/par, caja de 12, mayorista 15 % → **Q2,652.00**. | RF13 |
| `sp_crear_pedido(cliente, empleado, OUT id)` | Todo pedido nace `pendiente`, total 0, con cliente existente y vendedor con usuario activo. | RF11, RD04 |
| `sp_agregar_linea_pedido(pedido, variante, presentacion, cantidad)` | Inserta la línea con el precio de la función; los triggers validan stock, lo descuentan y recalculan el total. Una variante una sola vez por pedido. | RF11, RF12, RF13 |
| `sp_registrar_devolucion(pedido, variante, pares, empleado)` | Solo de pedidos `completado`, solo variantes compradas y nunca más pares de los vendidos. Transaccional con `EXIT HANDLER` → `ROLLBACK` + `RESIGNAL`. | RF17 |

La app web invoca `sp_crear_pedido` + `sp_agregar_linea_pedido` dentro de
**una** transacción: si una línea falla por stock, se revierte el pedido
completo (no quedan pedidos huérfanos — probado en CP3-08).

## 6. Seguridad (3 roles en MySQL)

| Privilegio | rol_administrador | rol_bodeguero | rol_vendedor |
|---|---|---|---|
| Todo el esquema | ALL | — | — |
| Catálogos / producto | ✅ | SELECT | SELECT |
| variante_producto, furgon, ingreso_mercaderia | ✅ | SELECT, INSERT, UPDATE | — (solo vista de stock) |
| detalle_ingreso | ✅ | SELECT, INSERT | — |
| movimiento_stock / vw_kardex | ✅ | SELECT | — |
| cliente, cliente_telefono | ✅ | — | SELECT, INSERT, UPDATE |
| pedido, detalle_pedido | ✅ | — | SELECT (escribe solo vía procedimientos) |
| EXECUTE sp_* / fn_* de pedidos | ✅ | — | ✅ |
| DELETE en cualquier tabla | ✅ | — | — |
| Tabla `usuario` (hash de contraseñas) | ✅ | — | — |

Decisión clave: el vendedor **no tiene INSERT** sobre `pedido` ni
`detalle_pedido`; solo puede vender ejecutando los procedimientos. Así no puede
escribir un precio a mano ni saltarse la validación de stock.

**Dos capas de seguridad:** (1) roles de MySQL para acceso directo a la BD
(usuarios `pvm_admin`, `pvm_bodega`, `pvm_ventas`); (2) control por rol en la
app (RF21), con una matriz única de permisos en `web/src/config/permisos.js`
alineada con la tabla anterior. La app se conecta con un usuario técnico
(`pavanamoon_app`) y aplica el rol del usuario en sesión.

## 7. Casos de prueba y trazabilidad

Ver [`casos-prueba/CASOS_PRUEBA_ENTREGA3.md`](../casos-prueba/CASOS_PRUEBA_ENTREGA3.md):
8 casos, 8/8 exitosos, con la matriz requerimiento → implementación → prueba.

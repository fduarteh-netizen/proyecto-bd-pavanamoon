# Casos de Prueba — Entrega 4
## Proyecto Pavanamoon

Código probado: `main`, commit `28f1176` (Lotes 1 a 5).

Hay **dos fuentes de verificación** y no se mezclan:

| Fuente | Dónde | Quién | Evidencia |
|---|---|---|---|
| **Local (L)** | Base instalada **desde cero** con el orden de `INSTALL.md`, en un entorno aislado (Linux, MySQL 8.0.46 con binlog, Node 22) | Asistente de IA, sesión del 20/10/2026 (Entrada 19 de la bitácora) | `evidencias/entrega4_*.txt`: salida sin editar, con encabezado de entorno |
| **Railway (R)** | Producción, solo con datos ficticios | Equipo | Tabla RW de la sección 4; capturas `evidencias/e4_*.png` |

Las baterías que escriben datos de prueba (CP4, INT) **no** se ejecutan en
Railway. Las de integración son destructivas y su instalador solo acepta
bases con nombre `*_prueba`.

---

## 1. Scripts y evidencias (local)

| Script | Casos | Resultado L | Salida real |
|---|---|---|---|
| Instalación `sql/` en el orden de `INSTALL.md` | — | 25 scripts sin error; 19 tablas, 6 vistas, 1 función, 4 procedimientos, 3 triggers, 6 cuentas de seguridad | [`entrega4_instalacion_desde_cero.txt`](./evidencias/entrega4_instalacion_desde_cero.txt) |
| [`scripts/entrega4_casos_bd.sql`](./scripts/entrega4_casos_bd.sql) | CP4-01 a CP4-07 | Todos como se esperaba (CP4-01c, 03, 04 y 06 fallan a propósito) | [`entrega4_casos_bd.txt`](./evidencias/entrega4_casos_bd.txt) |
| [`scripts/entrega4_casos_web.sh`](./scripts/entrega4_casos_web.sh) | CP4-08 a CP4-15 | **46 OK, 0 FALLA** | [`entrega4_casos_web.txt`](./evidencias/entrega4_casos_web.txt) |
| [`scripts/entrega4_casos_catalogos.sh`](./scripts/entrega4_casos_catalogos.sh) | CP4-16 a CP4-22 | **65 OK, 0 FALLA** | [`entrega4_casos_catalogos.txt`](./evidencias/entrega4_casos_catalogos.txt) |
| [`scripts/entrega4_seguridad.test.cjs`](./scripts/entrega4_seguridad.test.cjs) | SEG-01 a SEG-11 | **11/11** | [`entrega4_seguridad.txt`](./evidencias/entrega4_seguridad.txt) |
| [`scripts/entrega4_integracion_stock.test.cjs`](./scripts/entrega4_integracion_stock.test.cjs) | INT-01 a INT-07 | **7/7** (base `pavanamoon_prueba`) | [`entrega4_integracion_stock.txt`](./evidencias/entrega4_integracion_stock.txt) |
| [`scripts/entrega4_variantes_clientes_unit.cjs`](./scripts/entrega4_variantes_clientes_unit.cjs) | 10 unitarias | **10/10** | [`entrega4_unitarias_clientes_variantes.txt`](./evidencias/entrega4_unitarias_clientes_variantes.txt) |
| Scripts de la Entrega 3 (regresión) | CP3-01 a CP3-08 | Mismos resultados que en la Entrega 3 | [`entrega4_regresion_entrega3.txt`](./evidencias/entrega4_regresion_entrega3.txt) |

**Preparación necesaria para SEG.** El script exige los usuarios `cabrito`
(bodeguero) y `fernanflo` (vendedor), que no vienen en `sql/dml`. En la
ejecución local se crearon desde `/usuarios` como administrador, asignados a
los empleados 54 y 55, que no tenían usuario. Las contraseñas se pasaron con
`PVM_PASS_ADMIN`, `PVM_PASS_BODEGA` y `PVM_PASS_VENTAS` y no aparecen en la
evidencia.

**Locale.** `entrega3_casos_web.sh` llama a `mysql` sin fijar el charset. En
Linux sin locale UTF-8, los acentos salían corruptos en la evidencia. Se
ejecutó con `LANG=C.UTF-8`; en Windows no aplica.

---

## 2. Casos de prueba

### 2.1 Base de datos (CP4-01 a CP4-07)

| Caso | Objeto | Acción | Esperado | Obtenido (L) |
|---|---|---|---|---|
| **CP4-01** | `sp_registrar_devolucion` | Vender 3 pares; devolver 2, luego 1, luego 1 más | Las dos primeras pasan; la tercera se rechaza | ✅ Kardex: `salida 3`, `devolucion_cliente 3`; tercer intento: `Cantidad a devolver inválida…` |
| **CP4-02** | `sp_cancelar_pedido` | Cancelar un pedido pendiente de 2 líneas (2 y 4 pares) | El stock vuelve al original, 2 movimientos `cancelacion`, estado `cancelado`, las 2 líneas se conservan | ✅ 108 → 106 → 108 y 103 → 99 → 103; 2 líneas conservadas |
| **CP4-03** | `sp_cancelar_pedido` | Cancelar el mismo pedido otra vez | Rechazo | ✅ `Solo se pueden cancelar pedidos pendientes…` |
| **CP4-04** | `sp_cancelar_pedido` | Cancelar un pedido completado | Rechazo (se usa devolución) | ✅ Mismo mensaje |
| **CP4-05** | `vw_ventas_diarias`, `vw_ventas_por_modelo` | Comparar con las tablas base | Los montos y devoluciones coinciden | ✅ 156393.00 = 156393.00 = 156393.00; devueltos 9 = 9 |
| **CP4-06** | `fk_movimiento_pedido` | Borrar un pedido con kardex | `ERROR 1451`; el pedido sigue existiendo | ✅ |
| **CP4-07** | Consistencia global | stock = suma del kardex | 0 filas | ✅ 0 filas |

### 2.2 Aplicación web (CP4-08 a CP4-22)

| Caso | Qué prueba | Comprobaciones (L) |
|---|---|---|
| **CP4-08** | Módulos nuevos accesibles solo para el administrador | 9/9 |
| **CP4-09** | Empleado con 2 teléfonos (1FN), DPI duplicado, validación | 7/7 |
| **CP4-10** | Alta de usuario, inicio de sesión del nuevo usuario, contraseña hasheada | 5/5 |
| **CP4-11** | Cambio de rol y desactivación con la sesión **abierta** | 4/4 |
| **CP4-12** | El administrador no puede bloquearse a sí mismo | 4/4 |
| **CP4-13** | Borrar un empleado con usuario: mensaje de negocio, no error SQL | 5/5 |
| **CP4-14** | Cancelación de un pedido desde la web (vendedor) | 7/7 |
| **CP4-15** | Los reportes cuadran con la base de datos | 5/5 |
| **CP4-16** | Catálogos: solo administrador | 10/10 |
| **CP4-17** | Colores: alta normalizada, duplicado, validación, edición, borrado | 11/11 |
| **CP4-18** | Tallas | 8/8 |
| **CP4-19** | Categorías (`ck_categoria_nombre`) | 5/5 |
| **CP4-20** | Tipos de cliente: el descuento llega a `fn_calcular_precio_linea` | 9/9 |
| **CP4-21** | Presentaciones: protección del historial y desactivación | 15/15 |
| **CP4-22** | Inyección SQL y entradas maliciosas | 4/4 |

### 2.3 Seguridad (SEG-01 a SEG-11)

| Caso | Qué prueba | L |
|---|---|---|
| SEG-01 | El login no muestra credenciales de demostración | ✅ |
| SEG-02 | Cookie de sesión: nombre propio, `HttpOnly`, `SameSite=Lax` | ✅ |
| SEG-03 | El id de sesión cambia al iniciar sesión (sin fijación de sesión) | ✅ |
| SEG-04 | Después de cerrar sesión, la cookie ya no da acceso | ✅ |
| SEG-05 | Cabeceras de seguridad, sin `X-Powered-By` | ✅ |
| SEG-06 | Un POST desde otro sitio se rechaza aunque haya sesión (CSRF) | ✅ |
| SEG-07 | Tras 5 fallos responde 429; otro usuario sigue entrando | ✅ |
| SEG-08 | Matriz de autorización: cada módulo × cada rol, y sin sesión | ✅ |
| SEG-09 | En producción la app no arranca con un `SESSION_SECRET` débil | ✅ |
| SEG-10 | En producción: cookie `Secure` detrás de HTTPS y CSRF estricto | ✅ |
| SEG-11 | El mensaje de deadlock/timeout no afirma que "no se guardó nada" | ✅ |

### 2.4 Concurrencia (INT-01 a INT-07, base `pavanamoon_prueba`)

| Caso | Qué prueba | L |
|---|---|---|
| INT-01 | Una variante nueva inicia en 0; el ingreso suma stock y kardex | ✅ |
| INT-02 | Cuatro ingresos simultáneos de la misma variante: todos se aplican, sin deadlock | ✅ |
| INT-03 | Seis pedidos simultáneos por más stock del que hay: no se sobrevende | ✅ |
| INT-04 | Pedidos de varias líneas en orden opuesto (A,B contra B,A): sin deadlock | ✅ |
| INT-05 | Una devolución parcial y luego dos simultáneas por el resto: solo una pasa | ✅ |
| INT-06 | Dos cancelaciones simultáneas del mismo pedido: el stock vuelve una sola vez | ✅ |
| INT-07 | Invariante stock = suma del kardex (variantes de prueba y toda la base) | ✅ |

### 2.5 Unitarias (clientes y variantes)

10/10 (L): acepta 2 números y elimina duplicados; rechaza más de 5 teléfonos y
formatos inválidos; rechaza IDs no decimales y stock inválido; con stock solo
cambia el stock mínimo; no cambia la talla si hay stock; crear un cliente
inserta 2 teléfonos en una transacción; rollback si falla un teléfono; no se
elimina una variante con movimientos aunque su stock sea 0; el SKU se deriva y
el stock inicial es 0; editar un cliente actualiza los teléfonos en una sola
transacción.

---

## 3. Matriz de trazabilidad (requerimiento → implementación → prueba)

Solo requerimientos con cambios o pruebas nuevas en la Entrega 4. El resto se
mantiene como en [`CASOS_PRUEBA_ENTREGA3.md`](./CASOS_PRUEBA_ENTREGA3.md) y
se comprobó por regresión.

| Requerimiento | Implementación BD | Implementación web | Prueba L | Prueba R |
|---|---|---|---|---|
| RF02, RD02 — Variantes | `variante_producto`, `uq_variante_combinacion` | `/inventario` (edición protegida) | Unitarias 3–5, 8, 9 | — |
| RF01, RF10 — Catálogos de apoyo | `categoria`, `talla`, `color`, `tipo_cliente`, `presentacion_venta` | `/catalogos` | CP4-16 a CP4-22 | — |
| RF10 — Clientes con varios teléfonos (1FN) | `cliente_telefono` | `/clientes` | Unitarias 1, 2, 6, 7, 10 | — |
| RF11, RD04 — Pedido válido | `sp_crear_pedido`, `sp_agregar_linea_pedido` | `/pedidos/nuevo` | CP3-03, CP3-08 (regresión) | RW-03 |
| RF11, RF15 — Cancelación | `sp_cancelar_pedido`, `'cancelacion'`, `fk_movimiento_pedido` | `/pedidos/:id/cancelar` | CP4-02 a CP4-04, CP4-14, INT-06 | RW-05 |
| RF12, RF13 — Total y descuento mayorista | `fn_calcular_precio_linea`, `trg_detalle_pedido_ai` | precio calculado por la BD | CP4-20, CP3-02, CP3-03 | RW-03 |
| RF14 — Historial por cliente | `vw_pedidos_resumen` | `/pedidos?cliente=` | CP3-08 (regresión) | RW-02 (filtro sin error, reportado por el equipo el 25/10) |
| RF15, RF16 — Kardex ligado al pedido | `movimiento_stock.pedido_id`, `vw_kardex` | `/kardex` | CP4-01, CP4-02, CP4-06, CP4-07 | RW-04 |
| RF17 — Devolución acumulada | `sp_registrar_devolucion` | `/pedidos/:id` | CP4-01, INT-05 | RW-06 |
| RD03 — Sin stock negativo ni sobreventa | `trg_detalle_pedido_bi` (`FOR UPDATE`), `ck_variante_stock_actual` | mensaje de negocio | INT-03, INT-04, CP3-04 | — |
| Reportes de ventas (sin RF propio en la Entrega 1) | `vw_ventas_diarias`, `vw_ventas_por_modelo` | `/reportes` | CP4-05, CP4-15 | RW-07 |
| RF19, RD08, RD09 — Gestión de usuarios y roles | `usuario`, `rol`, `uq_usuario_username` | `/usuarios` | CP4-10 a CP4-12 | RW-08 |
| RD04 — Empleados | `empleado`, `empleado_telefono` | `/empleados` | CP4-09, CP4-13 | — |
| RF20 — Autenticación segura | bcrypt | `/login`, `seguridad.js` | SEG-01 a SEG-04, SEG-07, SEG-09 | RW-01 |
| RF21 — Operaciones por rol | `GRANT` (`sql/security`) | `permisos.js`, `requireRole` | SEG-08, CP4-08, CP4-16, CP3-06, CP3-07 | RW-01 |
| Seguridad web (CSRF, cabeceras) | — | `seguridad.js` | SEG-05, SEG-06, SEG-10 | — |

---

## 4. Verificación en Railway (R)

### 4.1 Ya realizado (reportado por el equipo, 25/10/2026)

| Verificación | Resultado reportado |
|---|---|
| `railway_verificar.sql` después de `railway_sincronizar_con_repo.sql` | `IGUAL AL REPOSITORIO` (19 / 6 / 1 / 4 / 3) |
| `/pedidos` → Historial por cliente | Sin HTTP 500 |
| Inicio de sesión y navegación por módulos | Sin errores visibles |
| Contraseña del administrador | Cambiada |
| Acceso público de MySQL | Cerrado |

_(Agregar las capturas de `railway_verificar.sql` y del filtro como
`evidencias/e4_01_railway_verificar.png` y `e4_02_filtro_cliente.png`.)_

### 4.2 Prueba manual con datos ficticios (pendiente)

> **Flujos del manual de usuario, verificados localmente (25/10/2026).** Las
> 26 capturas de [`MANUAL_USUARIO.md`](../entrega-4/MANUAL_USUARIO.md) se
> tomaron recorriendo cada flujo en la app instalada desde cero: ingreso
> (stock +24 y kardex `entrada`), pedido mayorista de 1 caja (Q2,652.00 =
> 260 × 12 × 0.85), completar, devolución de 2 pares, cancelación con
> reintegro, rechazo por stock insuficiente, historial por cliente, reportes
> y 403 del vendedor en Furgones. Todo respondió como describe el manual.
> Falta repetir los mismos flujos **en Railway** (tabla siguiente).

Se hace en la aplicación pública. Use clientes y productos **ficticios** y
anote el resultado real; deje "—" si no se hizo.

| Caso | Pasos | Esperado | Obtenido | Fecha / quién | Captura |
|---|---|---|---|---|---|
| RW-01 | Iniciar sesión como administrador, bodeguero y vendedor; como vendedor, escribir a mano `/furgones` | Menú distinto por rol; `/furgones` da 403 al vendedor | | | `e4_03_*.png` |
| RW-02 | `/pedidos` → Historial por cliente → filtrar | Solo los pedidos de ese cliente, con Vendedor y Pares | | | `e4_02_*.png` |
| RW-03 | Vendedor: pedido para un cliente **mayorista**, 1 caja de una variante con stock | Total = precio por par × 12 × (1 − descuento mayorista) | | | `e4_04_*.png` |
| RW-04 | `/inventario` y `/kardex` de esa variante | Stock −12; movimiento `salida 12` con el pedido | | | `e4_05_*.png` |
| RW-05 | Crear otro pedido pendiente y cancelarlo desde el detalle | Estado `cancelado`; el stock vuelve; kardex `cancelacion` | | | `e4_06_*.png` |
| RW-06 | Completar el pedido de RW-03 y devolver 2 pares; intentar devolver más de lo vendido | La primera devolución pasa; la segunda se rechaza con mensaje | | | `e4_07_*.png` |
| RW-07 | `/reportes` para el día de hoy | Aparece la venta completada de RW-03 (si la venta fue después de las 18:00, puede salir en el día siguiente: el reporte agrupa por fecha UTC) | | | `e4_08_*.png` |
| RW-08 | `/usuarios`: crear un usuario ficticio, iniciar sesión con él y desactivarlo | El usuario desactivado ya no puede entrar | | | `e4_09_*.png` |

---

## 5. Re-ejecución por el equipo (pendiente)

Las evidencias `entrega4_*.txt` las generó un asistente de IA en un entorno
aislado. Un integrante debe repetir al menos la instalación desde cero,
CP4-01 a CP4-22 y SEG-01 a SEG-11 en su máquina, siguiendo `INSTALL.md`
(sección 4.3 para INT), y anotar aquí el resultado.

| Batería | Resultado del equipo | Fecha | Integrante |
|---|---|---|---|
| Instalación desde cero | | | |
| CP4-01 a CP4-07 | | | |
| CP4-08 a CP4-15 | | | |
| CP4-16 a CP4-22 | | | |
| SEG-01 a SEG-11 | | | |
| INT-01 a INT-07 | | | |

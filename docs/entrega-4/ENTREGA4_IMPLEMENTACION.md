# Entrega 4 — Integración, despliegue y defensa
## Proyecto Pavanamoon

Este documento resume lo implementado en la Entrega 4: cambios de base de
datos, módulos web nuevos, endurecimiento de seguridad y concurrencia,
despliegue en Railway y resultado de las pruebas. Los manuales técnico y de
usuario y el diagrama actualizado los preparan otros integrantes y se
enlazarán aquí cuando se integren.

**Código evaluado:** rama `main`, commit `28f1176` (PR #2, Lotes 1 a 5).

> **Cómo leer las verificaciones.** Este documento distingue dos fuentes:
> - **Local:** ejecutado desde cero en un entorno aislado (MySQL 8.0.46,
>   Node 22) con los scripts de `docs/casos-prueba/scripts/`; salidas en
>   `docs/casos-prueba/evidencias/entrega4_*.txt`. Falta la re-ejecución
>   por el equipo en su propia máquina.
> - **Railway:** acciones realizadas y confirmadas por el equipo en
>   producción. No hay salidas de consola de Railway en el repositorio salvo
>   las que el equipo agregue (ver sección 8).

## 1. Resumen de productos entregados

| Producto | Ubicación | Estado |
|---|---|---|
| Ajuste de esquema: referencia del pedido en el kardex | `sql/ddl/07_ajustes_entrega4.sql` | ✅ |
| Vistas de reportes de ventas | `sql/views/05_vw_ventas_diarias.sql`, `06_vw_ventas_por_modelo.sql` | ✅ |
| Cancelación de pedidos | `sql/procedures/05_sp_cancelar_pedido.sql` | ✅ |
| Devolución acumulada (no devolver dos veces lo mismo) | `sql/procedures/04_sp_registrar_devolucion.sql` | ✅ |
| Concurrencia sin sobreventa ni deadlocks (`FOR UPDATE`) | `sql/triggers/02_...`, `sql/procedures/03_...`, `04_...` | ✅ |
| Privilegios de la Entrega 4 | `sql/security/02_privilegios_entrega4.sql` | ✅ |
| Web: Reportes, Empleados, Usuarios, Catálogos | `web/src/routes/`, `web/views/` | ✅ |
| Web: cancelación, teléfonos de clientes, edición de variantes | `web/src/routes/pedidoRoutes.js`, `clienteRoutes.js`, `inventarioRoutes.js` | ✅ |
| Endurecimiento de seguridad web (Lote 5) | `web/src/middleware/seguridad.js` | ✅ |
| Casos de prueba + matriz de trazabilidad | [`../casos-prueba/CASOS_PRUEBA_ENTREGA4.md`](../casos-prueba/CASOS_PRUEBA_ENTREGA4.md) | ✅ local · ⏳ Railway |
| Despliegue público | https://grand-acceptance-production-0ac1.up.railway.app | ✅ |
| Informe final (consolida las 4 entregas) | [`ENTREGA4_INFORME_FINAL.md`](./ENTREGA4_INFORME_FINAL.md) | ✅ |
| Declaración de integridad | [`ENTREGA4_DECLARACION_INTEGRIDAD.md`](./ENTREGA4_DECLARACION_INTEGRIDAD.md) | ⏳ firmas |
| Guía de defensa oral | [`ENTREGA4_GUIA_DEFENSA.md`](./ENTREGA4_GUIA_DEFENSA.md) | ✅ |
| Manual técnico | [`ENTREGA4_MANUAL_TECNICO.md`](./ENTREGA4_MANUAL_TECNICO.md) | ✅ |
| Manual de usuario (26 capturas reales de los flujos) | [`ENTREGA4_MANUAL_USUARIO.md`](./ENTREGA4_MANUAL_USUARIO.md) | ✅ |
| Diagrama ER (Chen): relación "origina" y `porcentaje_descuento` | `docs/diagramas/Pavanamoon_er_chen_corregido.*` | ✅ |
| Modelo relacional (Workbench): `pedido_id`, `fk_movimiento_pedido`, `cancelacion`, `porcentaje_descuento` | `docs/diagramas/Modelo_Entidad_R_Pavanamoon.mwb` + `Modelo_Entidad_Relacion.png` y `Modelo_Entidad_R_Pavanamoon.pdf` | ✅ (PNG/PDF dibujados a partir del `.mwb`, 27/10/2026) |
| Certificación de la Entrega 4 | [`../certificaciones/CERTIFICACION_ENTREGA_4.md`](../certificaciones/CERTIFICACION_ENTREGA_4.md) | ⏳ firmas |

Objetos de base de datos tras la Entrega 4: **19 tablas, 6 vistas, 1 función,
4 procedimientos y 3 triggers** (`entrega4_instalacion_desde_cero.txt`).

## 2. Base de datos

### 2.1 Cambio de esquema (`sql/ddl/07_ajustes_entrega4.sql`)

`movimiento_stock` recibe `pedido_id INT NULL` con la FK
`fk_movimiento_pedido` (`ON DELETE RESTRICT`) y el valor `'cancelacion'` en
`tipo_movimiento`. Así cada salida, devolución o cancelación queda ligada al
pedido que la originó, lo que permite:

- calcular cuánto se puede devolver todavía de una línea (RF17);
- reintegrar exactamente lo vendido al cancelar (RF11, RF15);
- impedir borrar un pedido que ya tiene kardex (auditoría, RF16; CP4-06).

Se hizo con `ALTER TABLE` en un script nuevo para que el cambio sea trazable
por entrega, igual que `06_ajustes_entrega3.sql`.

### 2.2 Objetos nuevos o modificados

| Objeto | Cambio | Regla de negocio | Requerimiento |
|---|---|---|---|
| `vw_ventas_diarias` | Nueva | Ventas por día; solo cuentan pedidos `completado` | Reportes de ventas |
| `vw_ventas_por_modelo` | Nueva | Pares vendidos, devueltos y netos por modelo, incluidos modelos sin ventas | Reportes de ventas |
| `vw_kardex` | Modificada | Expone `pedido_id`; `cancelacion` suma al stock | RF16, RF18 |
| `sp_cancelar_pedido` | Nuevo | Solo pedidos `pendiente`; reintegra cada línea como `cancelacion`; conserva el detalle; atómico | RF11, RF15 |
| `sp_registrar_devolucion` | Modificado | Disponible = vendido − ya devuelto (antes se podía devolver la misma línea varias veces) | RF17 |
| `trg_detalle_pedido_ai` | Modificado | La salida guarda `pedido_id` | RF15, RF16 |
| `trg_detalle_pedido_bi` | Modificado (Lote 5) | Lee el stock con `FOR UPDATE` | RD03 |
| `sp_agregar_linea_pedido` | Modificado (Lote 5) | Bloquea la variante al inicio para serializar pedidos simultáneos | RD03 |
| `rol_vendedor` | `GRANT EXECUTE` sobre `sp_cancelar_pedido` | El vendedor cancela solo por procedimiento | RF21 |

Detalle por objeto: `sql/views/README.md`, `sql/procedures/README.md` y
`sql/triggers/README.md`.

### 2.3 Concurrencia (Lote 5)

El riesgo era que dos pedidos simultáneos leyeran el mismo stock y ambos
pasaran la validación (sobreventa), o que pedidos con varias líneas en orden
opuesto se bloquearan mutuamente (deadlock). La solución bloquea la fila de
la variante (`SELECT … FOR UPDATE`) antes de validar; las devoluciones
bloquean la fila del pedido. Probado localmente con INT-02 a INT-07: sin
sobreventa, sin deadlocks y con stock = suma del kardex en toda la base.

## 3. Aplicación web

### 3.1 Módulos nuevos

| Módulo | Ruta | Roles | Qué hace |
|---|---|---|---|
| Reportes | `/reportes` | administrador | Ventas por periodo (día/mes) y modelos más y menos vendidos, desde `vw_ventas_diarias` y `vw_ventas_por_modelo` |
| Empleados | `/empleados` | administrador | Alta y edición con varios teléfonos (1FN); el DPI duplicado o el borrado con usuario dan un mensaje de negocio |
| Usuarios | `/usuarios` | administrador | Alta con contraseña bcrypt, cambio de rol, activación y cambio de contraseña. Un administrador no puede desactivarse ni quitarse el rol, y siempre queda al menos uno activo |
| Catálogos | `/catalogos` | administrador | Categorías, tallas, colores, tipos de cliente (el descuento llega a `fn_calcular_precio_linea`) y presentaciones protegidas si tienen historial |

Además: cancelación de pedidos pendientes desde el detalle (vendedor y
administrador), hasta 5 teléfonos por cliente en una transacción, y edición
de variantes (con stock solo se puede cambiar el stock mínimo).

La matriz de permisos sigue centralizada en `web/src/config/permisos.js`: los
4 módulos nuevos son solo para el administrador. Verificado con SEG-08,
CP4-08 y CP4-16.

### 3.2 Seguridad web (Lote 5, `web/src/middleware/seguridad.js`)

| Control | Detalle | Prueba |
|---|---|---|
| Sin credenciales de demostración en el login | Se retiraron del formulario | SEG-01 |
| Cookie de sesión | Nombre propio, `HttpOnly`, `SameSite=Lax`, `Secure` en producción | SEG-02, SEG-10 |
| Fijación de sesión | El id de sesión se regenera al iniciar sesión | SEG-03 |
| Cierre de sesión | La cookie anterior deja de dar acceso | SEG-04 |
| Cabeceras | `nosniff`, anti-iframe, `Referrer-Policy`, `no-store`; sin `X-Powered-By` | SEG-05 |
| CSRF | `SameSite` + verificación de `Origin`/`Referer`; en producción se rechaza un POST sin ellos | SEG-06, SEG-10 |
| Fuerza bruta | Bloqueo temporal por usuario+IP y por IP (HTTP 429) | SEG-07 |
| Secreto de sesión | En producción la app no arranca sin `SESSION_SECRET` de 32+ caracteres distinto del ejemplo | SEG-09 |
| Errores de concurrencia | El mensaje de deadlock/timeout no afirma que "no se guardó nada" | SEG-11 |
| Dependencias | `npm audit` en 0 (commit `ece0f84`) | — |

Límite documentado en el código: las sesiones usan `MemoryStore`, así que la
app debe correr con **una sola instancia** (réplicas = 1 en Railway).

## 4. Despliegue en Railway

### 4.1 Configuración

| Elemento | Valor |
|---|---|
| Aplicación | Node.js + Express + EJS, directorio raíz `/web`, despliegue automático desde `main` |
| Base de datos | Servicio MySQL 8 de Railway, esquema `railway`, conexión **privada** desde la app |
| URL pública | https://grand-acceptance-production-0ac1.up.railway.app |
| Acceso público a MySQL | Solo temporal, para Workbench durante la instalación y la sincronización; **cerrado** al terminar |
| Credenciales | Solo en variables de Railway; ninguna en el repositorio |

### 4.2 Incidente: base instalada desde una exportación antigua

La base `railway` se instaló el 20/10/2026 a partir de un dump estructural de
la base local de un integrante, no desde `sql/`. Ese dump conservaba objetos
de versiones anteriores: **9 vistas, 2 funciones y 9 procedimientos**, frente
a 6, 1 y 4 en el repositorio.

Consecuencias comprobadas localmente sobre una copia del mismo paquete:

- `vw_pedidos_resumen` era la versión antigua, sin `cliente_id`, `vendedor` ni
  `pares_totales`. El filtro **Historial por cliente (RF14)** respondía HTTP
  500 y las columnas Vendedor y Pares salían vacías.
- `sp_crear_pedido` era la versión antigua: no validaba el cliente ni el
  usuario activo del vendedor.
- Había 10 objetos que no existen en el repositorio, entre ellos
  `sp_cambiar_estado_pedido`, que cancela un pedido sin devolver el stock.

**Corrección:** `docs/entrega-4/despliegue-railway/railway_sincronizar_con_repo.sql`.
Elimina los 10 objetos ajenos, crea `trg_detalle_ingreso_ai` y reemplaza
`vw_pedidos_resumen` y `sp_crear_pedido` con copias exactas de `sql/`. **No
toca tablas ni datos.** Antes de usarlo en producción se probó en una base
aislada: sincronización, repetición, reversión, interrupción a mitad,
restauración del respaldo y aplicación conectada (ver
`despliegue-railway/pruebas_aisladas_sincronizacion.txt` y
`GUIA_SINCRONIZACION_RAILWAY.md`).

**Aplicado en Railway por el equipo el 25/10/2026** (confirmado por el equipo):

| Verificación en Railway | Resultado reportado |
|---|---|
| `railway_verificar.sql` después de sincronizar | `IGUAL AL REPOSITORIO`: 19 tablas, 6 vistas, 1 función, 4 procedimientos, 3 triggers |
| Filtro Historial por cliente en `/pedidos` | Funciona, sin HTTP 500 |
| Acceso público de MySQL | Cerrado de nuevo |
| Contraseña del administrador | Cambiada (la anterior se había compartido en una conversación) |

Evidencia del panel de Railway (27/10/2026): servicios en línea, despliegue
desde GitHub con 1 réplica, MySQL sin acceso público y la base con 19 tablas
y las 6 vistas del repositorio (`docs/casos-prueba/evidencias/e4_railway_01`
a `04`; detalle en `CASOS_PRUEBA_ENTREGA4.md`, sección 4.1).

**Lección:** una base de producción se instala desde los scripts versionados,
no desde un dump de una base de desarrollo, y después se compara con el
repositorio (`railway_verificar.sql`).

### 4.3 Diferencias con la instalación local

| Tema | Local (`INSTALL.md`) | Railway |
|---|---|---|
| Nombre del esquema | `pavanamoon` | `railway` |
| Usuario de la app | `pavanamoon_app` (privilegios mínimos) | Cuenta del servicio MySQL de Railway |
| Roles `pvm_*` / `rol_*` (`sql/security`) | Instalados y probados (CP3-06, CP3-07) | No instalados: el esquema se llama distinto y el acceso a MySQL es solo privado. Se demuestran en local |
| Datos | DML de prueba (≥ 50 registros por tabla) | Datos ficticios de demostración |
| Zona horaria | La de la máquina | UTC en el servidor; las pantallas muestran hora de Guatemala desde el PR #4 (sección 7) |

## 5. Pruebas

Detalle, matriz de trazabilidad y evidencias:
[`../casos-prueba/CASOS_PRUEBA_ENTREGA4.md`](../casos-prueba/CASOS_PRUEBA_ENTREGA4.md).

| Batería | Resultado local | En Railway |
|---|---|---|
| Instalación desde cero (25 scripts) | Sin errores | No aplica |
| CP4-01 a CP4-07 (SQL) | Todos como se esperaba (4 fallos intencionales) | No (escriben datos de prueba) |
| CP4-08 a CP4-15 (web) | 46/46 comprobaciones | No |
| CP4-16 a CP4-22 (catálogos) | 65/65 comprobaciones | No |
| SEG-01 a SEG-11 (seguridad) | 11/11 | No |
| INT-01 a INT-07 (concurrencia, base `pavanamoon_prueba`) | 7/7 | **Nunca** (son destructivas) |
| Unitarias de clientes y variantes | 10/10 | No aplica |
| Regresión de la Entrega 3 (CP3-01 a CP3-08) | Correcta | No |
| Prueba manual con datos ficticios (RW-01 a RW-08) | — | ⏳ Pendiente de registrar |

## 6. Historial de la Entrega 4 en Git

| Commit | Fecha | Contenido |
|---|---|---|
| `cb63d67` | 17/10/2026 | Lotes 1 y 2: DDL 07, cancelación, devolución acumulada, vistas de reportes, privilegios, módulos Empleados, Usuarios y Reportes, casos CP4-01 a CP4-15; limpieza de marcas de conflicto en documentos de las Entregas 1 y 2 |
| `5abeb76` | 19/10/2026 | Catálogos, variantes y teléfonos de clientes; casos CP4-16 a CP4-22 y pruebas unitarias |
| `ece0f84` | 19/10/2026 | Dependencias corregidas según `npm audit` |
| `246f4bc` | 20/10/2026 | Lote 5: seguridad web, concurrencia (`FOR UPDATE`), pruebas SEG e INT |
| `28f1176` | 20/10/2026 | Merge del PR #2 en `main` |
| `f9cf7a7` / `8dfedfa` | 27/10/2026 | PR #4: botón Cerrar sesión visible y fechas en hora de Guatemala. Cambio de presentación posterior a las pruebas del 20 al 25/10 |

## 7. Limitaciones conocidas y pendientes

- **Zona horaria: corregida en pantalla con el PR #4 (27/10/2026, commit
  `f9cf7a7`).** El servidor de Railway guarda las fechas en UTC. La app ahora
  las lee como UTC (`timezone: 'Z'` en `web/src/config/db.js`) y las muestra
  en hora de Guatemala (`timeZone: 'America/Guatemala'` en las vistas).
  Queda pendiente:
  - `vw_ventas_diarias` agrupa por la fecha UTC, así que en Reportes una venta
    hecha después de las 18:00 cuenta para el día siguiente;
  - en una instalación local con MySQL en hora de Guatemala, las horas se ven
    6 horas antes. Se evita configurando MySQL en UTC
    (`default-time-zone='+00:00'`).
- **Una sola instancia** por `MemoryStore` (sección 3.2).
- **`entrega4_seguridad.test.cjs`** exige los usuarios `cabrito` (bodeguero) y
  `fernanflo` (vendedor), que no vienen en `sql/dml`. En una instalación
  limpia hay que crearlos desde `/usuarios`. Falta documentarlo en
  `INSTALL.md`.
- **`INSTALL.md`** aún no tiene una sección de despliegue en Railway.
- **El encabezado de `entrega4_casos_web.sh`** dice "CP4-08 a CP4-14", pero el
  script también ejecuta CP4-15.

## 8. Pendiente para cerrar la entrega

Ya hecho el 27/10/2026: certificación y declaración de integridad
confirmadas por los cuatro, merge del PR #3 en `main` y etiqueta `entrega-4`.

Queda pendiente (fecha de entrega y defensa: **03/11/2026**, sección 13 de la guía):

1. Prueba manual en Railway con datos ficticios (RW-01 a RW-08 en
   `CASOS_PRUEBA_ENTREGA4.md`), siguiendo los flujos del manual de usuario
   (criterio "flujos del manual verificados"), con capturas en
   `docs/casos-prueba/evidencias/e4_*.png`.
2. Opcional: abrir `Modelo_Entidad_R_Pavanamoon.mwb` en Workbench para
   confirmar que abre. El PNG y el PDF del modelo relacional ya están
   actualizados.
3. Preparar la defensa oral grupal e individual con `ENTREGA4_GUIA_DEFENSA.md`.

## 9. Cumplimiento de la guía del proyecto

Revisión punto por punto contra *Proyecto – Base de datos* (guía del curso).
Las cifras se midieron el 27/10/2026 sobre `main` instalado desde cero.

### 9.1 Requisitos mínimos (sección 5)

| # | Requisito | Cumple | Evidencia |
|---|---|---|---|
| 1 | ≥ 8 entidades principales | ✅ | 17 tablas no asociativas (19 en total) |
| 2 | ≥ 2 relaciones N:M resueltas | ✅ | `detalle_ingreso` (ingreso ↔ variante) y `detalle_pedido` (pedido ↔ variante) |
| 3 | 3FN demostrada con ejemplo | ✅ | `docs/entrega-2/ENTREGA2_DISENO_LOGICO.md`, sección 3 |
| 4 | ≥ 15 restricciones explícitas | ✅ | 65 restricciones con nombre (19 PK, 21 FK, 13 UNIQUE, 12 CHECK) y 52 columnas `NOT NULL` |
| 5 | ≥ 2 triggers y ≥ 2 procedimientos o funciones | ✅ | 3 triggers, 4 procedimientos y 1 función, con su regla de negocio (`sql/*/README.md`) |
| 6 | ≥ 3 roles con privilegios diferenciados | ✅ | `rol_administrador`, `rol_bodeguero`, `rol_vendedor` (`sql/security/`, CP3-06 y CP3-07) |
| 7 | ≥ 50 registros por tabla principal | ✅ | `sql/dml/01_datos_prueba.sql` (Entrega 3). Los catálogos de referencia, como tipos de cliente o presentaciones, tienen solo los valores que existen en el negocio |

### 9.2 Estándares del repositorio (6.1)

| # | Estándar | Cumple | Evidencia |
|---|---|---|---|
| R1 | Estructura de la sección 7 | ✅ | En la raíz: `README.md`, `.gitignore`, `.env.example`, `INSTALL.md`, `docs/` (entrega-1 a entrega-4, diagramas, certificaciones, bitacora-ia, casos-prueba), `sql/` (ddl, dml, views, triggers, procedures, security) y `web/` |
| R2 | README | ✅ | Nombre, integrantes, SGBD, instalación y enlaces (incluida la app publicada) |
| R3 | Commits descriptivos | ✅ | La mayoría usa el formato `tipo(ámbito): descripción` (por ejemplo, `feat(entrega4): …`, `docs(sql): …`) |
| R4 | Participación visible | ✅ | Los cuatro integrantes tienen commits propios en `main` |
| R5 | Etiquetas por entrega | ✅ | `entrega-1`, `entrega-2`, `entrega-3` y `entrega-4` |
| R6 | Sin credenciales | ✅ | Ningún `.env` versionado; hay `.env.example` y `web/.env.example`; la contraseña de producción se cambió |
| R7 | `.gitignore` | ✅ | Excluye `node_modules/`, `.env`, `*.env` y registros (logs) |
| R8 | Acceso del catedrático | ✅ | Repositorio público |

### 9.3 Estándares de código de aplicación (6.3)

| # | Estándar | Cumple | Evidencia en el código |
|---|---|---|---|
| A1 | Separación de capas | ✅ | La conexión está en `web/src/config/db.js` y el SQL solo en `web/src/models/`. Ninguna ruta ni vista accede a la base directamente; la interfaz está en `web/views/` (EJS) |
| A2 | Manejo de errores | ✅ | `web/src/middleware/errorHandler.js` traduce los errores de MySQL (duplicado, FK, deadlock, timeout) a mensajes comprensibles. Solo se muestra el texto de los `SIGNAL 45000`, que son mensajes de negocio escritos por el equipo (por ejemplo, "Stock insuficiente…"). Ninguna pantalla muestra errores SQL sin traducir |
| A3 | Validación de entrada | ✅ | `web/src/utils/validate.js` y `validateCatalogo.js` validan tipos, campos requeridos y formatos (NIT, DPI de 13 dígitos, teléfonos, IDs enteros, precios) antes de llamar al modelo (CP4-09, CP4-17 a CP4-21) |
| A4 | Consultas parametrizadas | ✅ | Todos los valores van con `?` en `mysql2`. El único identificador dinámico (`DELETE FROM ${def.tabla}` en `catalogoAdminModel.js`) sale de la lista blanca fija `CATALOGOS`, nunca de la entrada del usuario. La inyección SQL se prueba en CP4-22 |
| A5 | Código legible | ✅ | Un router y un modelo por módulo, con nombres descriptivos (`listarDisponibles`, `registrarDevolucion`…), y una función por operación |
| A6 | Comentarios en funciones que acceden a la BD | ✅ | 78 de 78 funciones de `web/src/models/` comentadas. El 27/10/2026 se agregaron 50 comentarios de una línea, **sin ningún otro cambio en el código**; después se repitieron las pruebas (unitarias 10/10, web 46/46, catálogos 65/65, CP4-01 a CP4-07 correctos) |

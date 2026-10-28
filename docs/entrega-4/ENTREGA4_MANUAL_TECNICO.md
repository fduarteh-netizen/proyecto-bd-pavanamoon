# Manual Técnico — Pavanamoon
## Sistema de Gestión de Inventario y Distribución de Calzado

Este manual es para quien instala, mantiene o amplía el sistema. Para
instalar paso a paso se remite a [`INSTALL.md`](../../INSTALL.md), que es la
referencia y no se repite aquí. El uso funcional está en el
[Manual de Usuario](./ENTREGA4_MANUAL_USUARIO.md).

**Versión documentada:** `main` `28f1176` (Entrega 4), más el PR #4
(27/10/2026): hora de Guatemala en pantalla y botón Cerrar sesión visible.

## 1. Arquitectura

```
Navegador ──HTTPS──▶ Express (web/server.js)
                      ├─ middleware: seguridad.js → sesión → auth.js (rol)
                      ├─ routes/   (una por módulo; validan la entrada)
                      ├─ models/   (SQL parametrizado con mysql2)
                      └─ views/    (EJS, HTML del servidor)
                                │ pool de conexiones (src/config/db.js)
                                ▼
                     MySQL 8 — esquema pavanamoon (local) / railway (producción)
                     tablas · vistas · triggers · función · procedimientos · roles
```

**Principio de diseño:** las reglas que protegen el inventario están **en la
base de datos**, no en la app: el stock con triggers, el precio con una
función, los pedidos, devoluciones y cancelaciones con procedimientos, y la
integridad con FK, `CHECK` y `UNIQUE`. La app valida la entrada y traduce
los errores de la base a mensajes de negocio (`errorHandler.js`).

### 1.1 Estructura de `web/`

| Ruta | Contenido |
|---|---|
| `server.js` | Arranque: valida la configuración, monta middleware, rutas y manejo de errores; escucha en `WEB_PORT` |
| `src/config/db.js` | Pool `mysql2` a partir de las variables `DB_*` |
| `src/config/permisos.js` | **Única** matriz de módulos × roles: la usan el menú y la autorización |
| `src/middleware/seguridad.js` | Cookie de sesión, cabeceras, verificación de origen (CSRF), límite de intentos de login, validación de `SESSION_SECRET` |
| `src/middleware/auth.js` | `requireLogin` y `requireRole`; responde 403 fuera del rol |
| `src/middleware/errorHandler.js` | Traduce `SIGNAL 45000`, FK (`ER_ROW_IS_REFERENCED_2`), duplicados, deadlock y timeout |
| `src/routes/*.js` | 12 routers: auth, productos, inventario, furgones, ingresos, clientes, pedidos, kardex, reportes, empleados, usuarios, catálogos |
| `src/models/*.js` | Acceso a datos, solo con `?` (consultas parametrizadas) |
| `src/utils/validate*.js` | Validación de formularios |
| `views/`, `public/css/` | Plantillas EJS y estilos |

**Dependencias** (`package.json`): `express`, `express-session`, `ejs`,
`mysql2`, `bcryptjs`, `dotenv` y `method-override`. `npm audit` está en 0.

## 2. Requisitos

| Componente | Versión |
|---|---|
| MySQL | 8.0 o superior (probado con 8.0.46; binlog activo como en Railway) |
| Node.js | 18 o superior (probado con 22) |
| Cliente | MySQL Workbench 8 (opcional) |

## 3. Instalación y configuración

1. **Base de datos:** ejecute los scripts de `sql/` en el orden de
   `INSTALL.md`: `ddl` → `dml` → `views` → `triggers` → `procedures` →
   `security`. Resultado: 19 tablas, 6 vistas, 1 función, 4 procedimientos y
   3 triggers.
2. **Usuario de la aplicación:** `pavanamoon_app` con `SELECT, INSERT,
   UPDATE, DELETE, EXECUTE` sobre el esquema. **Nunca `root`** en local
   (`INSTALL.md`, paso 3).
3. **App:** en `web/`, ejecute `npm install`, copie `.env.example` a `.env`,
   complételo y ejecute `npm start`.

### 3.1 Variables de entorno (`web/.env`)

| Variable | Uso | Valor en producción |
|---|---|---|
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Conexión a MySQL | Las del servicio MySQL de Railway (red privada) |
| `WEB_PORT` | Puerto HTTP (3000 por defecto) | El del dominio público configurado en Railway |
| `NODE_ENV` | `production` activa la cookie `Secure`, el CSRF estricto y la validación del secreto | `production` |
| `SESSION_SECRET` | Firma de la sesión; en producción debe tener **32+ caracteres** y no ser el del ejemplo, o la app no arranca | Aleatorio, solo en Railway |
| `TRUST_PROXY` | `1` detrás del proxy HTTPS de Railway | `1` |
| `ORIGENES_PERMITIDOS` | Orígenes extra aceptados por la verificación CSRF | Vacío |
| `LOGIN_MAX_INTENTOS`, `LOGIN_MAX_INTENTOS_IP`, `LOGIN_BLOQUEO_MINUTOS` | Límite de intentos (5 por usuario+IP, 20 por IP, 15 minutos) | Valores por defecto |

`.env` está en `.gitignore`. Ninguna credencial real se versiona.

## 4. Base de datos

| Tema | Dónde |
|---|---|
| Modelo ER (Chen) y relacional (Workbench) | [`docs/diagramas/`](../diagramas/) |
| Normalización a 3FN y diccionario de datos | [`docs/entrega-2/ENTREGA2_DISENO_LOGICO.md`](../entrega-2/ENTREGA2_DISENO_LOGICO.md) |
| Vistas, procedimientos y triggers (regla de negocio de cada uno) | [`sql/views/`](../../sql/views/README.md), [`sql/procedures/`](../../sql/procedures/README.md), [`sql/triggers/`](../../sql/triggers/README.md) |
| Roles y privilegios | [`sql/security/`](../../sql/security/README.md) |
| Cambios por entrega | `sql/ddl/06_ajustes_entrega3.sql`, `sql/ddl/07_ajustes_entrega4.sql` |

### 4.1 Flujo de datos de las operaciones críticas

| Operación | Qué ejecuta la app | Qué hace la base de datos |
|---|---|---|
| Registrar un ingreso | `INSERT ingreso_mercaderia` + `INSERT detalle_ingreso` en una transacción | `trg_detalle_ingreso_ai`: stock + kardex `entrada` |
| Crear un pedido | `sp_crear_pedido` + `sp_agregar_linea_pedido` por línea, en una transacción | `fn_calcular_precio_linea` calcula el precio; `trg_detalle_pedido_bi` valida el stock (`FOR UPDATE`); `trg_detalle_pedido_ai` descuenta el stock, registra la `salida` con `pedido_id` y recalcula el total |
| Completar | `UPDATE pedido SET estado='completado'` (solo desde `pendiente`) | — |
| Devolver | `sp_registrar_devolucion` | Valida vendido − devuelto; stock + kardex `devolucion_cliente` |
| Cancelar | `sp_cancelar_pedido` | Solo `pendiente`; reintegra cada línea como `cancelacion`; conserva el detalle |

**Invariante:** stock de cada variante = suma de `vw_kardex.efecto_stock`. Se
comprueba con CP4-07 o con el punto 7 de `railway_verificar.sql`.

### 4.2 Alcance del CRUD

| Tablas | C | R | U | D |
|---|:---:|:---:|:---:|:---:|
| `producto`, `variante_producto`, `cliente` (+ teléfonos), `furgon`, `empleado` (+ teléfonos), `usuario`, `categoria`, `talla`, `color`, `tipo_cliente`, `presentacion_venta` | ✅ | ✅ | ✅ | ✅ (bloqueado por FK si tiene historial) |
| `ingreso_mercaderia`, `detalle_ingreso` | ✅ | ✅ | — | — |
| `pedido`, `detalle_pedido` | ✅ | ✅ | Estado | Cancelación o devolución |
| `movimiento_stock` | Por triggers y procedimientos | ✅ | — | — |

**Justificación.** Ingresos y pedidos son documentos transaccionales: ya
movieron el stock y generaron kardex. Editarlos o borrarlos descuadraría el
inventario y destruiría la auditoría (RF15, RF16), así que se corrigen con
operaciones inversas registradas: cancelación y devolución.
`fk_movimiento_pedido ON DELETE RESTRICT` lo impone en la base (CP4-06).
Detalle en [`ENTREGA4_INFORME_FINAL.md`](./ENTREGA4_INFORME_FINAL.md), sección 6.1.

## 5. Seguridad

**En la base de datos** (`sql/security/`): `rol_administrador`, `rol_bodeguero`
y `rol_vendedor`, con privilegios mínimos. Por ejemplo, el vendedor tiene
`SELECT` sobre `pedido` y `EXECUTE` sobre sus procedimientos, sin `INSERT`
directo. Se prueba con CP3-06 y CP3-07.

**En la web:**
- Contraseñas con bcrypt.
- Sesión regenerada al iniciar sesión; cookie `HttpOnly`, `SameSite=Lax` y `Secure` en producción.
- CSRF por `Origin`/`Referer` y cabeceras de seguridad, sin `X-Powered-By`.
- Límite de intentos de login con HTTP 429.
- Autorización centralizada en `permisos.js`, con respuesta 403.
- Consultas parametrizadas.

Se prueba con SEG-01 a SEG-11 y CP4-22.

## 6. Despliegue en Railway

| Elemento | Configuración |
|---|---|
| Servicio web | Repositorio de GitHub, rama `main`, directorio raíz `/web`, `npm start`, despliegue automático en cada push a `main` |
| Servicio MySQL | MySQL 8 de Railway, esquema `railway`; la app se conecta por la **red privada** con las variables del servicio MySQL |
| Variables de la app | Las de la sección 3.1, cargadas en el panel *Variables* de Railway |
| Acceso público a MySQL | Desactivado. Se activa solo de forma temporal para administrar con Workbench y se vuelve a cerrar |
| URL | https://grand-acceptance-production-0ac1.up.railway.app |
| Instancias | **1** (las sesiones están en memoria) |

### 6.1 Instalar o reinstalar la base de producción

Ejecute los scripts de `sql/` (con `USE railway;` en lugar de
`USE pavanamoon;`) o el procedimiento de
[`despliegue-railway/`](./despliegue-railway/GUIA_SINCRONIZACION_RAILWAY.md).
**No instale producción desde un dump de una base de desarrollo**: así se
originó el incidente del 20/10/2026 (`ENTREGA4_IMPLEMENTACION.md`, sección 4.2).
Después de cualquier cambio, ejecute `railway_verificar.sql`: el veredicto
debe ser `IGUAL AL REPOSITORIO`.

### 6.2 Respaldo

En Workbench, en la conexión de Railway: **Server → Data Export**, *Structure
and Data*, con procedimientos, funciones y triggers, *Self-Contained File* e
*Include Create Schema*. La comprobación del archivo está en la guía de
sincronización, paso 3.

## 7. Pruebas

| Batería | Cómo se ejecuta | Base |
|---|---|---|
| CP4-01 a CP4-07 | `mysql -t --force -u root < docs/casos-prueba/scripts/entrega4_casos_bd.sql` | `pavanamoon` |
| CP4-08 a CP4-15, CP4-16 a CP4-22 | `bash docs/casos-prueba/scripts/entrega4_casos_web.sh` y `entrega4_casos_catalogos.sh` (con la app en marcha) | `pavanamoon` |
| SEG-01 a SEG-11 | `node --test docs/casos-prueba/scripts/entrega4_seguridad.test.cjs`; antes, crear en `/usuarios` los usuarios `cabrito` (bodeguero) y `fernanflo` (vendedor) y pasar las contraseñas en `PVM_PASS_ADMIN/BODEGA/VENTAS` | `pavanamoon` |
| INT-01 a INT-07 | `node docs/casos-prueba/scripts/instalar_bd_prueba.cjs --recrear` y luego `node --test …/entrega4_integracion_stock.test.cjs` | **solo** `*_prueba` |
| Unitarias | `node docs/casos-prueba/scripts/entrega4_variantes_clientes_unit.cjs` | No usa base |

**Nunca** ejecute las baterías CP4 ni INT contra Railway: escriben datos de
prueba, y las INT son destructivas. Resultados y matriz de trazabilidad en
[`CASOS_PRUEBA_ENTREGA4.md`](../casos-prueba/CASOS_PRUEBA_ENTREGA4.md).

## 8. Mantenimiento y extensión

- **Cambio de esquema:** cree un script nuevo `sql/ddl/0N_ajustes_entregaX.sql`
  con `ALTER TABLE`; no reescriba los anteriores. Actualice el diagrama y el
  diccionario.
- **Nuevo objeto de base de datos:** un archivo por objeto, con encabezado
  (archivo, autor, descripción, dependencias, regla de negocio) y una entrada
  en el README de su carpeta.
- **Nuevo módulo web:** agregue su entrada en `permisos.js` (ruta y roles),
  un router en `src/routes/`, el modelo con consultas parametrizadas y las
  vistas. Monte el router en `server.js` con `requireRole`.
- **Cambiar el descuento mayorista:** en **Catálogos → Tipos de cliente**. Se
  aplica a los pedidos nuevos; los existentes conservan su precio.

## 9. Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| La app no arranca en producción y menciona `SESSION_SECRET` | Secreto corto o igual al del ejemplo | Ponga uno aleatorio de 32+ caracteres en Railway |
| `ER_ACCESS_DENIED_ERROR` al arrancar | Credenciales `DB_*` incorrectas | Revise las variables |
| Un POST devuelve 403 en producción | Origen no reconocido detrás del proxy | `TRUST_PROXY=1`; agregue el dominio en `ORIGENES_PERMITIDOS` si usa otro |
| `Unknown column 'cliente_id'` en `/pedidos` | Base instalada desde un dump antiguo | Guía de sincronización y `railway_verificar.sql` |
| `Table 'x' doesn't exist` solo en Railway | Linux distingue mayúsculas en los nombres de tabla | Use nombres en minúsculas, como en `sql/` |
| Se cierran las sesiones tras un despliegue | Sesiones en memoria | Es esperado: vuelva a iniciar sesión |
| En una instalación local, las horas salen 6 horas antes | MySQL local en hora de Guatemala, y la app lee las fechas como UTC (PR #4) | Configure MySQL local en UTC: `default-time-zone='+00:00'` en `my.ini` |

## 10. Limitaciones conocidas

- **Fechas:** el servidor guarda en UTC y la app muestra la hora de Guatemala
  (PR #4: `timezone: 'Z'` en `db.js` y `timeZone: 'America/Guatemala'` en las
  vistas). `vw_ventas_diarias` todavía agrupa por la fecha UTC.
- **Sesiones en `MemoryStore`:** una sola instancia, y las sesiones se pierden
  en cada despliegue.
- **Roles `pvm_*`:** instalados en local, no en Railway, donde la app usa la
  cuenta del servicio.
- **Sin pantalla para movimientos de `ajuste`:** el tipo existe en la base (RD10).

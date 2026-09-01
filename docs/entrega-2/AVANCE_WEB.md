# AVANCE_WEB — Entrega 2 (30%)

## Stack utilizado

- **Backend:** Node.js + Express 4
- **Vistas:** EJS (server-side rendering, sin build step)
- **Base de datos:** MySQL, vía `mysql2/promise` (pool de conexiones, consultas parametrizadas)
- **Sesiones:** `express-session` (autenticación basada en sesión de servidor)
- **Contraseñas:** `bcryptjs` (hash, nunca texto plano)

## Estructura del proyecto (`web/`)

```
web/
├── server.js                  # Punto de entrada, configuración de Express/sesiones
├── package.json
├── .env.example
├── src/
│   ├── config/db.js           # Pool de conexión MySQL (estándar A1: separación de capas)
│   ├── middleware/
│   │   ├── auth.js            # requireAuth, exposeCurrentUser
│   │   └── errorHandler.js    # Manejo centralizado de errores (estándar A2)
│   ├── models/                # Única capa que escribe SQL (consultas parametrizadas, A4)
│   │   ├── usuarioModel.js
│   │   ├── productoModel.js
│   │   ├── clienteModel.js
│   │   └── catalogoModel.js
│   ├── routes/
│   │   ├── authRoutes.js      # /login, /logout
│   │   ├── productoRoutes.js  # CRUD /productos
│   │   └── clienteRoutes.js   # CRUD /clientes
│   └── utils/validate.js      # Validación de entrada (estándar A3)
├── views/                      # Plantillas EJS (layout con header/footer parciales)
└── public/css/style.css
```

## Funcionalidad entregada en esta fase (30%)

| Requisito de la guía (Sección 11, Entrega 2) | Estado | Detalle |
|---|---|---|
| Login | ✅ | `/login` valida contra `usuario` (JOIN `rol`, `empleado`), compara hash con bcrypt, crea sesión de servidor. |
| Layout / estructura web | ✅ | Header con navegación y usuario actual, footer, hoja de estilos propia (`public/css/style.css`), sin frameworks CSS externos. |
| 2 módulos CRUD que persisten en BD | ✅ | **Productos** (`/productos`) y **Clientes** (`/clientes`): alta, listado, edición y eliminación, todo contra MySQL real. |
| Consultas parametrizadas (A4) | ✅ | Todas las consultas en `src/models/*` usan `?` — cero concatenación de strings en SQL. |
| Esquema alineado al diagrama ER vigente | ✅ | Producto usa `modelo` + `tipo_suela` (sin `marca`, Pavanamoon es marca propia); Cliente usa `tipo_cliente_id` (catálogo) en vez de un ENUM embebido — ver corrección documentada en `ENTREGA2_DISENO_LOGICO.md` §1. |
| Separación de capas (A1) | ✅ | rutas → modelos → `config/db.js`; las rutas nunca contienen SQL. |
| Manejo de errores (A2) | ✅ | `errorHandler.js` traduce errores de MySQL (`ER_DUP_ENTRY`, `ER_ROW_IS_REFERENCED_2`, etc.) a mensajes legibles; nunca se muestra el stack trace al usuario. |
| Validación de entrada (A3) | ✅ | `utils/validate.js` valida tipos, campos requeridos y formatos antes de tocar la BD. |
| Control de acceso por rol (RF21) | ⏳ Entrega 3 | Por ahora solo se exige "sesión activa" (`requireAuth`); la diferenciación de permisos por rol se implementa cuando existan más módulos con acciones sensibles (compras, seguridad). |

## Cómo probarlo localmente

Ver el detalle completo en [`INSTALL.md`](../../INSTALL.md). Resumen:

```bash
# 1) Base de datos (una sola vez)
mysql -u root -p < sql/ddl/01_crear_base_datos.sql
mysql -u root -p < sql/ddl/02_tablas_catalogo.sql
mysql -u root -p < sql/ddl/03_tablas_personas.sql
mysql -u root -p < sql/ddl/04_tablas_producto.sql
mysql -u root -p < sql/ddl/05_tablas_transacciones.sql
mysql -u root -p < sql/dml/00_seed_minimo.sql

# 2) App web
cd web
cp .env.example .env   # completar credenciales reales de tu MySQL local
npm install
npm start
```

Luego abrir `http://localhost:3000/login` — usuario semilla: `admin` / `Admin#2026`
(solo para ambiente local de pruebas; ver nota de seguridad en `sql/dml/00_seed_minimo.sql`).

Todas las vistas EJS (`login`, `home`, `error`, `productos/*`, `clientes/*`) fueron
renderizadas en seco con datos de prueba (`ejs.renderFile`) para confirmar que no
tienen errores de plantilla antes de esta entrega.

## Validación técnica realizada por el equipo (sin exponer credenciales reales)

- Los 5 scripts DDL y el script de datos semilla fueron verificados con un parser
  sintáctico de MySQL (`node-sql-parser`) para confirmar que no contienen errores de
  sintaxis antes de ejecutarlos contra un servidor real.
- Todos los módulos de Node.js (`server.js`, rutas, modelos, middlewares) pasaron
  `node --check` sin errores.
- Pendiente para la certificación de esta entrega: ejecutar los scripts contra una
  instancia MySQL real del equipo y adjuntar evidencia (capturas o log) en
  `docs/casos-prueba/`.

## Próximos pasos (Entrega 3)

- Módulos de Compras, Pedidos y Movimientos de Stock (con triggers de actualización de stock).
- Vistas y procedimientos almacenados (cálculo de `total_pedido` con descuento mayorista).
- Roles de seguridad a nivel de MySQL (`CREATE USER` / `GRANT`) en `sql/security/`.
- Control de acceso por rol dentro de la app (RF21).
- Carga de datos de prueba (≥50 registros por tabla principal) en `sql/dml/`.

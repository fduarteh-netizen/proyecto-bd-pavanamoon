# sql/security

Seguridad a nivel de base de datos (Sección 5, req. 6 de la guía): **3 roles de
MySQL 8 con privilegios diferenciados** según el principio de mínimo privilegio.

| Script | Contenido |
|---|---|
| [`01_roles_privilegios.sql`](./01_roles_privilegios.sql) | Crea los roles `rol_administrador`, `rol_bodeguero`, `rol_vendedor`, sus privilegios y un usuario de MySQL por rol (`pvm_admin`, `pvm_bodega`, `pvm_ventas`). |

## Roles y usuarios

| Usuario MySQL | Rol | Puede | No puede |
|---|---|---|---|
| `pvm_admin` | `rol_administrador` | Todo sobre el esquema `pavanamoon` (`ALL PRIVILEGES`). | Nada fuera del esquema `pavanamoon`. |
| `pvm_bodega` | `rol_bodeguero` | Leer catálogos y productos; `INSERT/UPDATE` en variantes, furgones e ingresos; `INSERT` en detalle de ingreso; leer kardex y vistas de stock/ingresos. | Ver clientes, pedidos o la tabla `usuario`; borrar (`DELETE`) cualquier cosa. |
| `pvm_ventas` | `rol_vendedor` | Leer productos, stock (vista) y pedidos; `INSERT/UPDATE` en clientes; crear pedidos y devoluciones **solo** con `CALL` a los procedimientos. | Escribir directo en `pedido`/`detalle_pedido` (no puede inventar precios), tocar inventario, furgones o ingresos, ver `usuario`, borrar. |

Las contraseñas de `01_roles_privilegios.sql` son **placeholders de desarrollo
local** (estándar R6); cambiarlas con `ALTER USER` antes de cualquier despliegue.

## Dos capas de seguridad

1. **Base de datos (esta carpeta):** los usuarios `pvm_*` son para acceso
   directo a MySQL (Workbench, reportes, soporte). Aunque alguien se salte la
   app, MySQL rechaza lo que su rol no permite (`ERROR 1142`).
2. **Aplicación web:** la app se conecta con un único usuario técnico
   (`pavanamoon_app`, ver `INSTALL.md` paso 3) y controla el acceso por rol con
   la tabla `usuario` (login con bcrypt) y la matriz
   `web/src/config/permisos.js` (respuesta 403 si el rol no tiene el módulo).

Ambas capas usan la **misma matriz de permisos**: lo que un rol ve en la web
coincide con lo que su usuario de MySQL puede consultar.

## Cómo verificarlo

```bash
# Matriz de privilegios legible (solo consulta, no modifica nada)
mysql -t -u root -p < docs/casos-prueba/scripts/demo_seguridad_presentacion.sql

# Pruebas reales permitido/denegado con cada usuario (CP3-06, CP3-07)
bash docs/casos-prueba/scripts/entrega3_casos_seguridad.sh
```

Guion para presentarlo al catedrático: [`docs/entrega-3/PRESENTACION_SEGURIDAD.md`](../../docs/entrega-3/PRESENTACION_SEGURIDAD.md).

Convención de nombres: `sql/security/NN_descripcion.sql` (estándar S2), con
encabezado (estándar S3).

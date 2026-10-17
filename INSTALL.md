# Instalación

Este documento reemplaza el placeholder de la Entrega 1: a partir de la Entrega 2
existen scripts DDL ejecutables y una aplicación web funcional.

## Requisitos previos

- **MySQL 8.x** con el motor **InnoDB** (requerido para llaves foráneas con
  integridad referencial; es el motor por defecto en MySQL 8, no requiere
  configuración adicional).
- **Node.js ≥ 18** y **npm** (para la aplicación web).
- Un cliente de línea de comandos `mysql`, o cualquier cliente gráfico (MySQL
  Workbench, DBeaver, TablePlus, etc.).

## 1. Crear la base de datos completa (orden obligatorio)

Ejecutar **en este orden exacto** (cada script depende de los anteriores; el
DML va ANTES de los triggers para que los datos históricos no vuelvan a mover
el stock):

```bash
# Estructura (Entregas 2, 3 y 4)
mysql -u root -p < sql/ddl/01_crear_base_datos.sql
mysql -u root -p < sql/ddl/02_tablas_catalogo.sql
mysql -u root -p < sql/ddl/03_tablas_personas.sql
mysql -u root -p < sql/ddl/04_tablas_producto.sql
mysql -u root -p < sql/ddl/05_tablas_transacciones.sql
mysql -u root -p < sql/ddl/06_ajustes_entrega3.sql
mysql -u root -p < sql/ddl/07_ajustes_entrega4.sql

# Datos
mysql -u root -p < sql/dml/00_seed_minimo.sql
mysql -u root -p < sql/dml/01_datos_prueba.sql

# Vistas, triggers, procedimientos y seguridad (Entregas 3 y 4)
for f in sql/views/*.sql sql/triggers/*.sql sql/procedures/*.sql sql/security/*.sql; do
  mysql -u root -p < "$f"
done
```

En Windows (PowerShell) el `for` equivalente es:

```powershell
Get-ChildItem sql\views\*.sql, sql\triggers\*.sql, sql\procedures\*.sql, sql\security\*.sql |
  ForEach-Object { Get-Content $_.FullName -Raw | mysql -u root -p }
```

En MySQL Workbench: abrir cada archivo en ese mismo orden y ejecutarlo
completo (rayo ⚡). Los scripts de triggers/procedimientos usan `DELIMITER $$`,
que Workbench y el cliente `mysql` soportan.

## 2. Usuarios de prueba (solo ambiente local, estándar R6)

| Usuario app | Contraseña | Rol |
|---|---|---|
| `admin` | `Admin#2026` | administrador |
| `bodega` | `Bodega#2026` | bodeguero |
| `ventas` | `Ventas#2026` | vendedor |

Usuarios de MySQL creados por `sql/security/01_roles_privilegios.sql`:
`pvm_admin`, `pvm_bodega`, `pvm_ventas` (contraseñas placeholder dentro del
script; cambiarlas con `ALTER USER` antes de cualquier despliegue).

## 3. Crear el usuario técnico de la aplicación

La app web se conecta con un usuario dedicado (nunca `root`). Necesita
`EXECUTE` para invocar los procedimientos almacenados:

```sql
CREATE USER 'pavanamoon_app'@'localhost' IDENTIFIED BY 'una_contraseña_segura';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON pavanamoon.* TO 'pavanamoon_app'@'localhost';
FLUSH PRIVILEGES;
```

## 4. Configurar y levantar la aplicación web

```bash
cd web
cp .env.example .env
# Editar .env y completar DB_USER, DB_PASSWORD con los datos del paso 3.

npm install
npm start
```

La aplicación queda disponible en `http://localhost:3000`. La ruta `/login` valida
contra la tabla `usuario` (contraseña con hash bcrypt, nunca texto plano). Cada
rol ve solo sus módulos (ver `docs/entrega-3/AVANCE_WEB.md`).

## 4.1 Ejecutar los casos de prueba de la Entrega 3

```bash
mysql -t --force -u root -p < docs/casos-prueba/scripts/entrega3_casos_bd.sql   # --force: CP3-04/05a fallan a propósito
bash docs/casos-prueba/scripts/entrega3_casos_seguridad.sh
bash docs/casos-prueba/scripts/entrega3_casos_web.sh   # con la app corriendo
```

## 4.2 Ejecutar los casos de prueba de la Entrega 4

```bash
mysql -t --force -u root -p < docs/casos-prueba/scripts/entrega4_casos_bd.sql   # --force: 4 casos fallan a propósito
bash docs/casos-prueba/scripts/entrega4_casos_web.sh   # con la app corriendo; imprime OK/FALLA y un resumen
```

Si `root` tiene contraseña, el script web la toma de la variable `MYSQL`:
`MYSQL="mysql -uroot -pTU_CLAVE" bash docs/casos-prueba/scripts/entrega4_casos_web.sh`

## 5. Variables de entorno

Ver [`.env.example`](./.env.example) (raíz, para referencia de conexión a MySQL) y
[`web/.env.example`](./web/.env.example) (usado realmente por la app Node.js).

> **Ojo con `#` en `.env`:** `dotenv` trata `#` como inicio de comentario si el
> valor no va entre comillas. Una contraseña como `App#2026` debe escribirse
> `DB_PASSWORD="App#2026"`; sin comillas la app lee solo `App` y MySQL responde
> *Access denied*.

## Notas de diseño relevantes para la instalación

- El modelo relacional implementado corresponde al **diagrama ER corregido**
  (`docs/diagramas/Pavanamoon_er_chen_corregido.drawio`), la versión más reciente
  confirmada por el equipo. Ver la nota de corrección completa en
  `docs/entrega-2/ENTREGA2_DISENO_LOGICO.md` (Sección 1).
- Todos los scripts DDL/DML fueron validados sintácticamente con un parser de MySQL
  antes de esta entrega; aun así, se recomienda ejecutar los pasos 1–2 contra una
  instancia real y guardar evidencia en `docs/casos-prueba/` antes de firmar la
  certificación de calidad de esta entrega.

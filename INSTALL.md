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

## 1. Crear la base de datos (scripts DDL)

Ejecutar los scripts **en este orden exacto** (cada uno depende del anterior):

```bash
mysql -u root -p < sql/ddl/01_crear_base_datos.sql
mysql -u root -p < sql/ddl/02_tablas_catalogo.sql
mysql -u root -p < sql/ddl/03_tablas_personas.sql
mysql -u root -p < sql/ddl/04_tablas_producto.sql
mysql -u root -p < sql/ddl/05_tablas_transacciones.sql
```

## 2. Cargar datos semilla (mínimos para poder iniciar sesión)

```bash
mysql -u root -p < sql/dml/00_seed_minimo.sql
```

Esto crea los 3 roles de seguridad, catálogos base (categoría, talla, color, tipo de
cliente, presentación de venta) y un usuario administrador de prueba:

- **username:** `admin`
- **password:** `Admin#2026`

> Esta contraseña es solo para desarrollo/pruebas locales. Nunca debe usarse en un
> despliegue con datos reales (estándar R6 de la guía del proyecto).

## 3. Crear un usuario de aplicación en MySQL (recomendado)

En vez de que la app web se conecte como `root`, crear un usuario dedicado (los
privilegios diferenciados por rol se completan en Entrega 3, `sql/security/`):

```sql
CREATE USER 'pavanamoon_app'@'localhost' IDENTIFIED BY 'una_contraseña_segura';
GRANT SELECT, INSERT, UPDATE, DELETE ON pavanamoon.* TO 'pavanamoon_app'@'localhost';
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
contra la tabla `usuario` (contraseña con hash bcrypt, nunca texto plano).

## 5. Orden general de ejecución de scripts SQL (para entregas futuras)

Conforme se agreguen vistas, triggers, procedimientos y seguridad en la Entrega 3, el
orden de ejecución completo será:

```
sql/ddl/         (estructura de tablas — Entrega 2)
sql/dml/         (datos semilla y de prueba)
sql/views/       (vistas — Entrega 3)
sql/triggers/    (triggers — Entrega 3)
sql/procedures/  (procedimientos almacenados — Entrega 3)
sql/security/    (roles y privilegios de MySQL — Entrega 3)
```

## 6. Variables de entorno

Ver [`.env.example`](./.env.example) (raíz, para referencia de conexión a MySQL) y
[`web/.env.example`](./web/.env.example) (usado realmente por la app Node.js).

## Notas de diseño relevantes para la instalación

- El modelo relacional implementado corresponde al **diagrama ER corregido**
  (`docs/diagramas/Pavanamoon_er_chen_corregido.drawio`), la versión más reciente
  confirmada por el equipo. Ver la nota de corrección completa en
  `docs/entrega-2/ENTREGA2_DISENO_LOGICO.md` (Sección 1).
- Todos los scripts DDL/DML fueron validados sintácticamente con un parser de MySQL
  antes de esta entrega; aun así, se recomienda ejecutar los pasos 1–2 contra una
  instancia real y guardar evidencia en `docs/casos-prueba/` antes de firmar la
  certificación de calidad de esta entrega.

# Casos de Prueba — Entrega 2
## Proyecto Pavanamoon

Todas las pruebas de este documento se ejecutaron de verdad contra una instancia
MySQL/MariaDB real y la aplicación web corriendo localmente (no son pruebas
hipotéticas). El log completo de la sesión SQL está en
[`evidencias/pruebas_restricciones_sql.log`](./evidencias/pruebas_restricciones_sql.log)
y las capturas de pantalla reales de la app están en [`evidencias/`](./evidencias/).

**Entorno de prueba:** MariaDB 10.11, Node.js 22, scripts ejecutados en el orden de
`INSTALL.md` desde una base de datos vacía (`DROP DATABASE` + recreación completa).

---

## Parte 1 — Scripts DDL/DML (creación desde cero)

| Caso | Acción | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| DDL-01 | Ejecutar `01_crear_base_datos.sql` .. `05_tablas_transacciones.sql` en orden, sobre una BD vacía | Las 19 tablas se crean sin errores | ✅ PASA — 19 tablas creadas (`SHOW TABLES` confirmado) |
| DDL-02 | Ejecutar `00_seed_minimo.sql` | Se cargan 3 roles, 3 categorías, 6 tallas, 4 colores, 2 tipos de cliente, 2 presentaciones, 1 empleado, 1 usuario | ✅ PASA — conteo verificado por tabla (ver evidencia abajo) |

Conteo real tras el seed:

```
rol                 3
categoria           3
talla               6
color               4
tipo_cliente        2
presentacion_venta  2
empleado            1
usuario             1
```

---

## Parte 2 — Restricciones de integridad (ejecutadas directamente en SQL)

| Caso | Prueba | Restricción que se valida | Resultado esperado | Resultado obtenido |
|---|---|---|---|---|
| CP-01 | Insertar cliente con NIT nuevo | — | Éxito | ✅ PASA |
| CP-02 | Insertar cliente con NIT ya usado | `UNIQUE uq_cliente_nit` | Rechazado | ✅ PASA — `ERROR 1062: Duplicate entry '1234567' for key 'uq_cliente_nit'` |
| CP-03 | Insertar producto con `precio_venta = -10` | `CHECK ck_producto_precio` | Rechazado | ✅ PASA — `ERROR 4025: CONSTRAINT ck_producto_precio failed` |
| CP-04 | Insertar producto con `categoria_id = 999` (no existe) | `FK fk_producto_categoria` | Rechazado | ✅ PASA — `ERROR 1452: foreign key constraint fails` |
| CP-05 | Insertar variante con `stock_actual = -5` | `CHECK ck_variante_stock_actual` | Rechazado | ✅ PASA — `ERROR 4025: CONSTRAINT ck_variante_stock_actual failed` |
| CP-06 | Insertar variante válida (`stock_actual = 10`) | — | Éxito | ✅ PASA |
| CP-07 | Insertar otra variante con el mismo `sku` | `UNIQUE uq_variante_sku` | Rechazado | ✅ PASA — `ERROR 1062: Duplicate entry 'SKU-TEST-001'` |
| CP-08 | Insertar variante con la misma combinación `(producto_id, talla_id, color_id)` | `UNIQUE uq_variante_combinacion` | Rechazado | ✅ PASA — `ERROR 1062: Duplicate entry '2-1-1'` |
| CP-09 | Borrar una `categoria` referenciada por un `producto` | `FK ... ON DELETE RESTRICT` (implícito) | Rechazado | ✅ PASA — `ERROR 1451: a foreign key constraint fails` |
| CP-10 | Insertar en `detalle_ingreso` con `cantidad=10, costo_unitario=85.50` | Columna generada `subtotal` | `subtotal = 855.00`, calculado por MySQL | ✅ PASA — valor exacto confirmado |

**10/10 pruebas pasaron.** Evidencia completa (comandos y salida real de MySQL) en
`evidencias/pruebas_restricciones_sql.log`.

---

## Parte 3 — Aplicación web (Node.js + Express + EJS contra MySQL real)

| Caso | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|
| WEB-01 | `POST /login` con `admin` / `Admin#2026` | Autentica y crea sesión (redirección 302) | ✅ PASA — `HTTP 302`, cookie de sesión emitida | `evidencias/01_login.png` |
| WEB-02 | `GET /` autenticado | Muestra "Bienvenido, Admin Pavanamoon" (confirma que `nombres_apellidos` se lee correctamente desde `empleado`, sin usar columnas inexistentes `nombres`/`apellidos`) | ✅ PASA | `evidencias/02_home.png` |
| WEB-03 | Crear producto real vía `POST /productos` (modelo "Pavanamoon Striker X") | El producto se guarda en MySQL y aparece en el listado | ✅ PASA — confirmado con `SELECT` indirecto vía `GET /productos` | `evidencias/03_productos_list.png`, `evidencias/05_producto_form.png` |
| WEB-04 | Crear cliente real vía `POST /clientes` ("Comercial El Rápido", tipo mayorista) | El cliente se guarda en MySQL y aparece en el listado con su tipo | ✅ PASA | `evidencias/04_clientes_list.png`, `evidencias/06_cliente_form.png` |
| WEB-05 | Crear un segundo cliente con el mismo NIT ya usado | La app no se cae; muestra un mensaje entendible, nunca el error SQL crudo (estándar A2) | ✅ PASA — `HTTP 500` controlado, mensaje: *"Ya existe un registro con ese valor único (NIT, SKU, username, etc.)."* | `evidencias/07_error_nit_duplicado.png` |
| WEB-06 | `GET /productos` **sin** cookie de sesión | Redirige a `/login` (`requireAuth`) | ✅ PASA — `HTTP 302` hacia `/login` | (ver log de comandos abajo) |
| WEB-07 | `POST /logout` | Cierra la sesión | ✅ PASA — `HTTP 302` | — |

### Comandos ejecutados (reproducibles)

```bash
curl -c cookies.txt -X POST http://localhost:3000/login -d "username=admin&password=Admin#2026"
curl -b cookies.txt http://localhost:3000/
curl -b cookies.txt -X POST http://localhost:3000/productos -d "categoria_id=1&modelo=Pavanamoon Striker X&tipo_suela=flex&precio_venta=249.99"
curl -b cookies.txt http://localhost:3000/productos
curl -b cookies.txt -X POST http://localhost:3000/clientes -d "tipo_cliente_id=2&nombre_cliente=Comercial El Rapido&nit=7654321&telefono=5555-1234"
curl -b cookies.txt http://localhost:3000/clientes
curl -b cookies.txt -X POST http://localhost:3000/clientes -d "tipo_cliente_id=1&nombre_cliente=Cliente Duplicado&nit=7654321"
curl http://localhost:3000/productos   # sin cookie
curl -b cookies.txt -X POST http://localhost:3000/logout
```

---

## Resumen

| Bloque | Casos ejecutados | Pasaron |
|---|---|---|
| DDL/DML desde cero | 2 | 2/2 |
| Restricciones de integridad (SQL directo) | 10 | 10/10 |
| Aplicación web (login + CRUD real) | 7 | 7/7 |
| **Total** | **19** | **19/19** |

## Pendiente para Entrega 3

- Casos de prueba para triggers, procedimientos almacenados y vistas (no existen
  hasta la Entrega 3).
- Casos de prueba de roles de seguridad de MySQL con privilegios diferenciados
  (`sql/security/`, Entrega 3).
- Pruebas de carga con el volumen final de datos (≥50 registros por tabla
  principal, Entrega 3).

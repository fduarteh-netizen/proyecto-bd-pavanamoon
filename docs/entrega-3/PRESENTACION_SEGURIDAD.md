# Presentación de seguridad y control de acceso — Entrega 3
## Proyecto Pavanamoon

Guion para demostrar al catedrático los criterios **"Seguridad: 3 roles en BD"**
(0.5), **"Control de acceso por rol en la app"** (0.5) y la parte de **"roles BD
OK"** de la revisión funcional. Duración aproximada: 8–10 minutos.

**Antes de empezar:** la base debe estar instalada según `INSTALL.md` (incluye
`sql/security/01_roles_privilegios.sql`) y la app corriendo (`npm start` en `web/`).

---

## 1. Idea central (30 segundos, para decirla al inicio)

> "Pavanamoon tiene **dos capas** de seguridad que usan la **misma matriz de
> permisos**. La primera está en MySQL: 3 roles con mínimo privilegio, así
> que aunque alguien entre directo a la base con Workbench, MySQL le niega lo
> que su rol no permite. La segunda está en la app web: cada usuario inicia
> sesión con su rol y solo ve y puede abrir sus módulos; si escribe la URL a
> mano, el servidor responde 403."

| Rol | Usuario MySQL | Usuario web | Responsabilidad |
|---|---|---|---|
| Administrador | `pvm_admin` / `Cambiar#Admin2026` | `admin` / `Admin#2026` | Todo el sistema |
| Bodeguero | `pvm_bodega` / `Cambiar#Bodega2026` | `bodega` / `Bodega#2026` | Inventario, furgones, ingresos, kardex |
| Vendedor | `pvm_ventas` / `Cambiar#Ventas2026` | `ventas` / `Ventas#2026` | Clientes y pedidos |

Todas son contraseñas de desarrollo local (estándar R6).

---

## 2. Capa 1 — Base de datos (Workbench)

### 2.1 Mostrar que los roles y usuarios existen (conexión root)

Abrir `docs/casos-prueba/scripts/demo_seguridad_presentacion.sql` en Workbench
y ejecutar cada bloque con **Ctrl+Enter** (cursor sobre la consulta). Qué decir
en cada paso:

| Paso | Qué se ve | Qué explicar |
|---|---|---|
| 1 | 3 cuentas tipo ROL y 3 tipo USUARIO | En MySQL 8 un rol es una cuenta bloqueada que solo agrupa privilegios; los usuarios `pvm_*` son los que inician sesión. |
| 2 | Cada `pvm_*` con su rol y "activo por defecto = SÍ" | Se usó `SET DEFAULT ROLE ALL`, así el rol se activa solo al conectarse. |
| 3 | **Matriz de privilegios** tabla × rol | Es la pantalla clave. Señalar: el bodeguero no ve `cliente` ni `pedido`; el vendedor no ve `furgon` ni `variante_producto`; **nadie** salvo admin ve `usuario`; ninguno tiene `DELETE`. |
| 4 | El vendedor tiene `EXECUTE` sobre los procedimientos | El vendedor **no** tiene `INSERT` en `pedido`: solo puede vender con `CALL sp_crear_pedido` / `sp_agregar_linea_pedido`, que calculan el precio con descuento. Así no puede poner precios a mano. |
| 5 | `SHOW GRANTS` | Lo que MySQL realmente aplica (es la forma "oficial" de verlo). |
| 6 | 0 roles no-admin con acceso a `usuario` | La tabla de contraseñas (hash bcrypt) está protegida. |

La salida completa de este script está guardada en
`docs/casos-prueba/evidencias/entrega3_demo_seguridad.txt` por si no hay tiempo
de ejecutarlo en vivo.

### 2.2 Demostración en vivo: permitido vs. denegado

En Workbench: **Database → Manage Connections → New**, crear una conexión por
usuario (host `127.0.0.1`, puerto `3306`, usuario `pvm_ventas`, contraseña
`Cambiar#Ventas2026`, esquema por defecto `pavanamoon`). Repetir para
`pvm_bodega`.

**Conectado como `pvm_ventas` (vendedor):**

```sql
SELECT CURRENT_ROLE();                                   -- rol_vendedor
SELECT COUNT(*) FROM cliente;                            -- ✅ 60 clientes
SELECT username, password_hash FROM usuario;             -- ❌ ERROR 1142
UPDATE variante_producto SET stock_actual = 9999
 WHERE variante_id = 1;                                  -- ❌ ERROR 1142 (no toca inventario)
DELETE FROM cliente WHERE cliente_id = 1;                -- ❌ ERROR 1142 (no borra)
INSERT INTO pedido (cliente_id, empleado_id, estado, total_pedido)
VALUES (1, 3, 'pendiente', 1);                           -- ❌ ERROR 1142 (no inventa pedidos)
CALL sp_crear_pedido(1, 3, @p); SELECT @p;               -- ✅ solo por procedimiento
```

**Conectado como `pvm_bodega` (bodeguero):**

```sql
SELECT CURRENT_ROLE();                                   -- rol_bodeguero
SELECT COUNT(*) FROM pedido;                             -- ❌ ERROR 1142 (no ve ventas)
SELECT * FROM vw_stock_variantes WHERE alerta_stock_bajo = 1;  -- ✅ alertas de stock
INSERT INTO furgon (numero_furgon, fecha_llegada, estado)
VALUES ('FRG-DEMO', CURDATE(), 'en_transito');           -- ✅ registra furgón
DELETE FROM furgon WHERE numero_furgon = 'FRG-DEMO';     -- ❌ ERROR 1142 (no borra)
```

Al terminar, borrar el furgón de prueba con root o `pvm_admin`:
`DELETE FROM furgon WHERE numero_furgon = 'FRG-DEMO';`

**Alternativa rápida (terminal):** `bash docs/casos-prueba/scripts/entrega3_casos_seguridad.sh`
ejecuta exactamente estos casos (CP3-06 y CP3-07) con los tres usuarios.

---

## 3. Capa 2 — Aplicación web (navegador)

1. Entrar como **`ventas`**: el menú muestra solo *Inventario, Clientes, Pedidos*.
2. Escribir a mano `http://localhost:3000/furgones` → página **403 "Tu rol
   (vendedor) no tiene permiso para acceder a este módulo"**. Explicar: el menú
   oculta el enlace, pero lo que protege es el servidor (`requireRole`).
3. Crear un pedido de un cliente mayorista (1 caja): el precio sale con el 15 %
   de descuento sin que el vendedor lo digite (lo calcula la BD).
4. Cerrar sesión y entrar como **`bodega`**: menú *Productos, Inventario,
   Furgones, Ingresos, Kardex*; abrir `/pedidos` a mano → 403.
5. Entrar como **`admin`**: ve los 7 módulos.

Dónde está en el código: `web/src/config/permisos.js` (matriz única: menú,
tarjetas de inicio y rutas) y `web/src/middleware/auth.js` (`requireRole`).

---

## 4. Preguntas probables del catedrático

**¿Por qué la app no se conecta con `pvm_ventas` o `pvm_bodega` según quién
inicie sesión?** Porque la app usa un pool de conexiones con un solo usuario
técnico (`pavanamoon_app`, sin privilegios de administración: solo
`SELECT/INSERT/UPDATE/DELETE/EXECUTE` sobre `pavanamoon`). Abrir una conexión
distinta por usuario web no escala y obligaría a guardar contraseñas de MySQL
por cada empleado. Los usuarios `pvm_*` son para acceso directo a la BD; la
app aplica la misma matriz en su middleware.

**¿Qué pasa si un vendedor intenta cambiar el precio?** En la BD no tiene
`INSERT` ni `UPDATE` sobre `pedido`/`detalle_pedido`; solo `EXECUTE` sobre los
procedimientos, que calculan el precio con `fn_calcular_precio_linea`. En la
web el formulario no tiene campo de precio.

**¿Por qué nadie tiene `DELETE` salvo el administrador?** Pedidos, ingresos y
kardex son registros contables/auditables: se cancelan o se devuelven, no se
borran. Borrar rompería la trazabilidad del stock (stock = suma del kardex).

**¿Dónde están las contraseñas de la app?** En la tabla `usuario` como hash
bcrypt (nunca en texto plano), y ningún rol distinto de administrador puede
leer esa tabla.

**¿Cómo se crean los usuarios si se reinstala?** `sql/security/01_roles_privilegios.sql`
es idempotente (`DROP ROLE/USER IF EXISTS` y luego `CREATE`), se puede ejecutar
de nuevo sin errores.

---

## 5. Evidencias

| Evidencia | Archivo |
|---|---|
| Matriz de privilegios y `SHOW GRANTS` | `docs/casos-prueba/evidencias/entrega3_demo_seguridad.txt` |
| CP3-06 / CP3-07 (permitido/denegado por usuario MySQL) | `docs/casos-prueba/evidencias/entrega3_casos_seguridad.txt` |
| CP3-08 (rutas 200/403 por rol en la web) | `docs/casos-prueba/evidencias/entrega3_casos_web.txt` |
| Capturas: menú vendedor, 403, menú bodeguero | `docs/casos-prueba/evidencias/e3_05_*`, `e3_06_*`, `e3_08_*` |

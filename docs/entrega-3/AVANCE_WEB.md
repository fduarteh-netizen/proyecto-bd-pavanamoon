# AVANCE_WEB — Entrega 3 (≈70%)

Continúa [`../entrega-2/AVANCE_WEB.md`](../entrega-2/AVANCE_WEB.md) (30%: login + CRUD de Producto y Cliente).

## Módulos implementados

| # | Módulo | Ruta | Qué hace | Objetos de BD que usa | Roles |
|---|---|---|---|---|---|
| 1 | Productos | `/productos` | CRUD de modelos de calzado (Entrega 2) | `producto`, `categoria` | admin, bodeguero |
| 2 | Clientes | `/clientes` | CRUD de clientes (Entrega 2) | `cliente`, `cliente_telefono` | admin, vendedor |
| 3 | **Inventario** | `/inventario` | Stock por variante, búsqueda, filtro "bajo mínimo", alta de variantes | `vw_stock_variantes` | todos (alta: admin, bodeguero) |
| 4 | **Furgones** | `/furgones` | CRUD completo | `furgon` | admin, bodeguero |
| 5 | **Ingresos** | `/ingresos` | Registrar ingreso con varias líneas, ver detalle | `vw_ingresos_detalle`, `trg_detalle_ingreso_ai` | admin, bodeguero |
| 6 | **Pedidos** | `/pedidos` | Crear pedido multi-línea, historial por cliente, completar, devolución | `sp_crear_pedido`, `sp_agregar_linea_pedido`, `sp_registrar_devolucion`, `fn_calcular_precio_linea`, triggers de `detalle_pedido`, `vw_pedidos_resumen` | admin, vendedor |
| 7 | **Kardex** | `/kardex` | Movimientos filtrados por SKU y rango de fechas | `vw_kardex` | admin, bodeguero |

Pendiente para Entrega 4 (≈30% restante): administración de usuarios y
empleados, reportes consolidados (ventas por periodo, top productos),
cancelación de pedidos con reversión de stock, y despliegue en internet (S5).

## Control de acceso por rol (RF21)

- `web/src/config/permisos.js`: **una sola matriz** módulo → roles.
- `requireRole('modulo')` (en `web/src/middleware/auth.js`) protege cada router:
  si el rol no tiene permiso responde **HTTP 403** con mensaje comprensible,
  aunque el usuario escriba la URL a mano.
- El menú y las tarjetas del inicio se generan desde la misma matriz: cada rol
  solo ve los módulos que puede usar.
- El empleado responsable de pedidos, ingresos y devoluciones se toma de la
  sesión, nunca del formulario (evita suplantación).

## Estándares de código aplicados

| Estándar | Cómo se cumple |
|---|---|
| A1 Separación de capas | rutas → modelos → `config/db.js`; ninguna ruta tiene SQL |
| A2 Manejo de errores | `errorHandler.js` traduce errores de MySQL; los `SIGNAL 45000` de triggers/procedimientos se muestran como mensaje de negocio en el mismo formulario |
| A3 Validación | `utils/validate.js`: validaciones de furgón, variante, ingreso y pedido (enteros, fechas, líneas repetidas) |
| A4 Consultas parametrizadas | todas las consultas y `CALL` usan `?`, incluidos los filtros de búsqueda |
| A5/A6 Legibilidad y documentación | encabezado en cada archivo, funciones cortas con comentario cuando acceden a la BD |
| Transacciones | ingresos y pedidos son todo-o-nada (`beginTransaction` / `rollback`) |

## Evidencia (probado en navegador)

Capturas reales en [`../casos-prueba/evidencias/`](../casos-prueba/evidencias/) (`e3_01` a `e3_09`):
inicio por rol (admin/bodeguero/vendedor), 403 del vendedor, inventario con
alertas, formulario de pedido, detalle de pedido con precio mayorista, detalle
de ingreso y kardex filtrado.

## Cómo probar

Ver [`INSTALL.md`](../../INSTALL.md). Credenciales de prueba: `admin/Admin#2026`,
`bodega/Bodega#2026`, `ventas/Ventas#2026` (solo local).

Demostración sugerida (5 minutos):
1. Entrar como `ventas` → solo ve Inventario, Clientes, Pedidos. Escribir `/furgones` en la URL → 403.
2. Nuevo pedido a un cliente **mayorista**, 1 caja → el precio sale con 15 % de descuento y el stock baja 12 pares.
3. Intentar 999 cajas → "Stock insuficiente…" y no se crea ningún pedido.
4. Entrar como `bodega` → registrar un ingreso → el stock sube y aparece la entrada en el Kardex.

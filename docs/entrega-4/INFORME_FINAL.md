# Informe Final — Proyecto Pavanamoon
## Sistema de Gestión de Inventario y Distribución de Calzado Deportivo (Fútbol)

**Universidad Mariano Gálvez de Guatemala — Bases de Datos**

| Integrante | Carné |
|---|---|
| Fernando Rafael Duarte Hernández | 2690-24-7341 |
| Luis Adolfo Martínez Hernández | 2690-23-6092 |
| Cristian Otoniel Pérez Ríos | 2690-22-18389 |
| José Alejandro Cabrera Gramajo | 2690-23-11913 |

**Repositorio:** https://github.com/fduarteh-netizen/proyecto-bd-pavanamoon
**Aplicación publicada:** https://grand-acceptance-production-0ac1.up.railway.app
**SGBD:** MySQL 8 · **Aplicación:** Node.js + Express + EJS

---

## 1. Problema

Pavanamoon es una marca propia de calzado de fútbol para tres segmentos de
edad (niño, juvenil y adulto), con modelos que se distinguen por su tipo de
suela (Hule, Flex, TPU). Vende al detalle (B2C) y al por mayor (B2B). El
crecimiento del volumen de mercadería generó cinco problemas:

1. inventario disperso, sin existencias confiables por modelo, talla y color,
   lo que causa sobreventa o quiebres de stock;
2. ningún historial auditable de entradas, salidas y devoluciones (kardex);
3. recepción por furgón sin trazabilidad de qué llegó en cada carga;
4. ninguna distinción formal entre detalle y mayoreo, lo que impide aplicar
   descuentos de forma consistente;
5. ningún control de acceso por función (bodega, ventas, administración).

## 2. Solución

Una base de datos relacional en MySQL que centraliza el catálogo con sus
variantes, la recepción por furgón, los clientes y los pedidos con descuento
por tipo de cliente, el kardex completo y la seguridad por roles. Las reglas
críticas viven **en la base de datos** (triggers, procedimientos,
restricciones), de modo que se cumplen se use la web, Workbench o un script.
Una aplicación web consume la base con consultas parametrizadas y control por
rol.

**Alcance excluido a propósito:** proveedores externos, logística y aduanas
(evaluado y descartado por el equipo en la Entrega 1).

## 3. Desarrollo por entregas

| Entrega | Contenido principal | Documento |
|---|---|---|
| 1 — Análisis y diseño conceptual | 21 RF, 11 RD, matriz requerimiento → entidad, modelo ER en notación Chen (15 entidades, 2 asociativas N:M), cronograma | [`entrega-1/ENTREGA1_PROPUESTA.md`](../entrega-1/ENTREGA1_PROPUESTA.md) |
| 2 — Diseño lógico e implementación base | Modelo relacional, normalización a 3FN, diccionario de datos, DDL, datos semilla, web ≈30 % | [`entrega-2/ENTREGA2_DISENO_LOGICO.md`](../entrega-2/ENTREGA2_DISENO_LOGICO.md) |
| 3 — Implementación avanzada, seguridad y pruebas | ≥ 50 registros por tabla, 4 vistas, 3 triggers, 1 función + 3 procedimientos, 3 roles de BD, 8 casos de prueba, web ≈70 % | [`entrega-3/ENTREGA3_IMPLEMENTACION.md`](../entrega-3/ENTREGA3_IMPLEMENTACION.md) |
| 4 — Integración, documentación y defensa | Cancelación, devolución acumulada, kardex ligado al pedido, reportes, 4 módulos nuevos (web completa), seguridad y concurrencia, despliegue en Railway | [`ENTREGA4_IMPLEMENTACION.md`](./ENTREGA4_IMPLEMENTACION.md) |

### Correcciones importantes durante el proyecto

- **Entrega 2:** el texto de la Entrega 1 no coincidía con el diagrama
  aprobado, así que se reemplazó `PROVEEDOR`/`COMPRA` por
  `FURGON`/`INGRESO_MERCADERIA`. Además, el precio de venta estaba duplicado
  entre `PRODUCTO` y `PRESENTACION_VENTA`; ahora vive solo en `PRODUCTO`.
- **Entrega 3:** se agregó `tipo_cliente.porcentaje_descuento`, que el diseño
  mencionaba pero no existía. También se corrigió una regresión de la web que
  llamaba a un procedimiento inexistente.
- **Entrega 4:** una devolución podía repetirse sobre la misma línea, y ahora
  se descuenta lo ya devuelto. La base de Railway se había instalado desde un
  dump antiguo y se sincronizó con el repositorio (sección 7).

## 4. Modelo de datos

**19 tablas**, normalizadas a 3FN (demostración en la Entrega 2, sección 3):

| Grupo | Tablas |
|---|---|
| Catálogo | `categoria`, `talla`, `color`, `producto`, `variante_producto`, `presentacion_venta` |
| Recepción | `furgon`, `ingreso_mercaderia`, `detalle_ingreso` |
| Ventas | `tipo_cliente`, `cliente`, `cliente_telefono`, `pedido`, `detalle_pedido` |
| Inventario | `movimiento_stock` (kardex) |
| Personas y acceso | `empleado`, `empleado_telefono`, `usuario`, `rol` |

**Decisiones de diseño:**
- Los teléfonos van en tablas aparte (1FN).
- Una variante se identifica de forma única por producto, talla y color (RD02).
- El stock nunca es negativo (`CHECK`, RD03).
- Los tipos de movimiento son un conjunto cerrado (RD10).
- Los subtotales son columnas generadas y nada calculable se almacena dos
  veces (S7).
- En la Entrega 4, `movimiento_stock.pedido_id` liga cada salida, devolución
  y cancelación con su pedido, con `ON DELETE RESTRICT`.

Diagramas (fuente de verdad del modelo): [`../diagramas/`](../diagramas/).

## 5. Lógica en la base de datos

| Tipo | Objetos | Para qué |
|---|---|---|
| Vistas (6) | `vw_stock_variantes`, `vw_pedidos_resumen`, `vw_kardex`, `vw_ingresos_detalle`, `vw_ventas_diarias`, `vw_ventas_por_modelo` | Consultas y reportes sin repetir JOIN en la app |
| Triggers (3) | `trg_detalle_ingreso_ai`, `trg_detalle_pedido_bi`, `trg_detalle_pedido_ai` | El ingreso suma stock y kardex; no se vende sin stock; la venta descuenta stock, registra el kardex y recalcula el total |
| Función (1) | `fn_calcular_precio_linea` | Precio con el descuento del tipo de cliente; nadie digita precios |
| Procedimientos (4) | `sp_crear_pedido`, `sp_agregar_linea_pedido`, `sp_registrar_devolucion`, `sp_cancelar_pedido` | Pedido válido, línea con precio calculado, devolución acumulada y cancelación con reintegro, todo atómico |
| Roles de BD (3) | `rol_administrador`, `rol_bodeguero`, `rol_vendedor` | Privilegios mínimos; el vendedor opera los pedidos solo mediante procedimientos |

**Concurrencia.** Las lecturas de stock y de pedido usan `FOR UPDATE`, así que
no hay sobreventa ni deadlocks con pedidos simultáneos. Lo comprueban las
pruebas INT-02 a INT-07.

## 6. Aplicación web

11 módulos, con permisos centralizados en `web/src/config/permisos.js`:

| Módulo | Administrador | Bodeguero | Vendedor |
|---|---|---|---|
| Productos, Inventario (variantes), Furgones, Ingresos | ✅ | ✅ | Solo consulta de inventario |
| Clientes, Pedidos | ✅ | — | ✅ |
| Kardex | ✅ | ✅ | — |
| Reportes, Empleados, Usuarios, Catálogos | ✅ | — | — |

_(El detalle exacto por ruta está en `permisos.js` y se verifica con SEG-08.)_

**Seguridad web:**
- Contraseñas con bcrypt.
- Consultas parametrizadas.
- Sesión regenerada al iniciar sesión, cookie `HttpOnly`/`SameSite` (`Secure` en producción).
- Protección CSRF por origen, cabeceras de seguridad y bloqueo por intentos fallidos.
- En producción la app no arranca sin un secreto de sesión fuerte.

### 6.1 Alcance del CRUD

| Tabla principal | Crear | Consultar | Editar | Eliminar |
|---|---|---|---|---|
| `producto`, `variante_producto`, `cliente` (+ teléfonos), `furgon`, `empleado` (+ teléfonos), `usuario`, catálogos (`categoria`, `talla`, `color`, `tipo_cliente`, `presentacion_venta`) | ✅ | ✅ | ✅ | ✅ (con protección si hay historial) |
| `ingreso_mercaderia` + `detalle_ingreso` | ✅ | ✅ | — | — |
| `pedido` + `detalle_pedido` | ✅ | ✅ | Cambio de estado: completar | Cancelar (`sp_cancelar_pedido`) o devolver (`sp_registrar_devolucion`) |
| `movimiento_stock` | Solo por triggers y procedimientos | ✅ (kardex) | — | — |

**Justificación.** Los ingresos y los pedidos son **documentos transaccionales**:
al registrarse cambian el stock y generan movimientos en el kardex. Editarlos
o borrarlos descuadraría el inventario y destruiría la auditoría que exigen
RF15 y RF16. Por eso se corrigen como lo hace un sistema contable, con una
operación inversa que también queda registrada:

- un pedido pendiente se **cancela** (el stock vuelve y el kardex registra `cancelacion`);
- un pedido completado admite **devoluciones** (`devolucion_cliente`);
- para un ingreso erróneo, la base ya prevé el tipo de movimiento `ajuste` (RD10), pero **no tiene pantalla en la web**: queda como trabajo futuro (sección 9).

La base lo garantiza: `fk_movimiento_pedido` (`ON DELETE RESTRICT`) impide
borrar un pedido con kardex (caso CP4-06), y el detalle de un pedido
cancelado se conserva como evidencia.

## 7. Despliegue

La aplicación corre en Railway, con despliegue automático desde `main`
(directorio raíz `/web`) y MySQL 8 por conexión privada. El acceso público a
MySQL se abrió solo temporalmente para instalar y sincronizar.

**Incidente y corrección.** La base de producción se instaló primero desde un
dump de una base local que tenía objetos de versiones anteriores: 9 vistas y
11 rutinas, frente a 6 y 5 en el repositorio. Esto rompía el filtro de
pedidos por cliente (HTTP 500). Se corrigió el 25/10/2026 con un script
probado antes en una base aislada, que no tocó tablas ni datos. Desde
entonces, `railway_verificar.sql` da `IGUAL AL REPOSITORIO`. Detalle en
[`despliegue-railway/`](./despliegue-railway/). También se cambió la
contraseña del administrador, que se había compartido en una conversación.

## 8. Calidad y pruebas

| Batería | Casos | Resultado |
|---|---|---|
| Entrega 2: restricciones de integridad | 10 | 10/10 |
| Entrega 3: SQL y web | 8 | 8/8 |
| Entrega 4: SQL (CP4-01 a CP4-07) | 7 | Todos como se esperaba |
| Entrega 4: web y catálogos (CP4-08 a CP4-22) | 111 comprobaciones | 111/111 |
| Seguridad (SEG) | 11 | 11/11 |
| Concurrencia (INT) | 7 | 7/7 |
| Unitarias | 10 | 10/10 |

Los resultados de la Entrega 4 se obtuvieron instalando la base desde cero
en un entorno aislado. La verificación en Railway con datos ficticios y la
re-ejecución por el equipo están en
[`../casos-prueba/CASOS_PRUEBA_ENTREGA4.md`](../casos-prueba/CASOS_PRUEBA_ENTREGA4.md).
Cada entrega tiene su certificación en [`../certificaciones/`](../certificaciones/).

**Uso de IA.** Se declara en la bitácora
([`../bitacora-ia/BITACORA_IA.md`](../bitacora-ia/BITACORA_IA.md), Entradas 1 a
20). Allí consta qué se pidió, qué se obtuvo y cómo lo validó el grupo,
incluidos los errores de la IA detectados en la validación. Ver también la
[declaración de integridad](./DECLARACION_INTEGRIDAD.md).

## 9. Limitaciones y trabajo futuro

- **Zona horaria:** el servidor usa UTC, así que las fechas se ven 6 horas
  adelantadas. La corrección está identificada (`SET time_zone` por conexión)
  y no se aplicó para no cambiar el código cerca de la entrega.
- **Sesiones en memoria:** la app debe correr en una sola instancia. Se
  resolvería con un almacén de sesiones en la base de datos.
- **Roles de MySQL:** se demuestran en la instalación local. En Railway la app
  usa la cuenta del servicio.
- **Trabajo futuro:** anulación formal de ingresos (con movimiento de
  ajuste), recuperación de contraseña, reportes por bodega y exportación a
  PDF o Excel.

## 10. Conclusiones

1. Poner las reglas críticas en la base de datos (stock, precios, kardex)
   hizo que se cumplan sin depender de la interfaz. Las pruebas de
   concurrencia lo confirmaron con operaciones simultáneas.
2. El kardex ligado al documento de origen permite auditar y revertir
   operaciones sin borrar historia.
3. La normalización a 3FN evitó inconsistencias. Las dos correcciones de
   diseño (proveedor → furgón y el precio duplicado) se detectaron
   comparando el texto con el diagrama.
4. El incidente de Railway mostró que producción debe instalarse desde los
   scripts versionados y verificarse contra el repositorio, no desde una
   copia de desarrollo.
5. La IA aceleró el trabajo, pero cada resultado tuvo que validarse. La
   bitácora registra tanto los aportes como los errores corregidos.

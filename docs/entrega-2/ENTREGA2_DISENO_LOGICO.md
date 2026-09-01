# ENTREGA 2 — Diseño Lógico, Diccionario de Datos e Implementación Base
## Sistema de Gestión de Inventario y Distribución de Calzado — Pavanamoon

**Universidad Mariano Gálvez de Guatemala**
**Curso:** Bases de Datos
**SGBD:** MySQL 8.x
**Fecha:** Semanas 4–5

---

## 1. Alcance de esta entrega y nota de corrección importante

### 1.1 Inconsistencia detectada entre el texto y el diagrama de la Entrega 1

Al iniciar esta entrega se detectó que el repositorio contenía **dos versiones
distintas del modelo conceptual**, que no coincidían entre sí:

- El documento de texto `docs/entrega-1/ENTREGA1_PROPUESTA.md` describe un modelo con
  `PROVEEDOR`, `COMPRA` y `DETALLE_COMPRA`.
- El diagrama ER vigente (`docs/diagramas/Pavanamoon_er_chen.drawio` /
  `pavanaDiagrama.png`), que según la propia **Bitácora de IA, Entrada 7**, es el
  rediseño final aprobado por el equipo, usa en cambio `FURGON`,
  `INGRESO_MERCADERIA` y `DETALLE_INGRESO` (sin catálogo de proveedores), agrega
  `TIPO_CLIENTE` como catálogo independiente y `PRESENTACION_VENTA` como entidad
  nueva, y clasifica `PRODUCTO` por edad (niño/juvenil/adulto) y tipo de suela
  (hule/flex/tpu) en vez de por categoría deportivo/casual.

El documento de texto de la Entrega 1 nunca se actualizó después del rediseño
documentado en la Entrada 7 de la bitácora. **Esta entrega usa como fuente de verdad
el diagrama ER** — específicamente `docs/diagramas/Pavanamoon_er_chen_corregido.drawio`,
la versión que el equipo subió después con 3 correcciones adicionales de
cardinalidad/llaves (ver Entrada 9 de la bitácora y Sección 1.2 de este documento) —
por ser el artefacto que el equipo confirmó como vigente, y dejamos constancia
explícita de la inconsistencia aquí en vez de reescribir retroactivamente el
documento ya entregado y etiquetado como `entrega-1` (evita alterar un entregable ya
calificado; la corrección queda documentada como parte de la trazabilidad exigida por
el estándar D4).

> **Pendiente recomendado para el equipo antes de la defensa oral:** sincronizar la
> Sección 7 de `ENTREGA1_PROPUESTA.md` con el diagrama vigente, o al menos anexar una
> nota de errata, para que cualquier persona que revise el repositorio desde el
> principio no encuentre la contradicción. Esta entrega ya deja la corrección
> documentada por si el catedrático solo revisa a partir de aquí.

### 1.2 Correcciones aplicadas por el equipo sobre el diagrama (versión corregida)

El equipo entregó una versión corregida del diagrama
(`Pavanamoon_er_chen_corregido.drawio`) que resuelve las imprecisiones detectadas y
ajusta dos cardinalidades. Esta es la versión que se usa como fuente de verdad final:

| # | Elemento | Diagrama original | Diagrama corregido | Impacto en el DDL |
|---|---|---|---|---|
| 1 | `INGRESO_MERCADERIA.empleado_id` | Aparecía subrayado (como PK) | Ya no está subrayado; se marcó explícitamente como `(FK)` | Confirma que la PK es solo `ingreso_id`; sin cambios adicionales |
| 2 | Relación `FURGON`–`INGRESO_MERCADERIA` ("transporta") | `FURGON(1,1)` – `INGRESO_MERCADERIA(1,1)` (1:1 estricta) | `FURGON(0,N)` – `INGRESO_MERCADERIA(1,1)` | Ya **no** es 1:1: un furgón puede corresponder a varios ingresos (ej. descargas parciales). Se **quitó** `UNIQUE(furgon_id)` de `ingreso_mercaderia`; ahora es una FK simple |
| 3 | `DETALLE_PEDIDO` | Sin llave primaria explícita (se infería una PK sustituta) | PK compuesta explícita **(pedido_id, variante_id)**; `presentacion_id` queda fuera de la llave | Se reemplazó la PK sustituta `detalle_pedido_id` por la compuesta `(pedido_id, variante_id)`: una misma variante aparece como máximo una vez por pedido |
| 4 | `VARIANTE_PRODUCTO.sku` | Marcado como atributo derivado (línea punteada) | Marcado como llave candidata (subrayado) | Se mantiene como `UNIQUE`, generado por la aplicación (no por SQL); se ajustó la redacción para no llamarlo "derivado" |
| 5 | Relación `ROL`–`USUARIO` ("tiene") | `ROL(1,1)` – `USUARIO(0,N)` | `ROL(1,N)` – `USUARIO(1,1)` | Corrige la dirección de la relación (cada usuario tiene exactamente un rol); ya coincidía con la implementación (`usuario.rol_id NOT NULL`), sin cambios en el DDL |
| 6 | Nombres de relaciones | Dos relaciones distintas compartían el nombre `corresponde_a` | Renombradas a `corresponde_a_ingreso` y `corresponde_a_pedido` | Solo mejora de legibilidad del diagrama, sin impacto en el DDL |
| 7 | `PRESENTACION_VENTA.precio_venta` | El diagrama tenía un atributo `precio_venta` en `PRESENTACION_VENTA`, además del ya existente en `PRODUCTO` — dos fuentes de precio para el mismo concepto | Se **eliminó** `precio_venta` de `PRESENTACION_VENTA` (diagrama, DDL, diccionario y semilla). El precio vive **una sola vez** en `producto.precio_venta` (precio por par); `detalle_pedido.precio_unitario` es el precio realmente aplicado en cada línea, calculado por la aplicación | Evita que el precio de un mismo producto se pueda leer de dos lugares distintos y quedar desincronizado; además `MAYORISTA` se confirma como valor de `tipo_cliente`, nunca como fila de `presentacion_venta` (que ahora solo representa `unidad`/`caja`, sin connotación de segmento de cliente) |

Se mantienen, además, las dos adiciones justificadas de la versión anterior de este
documento (el diagrama corregido no las incorporó, pero siguen siendo necesarias
para que el sistema sea operable):

| # | Elemento | Adición aplicada | Justificación |
|---|---|---|---|
| A | `CLIENTE` | `nombre_cliente VARCHAR(150) NOT NULL` | Sin un nombre no es posible identificar al cliente en pantallas, pedidos ni reportes |
| B | `PEDIDO` | `estado ENUM('pendiente','completado','cancelado')` | Necesario para distinguir pedidos activos de cancelados en la operación diaria |

También se mantiene el ajuste de `movimiento_stock.tipo_movimiento` a
`('entrada','salida','devolucion_cliente','ajuste')`, ya que el diagrama no detalla
los valores permitidos de ese ENUM y el concepto de "devolución a proveedor" ya no
aplica al modelo basado en furgones.

### 1.3 Pendiente manual: archivo `.mwb` (MySQL Workbench)

El modelo relacional editable en `docs/diagramas/Modelo_Entidad_R_Pavanamoon.mwb`
todavía tiene, dentro de la tabla `presentacion_venta`, la columna `precio_venta`
que se eliminó en el punto 7 de la Sección 1.2. El archivo `.mwb` es un formato
binario propietario de MySQL Workbench (ZIP + XML con checksums internos por
estructura); no es seguro editarlo por fuera de la aplicación real sin arriesgar
corromperlo. Por eso:

- El **PNG y PDF del modelo relacional** (`Modelo_Entidad_Relacion.png`,
  `Modelo_Entidad_R_Pavanamoon.pdf`) se **regeneraron directamente desde el DDL
  real** (`sql/ddl/`), por lo que **sí** están 100% sincronizados (sin
  `presentacion_venta.precio_venta`, con la PK compuesta de `detalle_pedido`, etc.).
- El `.mwb` editable queda con esa única columna de más. **Acción pendiente para
  el equipo:** abrir el archivo en MySQL Workbench, eliminar la columna
  `precio_venta` de `presentacion_venta`, y volver a exportar el PNG/PDF (o
  confirmar que los ya generados siguen siendo válidos). Es un cambio de ~30
  segundos una vez que alguien del equipo tenga Workbench instalado.

### 1.3 Alcance de la entrega

Esta entrega cubre el **diseño lógico** derivado del diagrama ER vigente: el modelo
relacional completo, la normalización hasta 3FN (con ejemplo), el diccionario de
datos de las 19 tablas resultantes, los scripts DDL ejecutables (`sql/ddl/`), datos
semilla mínimos (`sql/dml/00_seed_minimo.sql`) y el 30% de la aplicación web (login +
layout + 2 módulos CRUD: Producto y Cliente), documentado en
`docs/entrega-2/AVANCE_WEB.md`.

---

## 2. Del modelo conceptual al modelo relacional

Se aplicaron las reglas estándar de transformación ER → Relacional sobre las 15
entidades principales y las relaciones N:M del diagrama vigente:

| Regla de transformación | Aplicación en Pavanamoon |
|---|---|
| Toda entidad fuerte → una tabla, con su PK. | Las 15 entidades del diagrama se convierten en 15 tablas. |
| Relación 1:N → FK en el lado "N". | Ej.: `producto.categoria_id`; `variante_producto.producto_id/.talla_id/.color_id`; `cliente.tipo_cliente_id`. |
| Relación 1:1 con participación total de un lado → FK con UNIQUE. | `usuario.empleado_id` (relación `posee`). |
| Relación 1:N con FK simple. | `ingreso_mercaderia.furgon_id` (relación `transporta`, FURGON(0,N)–INGRESO_MERCADERIA(1,1): un furgón puede tener varios ingresos). |
| Relación N:M → tabla asociativa con FK de ambas entidades + atributos propios. | `detalle_ingreso` (INGRESO_MERCADERIA↔VARIANTE_PRODUCTO) y `detalle_pedido` (PEDIDO↔VARIANTE_PRODUCTO, y además FK hacia `presentacion_venta` por la relación "se_utiliza_en"). |
| Atributo multivaluado → tabla hija con PK compuesta. | `empleado_telefono` y `cliente_telefono` (ver 1FN, Sección 3.1). |
| Atributo derivado → columna generada o recalculada por trigger/procedimiento. | `subtotal` en `detalle_ingreso`/`detalle_pedido` (`GENERATED ALWAYS AS ... STORED`); `total_pedido` se completa en Entrega 3. |

**Resultado:** 19 tablas (15 entidades principales + 2 tablas asociativas N:M + 2
tablas de teléfonos derivadas de la normalización 1FN). Ver el DDL ejecutable en
`sql/ddl/` y el diccionario completo en la Sección 4.

---

## 3. Normalización — demostración hasta 3FN

### 3.1 Primera Forma Normal (1FN) — eliminar atributos multivaluados

El diagrama ER marca explícitamente `telefono` como **multivaluado** (borde grueso)
en `EMPLEADO` y `CLIENTE`. Guardarlo como una sola columna de texto
(`"5555-1111, 5555-2222"`) violaría 1FN: el valor no sería atómico y sería imposible
indexar o garantizar unicidad por número.

**Antes (no cumple 1FN):**

| cliente_id | nombre_cliente | telefono |
|---|---|---|
| 12 | Comercial El Rápido | `5555-1111, 5555-2222` |

**Después (1FN — tabla hija con una fila por valor atómico):**

`cliente` (cliente_id, nombre_cliente, …) — sin columna telefono
`cliente_telefono` (cliente_id FK, telefono) — PK compuesta

| cliente_id | telefono |
|---|---|
| 12 | 5555-1111 |
| 12 | 5555-2222 |

Se aplicó la misma solución a `empleado` → `empleado_telefono`.

### 3.2 Segunda Forma Normal (2FN) — eliminar dependencias parciales

2FN aplica a tablas con **clave primaria compuesta**: `empleado_telefono`,
`cliente_telefono` y `detalle_ingreso` (PK compuesta `ingreso_id + variante_id`, tal
como la define el diagrama ER).

**Caso analizado:** en `detalle_ingreso`, ¿depende `costo_unitario` únicamente de
`variante_id` (parte de la clave) y no de la clave completa? **No** — el costo pagado
por una variante puede cambiar entre un furgón y otro (negociación, tipo de cambio,
promoción del proveedor de origen), por lo que `costo_unitario` depende de la
combinación completa `(ingreso_id, variante_id)`, no de una parte. Esto confirma que
la tabla cumple 2FN sin ambigüedad.

Para `detalle_pedido`, el diagrama ER corregido define una PK compuesta
`(pedido_id, variante_id)` — sin incluir `presentacion_id` en la llave — porque una
misma variante debe aparecer como máximo una vez por pedido; si el cliente compra la
misma variante en dos presentaciones distintas dentro del mismo pedido, se registran
como líneas de pedidos separados o se resuelve a nivel de aplicación antes de
insertar. Esto también cumple 2FN sin ambigüedad: `precio_unitario` y `cantidad`
dependen de la combinación completa `(pedido_id, variante_id)`.

### 3.3 Tercera Forma Normal (3FN) — eliminar dependencias transitivas

**Ejemplo de diseño incorrecto que se descartó** (dependencia transitiva):

Si `variante_producto` hubiera almacenado directamente `tipo_suela` y
`nombre_categoria` (para "evitar un JOIN"), existiría esta cadena de dependencias:

```
variante_id → producto_id → tipo_suela, nombre_categoria
```

`tipo_suela`/`nombre_categoria` no dependen de `variante_id` (la PK de
`variante_producto`), sino de `producto_id`, que es un atributo no clave de la misma
tabla → **dependencia transitiva**, viola 3FN.

**Antes (viola 3FN):**

| variante_id (PK) | producto_id | tipo_suela | nombre_categoria | talla_id | color_id | stock_actual |
|---|---|---|---|---|---|---|
| 501 | 30 | flex | juvenil | 3 (talla 38) | 1 (negro) | 12 |

Problemas: si el modelo 30 cambia de tipo de suela en un rediseño, hay que
actualizar **todas** sus variantes (anomalía de actualización); si se elimina la
última variante de un producto, se pierde el dato de suela/categoría (anomalía de
borrado); y el dato queda duplicado en cada variante (redundancia, contradice S7).

**Después (cumple 3FN — implementado en `sql/ddl/04_tablas_producto.sql`):**

`producto` (producto_id PK, categoria_id FK, modelo, tipo_suela, precio_venta)
`variante_producto` (variante_id PK, producto_id FK, talla_id FK, color_id FK, sku, stock_actual, stock_minimo)

`tipo_suela` y `categoria_id` viven **una sola vez** en `producto`; la aplicación usa
`JOIN` para mostrar "Pavanamoon modelo X, suela flex, categoría juvenil, talla 38,
negro" sin duplicar datos. El mismo razonamiento se aplicó a `pedido` (el nombre del
cliente no se repite en `detalle_pedido`, se obtiene por JOIN con `cliente`) y a
`ingreso_mercaderia` (los datos del furgón no se repiten en `detalle_ingreso`).

**Conclusión:** las 19 tablas del modelo relacional de Pavanamoon cumplen 1FN, 2FN y
3FN: cada atributo no clave depende de la clave completa, y solo de la clave (Codd).

---

## 4. Diccionario de datos

> Convención: **PK** llave primaria, **FK** llave foránea, **UK** único, **NN** not
> null. Todas las tablas usan motor InnoDB y `snake_case` (estándar S1). Las filas
> marcadas "**(agregado)**" no estaban en el diagrama ER; ver justificación en §1.2.

### 4.1 rol
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| rol_id | INT | PK, AUTO_INCREMENT | Identificador del rol |
| nombre_rol | VARCHAR(50) | NN, UK | administrador / bodeguero / vendedor |
| descripcion | VARCHAR(255) | NULL | Detalle del rol |

### 4.2 categoria
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| categoria_id | INT | PK, AUTO_INCREMENT | Identificador |
| nombre_categoria | VARCHAR(50) | NN, UK, CHECK IN ('nino','juvenil','adulto') | Categoría por edad |

### 4.3 talla
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| talla_id | INT | PK, AUTO_INCREMENT | Identificador |
| valor_talla | VARCHAR(10) | NN, UK | Valor de la talla |

### 4.4 color
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| color_id | INT | PK, AUTO_INCREMENT | Identificador |
| nombre_color | VARCHAR(40) | NN, UK | Nombre del color |

### 4.5 tipo_cliente
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| tipo_cliente_id | INT | PK, AUTO_INCREMENT | Identificador |
| nombre | VARCHAR(50) | NN, UK | individual / mayorista |
| descripcion | VARCHAR(255) | NULL | Detalle del segmento |

### 4.6 presentacion_venta
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| presentacion_id | INT | PK, AUTO_INCREMENT | Identificador |
| nombre | VARCHAR(50) | NN, UK | unidad / caja |
| cantidad_pares | INT | NN, CHECK > 0 | Pares que representa la presentación |
| estado | ENUM('activo','inactivo') | NN, DEFAULT 'activo' | Disponibilidad |

> **Nota de consistencia de precio** (ver Sección 1.2, punto 7): esta tabla
> **no tiene columna de precio**. El precio vive una sola vez en
> `producto.precio_venta` (precio de venta por par). `detalle_pedido.precio_unitario`
> es el precio realmente aplicado en cada línea (permite reflejar el descuento del
> `tipo_cliente` u otras condiciones comerciales), calculado por la aplicación a
> partir de `producto.precio_venta`, nunca almacenado ni editado en
> `presentacion_venta`. `MAYORISTA` es un valor de `tipo_cliente`, **no** una
> presentación de venta.

### 4.7 empleado
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| empleado_id | INT | PK, AUTO_INCREMENT | Identificador |
| nombres_apellidos | VARCHAR(150) | NN | Nombre completo |
| dpi | CHAR(13) | NN, UK | Documento de identificación |

### 4.8 empleado_telefono *(normalización 1FN)*
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| empleado_id | INT | PK compuesta, FK → empleado | Empleado dueño del número |
| telefono | VARCHAR(20) | PK compuesta, NN | Número telefónico |

### 4.9 usuario
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| usuario_id | INT | PK, AUTO_INCREMENT | Identificador |
| username | VARCHAR(40) | NN, UK | Usuario de login |
| password_hash | VARCHAR(255) | NN | Hash bcrypt |
| estado | ENUM('activo','inactivo') | NN, DEFAULT 'activo' | Estado de la cuenta |
| fecha_creacion | DATETIME | NN, DEFAULT CURRENT_TIMESTAMP | Alta de la cuenta |
| rol_id | INT | NN, FK → rol | Rol asignado |
| empleado_id | INT | NN, UK, FK → empleado | Empleado dueño (1:1) |

### 4.10 cliente
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| cliente_id | INT | PK, AUTO_INCREMENT | Identificador |
| tipo_cliente_id | INT | NN, FK → tipo_cliente | Segmento B2C/B2B |
| nombre_cliente | VARCHAR(150) | NN | **(agregado)** Nombre o razón social |
| nit | VARCHAR(15) | NN, UK | Identificador fiscal |

### 4.11 cliente_telefono *(normalización 1FN)*
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| cliente_id | INT | PK compuesta, FK → cliente | Cliente dueño del número |
| telefono | VARCHAR(20) | PK compuesta, NN | Número telefónico |

### 4.12 producto
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| producto_id | INT | PK, AUTO_INCREMENT | Identificador |
| categoria_id | INT | NN, FK → categoria | Categoría por edad |
| modelo | VARCHAR(100) | NN | Modelo del calzado |
| tipo_suela | ENUM('hule','flex','tpu') | NN | Tipo de suela |
| precio_venta | DECIMAL(10,2) | NN, CHECK > 0 | Precio de venta base |

### 4.13 variante_producto
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| variante_id | INT | PK, AUTO_INCREMENT | Identificador |
| producto_id | INT | NN, FK → producto | Producto base |
| talla_id | INT | NN, FK → talla | Talla |
| color_id | INT | NN, FK → color | Color |
| sku | VARCHAR(40) | NN, UK | Código único derivado, generado por la aplicación |
| stock_actual | INT | NN, DEFAULT 0, CHECK ≥ 0 | Existencias actuales |
| stock_minimo | INT | NN, DEFAULT 5, CHECK ≥ 0 | Umbral de reabastecimiento |
| *(UK compuesta)* | — | UNIQUE(producto_id, talla_id, color_id) | Combinación única |

### 4.14 furgon
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| furgon_id | INT | PK, AUTO_INCREMENT | Identificador |
| numero_furgon | VARCHAR(30) | NN, UK | Número de furgón |
| fecha_llegada | DATE | NN | Fecha de llegada |
| procedencia | VARCHAR(100) | NULL | Origen de la mercadería |
| transportista | VARCHAR(100) | NULL | Empresa transportista |
| estado | ENUM('en_transito','recibido','cancelado') | NN, DEFAULT 'en_transito' | Estado del furgón |

### 4.15 ingreso_mercaderia
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| ingreso_id | INT | PK, AUTO_INCREMENT | Identificador |
| furgon_id | INT | NN, FK → furgon | Furgón del que procede (1:N — un furgón puede tener varios ingresos) |
| empleado_id | INT | NN, FK → empleado | Responsable del ingreso |
| fecha_ingreso | DATETIME | NN, DEFAULT CURRENT_TIMESTAMP | Fecha/hora de registro |
| bodega_destino | VARCHAR(60) | NULL | Bodega donde se almacenó |
| estado | ENUM('pendiente','completado','cancelado') | NN, DEFAULT 'completado' | Estado del ingreso |

### 4.16 detalle_ingreso *(resuelve N:M Ingreso–Variante)*
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| ingreso_id | INT | PK compuesta, FK → ingreso_mercaderia | Ingreso al que pertenece |
| variante_id | INT | PK compuesta, FK → variante_producto | Variante recibida |
| cantidad | INT | NN, CHECK > 0 | Unidades recibidas |
| costo_unitario | DECIMAL(10,2) | NN, CHECK > 0 | Costo por unidad |
| subtotal | DECIMAL(12,2) | GENERATED (cantidad × costo_unitario) | {derivado} |

### 4.17 pedido
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| pedido_id | INT | PK, AUTO_INCREMENT | Identificador |
| cliente_id | INT | NN, FK → cliente | Cliente |
| empleado_id | INT | NN, FK → empleado | Vendedor responsable |
| fecha_pedido | DATETIME | NN, DEFAULT CURRENT_TIMESTAMP | Fecha/hora de registro |
| total_pedido | DECIMAL(12,2) | NN, DEFAULT 0, CHECK ≥ 0 | {derivado}; procedimiento en Entrega 3 |
| estado | ENUM('pendiente','completado','cancelado') | NN, DEFAULT 'pendiente' | **(agregado)** Estado del pedido |

### 4.18 detalle_pedido *(resuelve N:M Pedido–Variante, y referencia Presentación)*
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| pedido_id | INT | PK compuesta, FK → pedido | Pedido al que pertenece |
| variante_id | INT | PK compuesta, FK → variante_producto | Variante vendida (única por pedido) |
| presentacion_id | INT | NN, FK → presentacion_venta | Unidad de venta (unidad/caja) |
| cantidad | INT | NN, CHECK > 0 | Cantidad de esa presentación |
| precio_unitario | DECIMAL(10,2) | NN, CHECK > 0 | Precio aplicado en esa línea |
| subtotal | DECIMAL(12,2) | GENERATED (cantidad × precio_unitario) | {derivado} |

### 4.19 movimiento_stock
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| movimiento_id | INT | PK, AUTO_INCREMENT | Identificador |
| variante_id | INT | NN, FK → variante_producto | Variante afectada |
| empleado_id | INT | NN, FK → empleado | Responsable |
| tipo_movimiento | ENUM('entrada','salida','devolucion_cliente','ajuste') | NN | Tipo de movimiento |
| cantidad | INT | NN, CHECK > 0 | Unidades movidas |
| fecha_movimiento | DATETIME | NN, DEFAULT CURRENT_TIMESTAMP | Fecha/hora |

---

## 5. Resumen de cumplimiento de requisitos mínimos (actualizado en Entrega 2)

| Requisito mínimo del proyecto | Cumplimiento |
|---|---|
| ≥8 entidades principales | ✅ 15 entidades principales + 2 asociativas + 2 de normalización (19 tablas totales) |
| ≥2 relaciones N:M resueltas | ✅ `detalle_ingreso` (Ingreso↔Variante) y `detalle_pedido` (Pedido↔Variante, con FK adicional a Presentación) |
| Normalización hasta 3FN con ejemplo | ✅ Sección 3 de este documento |
| ≥15 restricciones explícitas | ✅ 19 PK + 20 FK + 13 UNIQUE + 10 CHECK + NOT NULL en prácticamente todas las columnas (ver `sql/ddl/`) |
| Scripts DDL ejecutables | ✅ `sql/ddl/01` a `sql/ddl/05` (orden de ejecución en `INSTALL.md`), validados sintácticamente con un parser de MySQL |
| ≥2 triggers / procedimientos | ⏳ Planeado para Entrega 3 (cálculo de `total_pedido`, actualización de stock al registrar ingresos/ventas) |
| ≥3 roles de seguridad a nivel de BD | ⏳ La tabla `rol` ya tiene 3 roles cargados (seed); los roles de MySQL (`CREATE USER`/`GRANT`) van en Entrega 3 (`sql/security/`) |
| Datos de prueba ≥50 registros/tabla | ⏳ Planeado para Entrega 3 (`sql/dml/`); esta entrega solo incluye datos semilla mínimos para probar login y catálogos |

---

## 6. Declaración de uso de agentes de IA

El equipo utilizó Claude (Anthropic) para: **detectar y documentar la inconsistencia
entre el texto y el diagrama de la Entrega 1** (Sección 1.1), extraer
programáticamente la estructura exacta del archivo `.drawio` vigente (entidades,
atributos y cardinalidades) para evitar transcribir el modelo a mano y arriesgar
errores, derivar el modelo relacional aplicando las reglas de transformación
estándar, redactar la demostración de normalización 1FN/2FN/3FN con ejemplos del
propio dominio de negocio, generar y validar sintácticamente los scripts DDL, y
construir la base de la aplicación web (login + 2 CRUD) en Node.js/Express. El
detalle completo, con prompts y validación del equipo, se documenta en
`docs/bitacora-ia/BITACORA_IA.md` (Entrada 8).

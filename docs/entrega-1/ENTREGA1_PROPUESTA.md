# ENTREGA 1 — Análisis, Propuesta y Diseño Conceptual
## Sistema de Gestión de Inventario y Distribución de Calzado Deportivo (Fútbol) — Pavanamoon

**Universidad Mariano Gálvez de Guatemala**
**Curso:** Bases de Datos
**SGBD seleccionado:** MySQL *(confirmado — dentro de las opciones permitidas por la guía del proyecto, Sección 3)*
**Empresa:** Pavanamoon (marca propia de calzado deportivo)
**Fecha:** Semana 1–3

**Integrantes:**

| Nombre completo | Carné |
|---|---|
| Fernando Rafael Duarte Hernández | 2690-24-7341 |
| Luis Adolfo Martínez Hernández | 2690-23-6092 |
| Cristian Otoniel Pérez Ríos | 2690-22-18389 |
| José Alejandro Cabrera Gramajo | 2690-23-11913 |

---

## 1. Descripción del problema real

Pavanamoon es una marca propia dedicada al diseño, fabricación y distribución de **calzado deportivo especializado en fútbol** (modelos propios, ej. "Terminator T-800", "Striker X"), destinado a tres segmentos de edad: **niño, juvenil y adulto**. La empresa atiende dos canales de venta con dinámicas distintas:

- **B2C (detalle):** clientes individuales que compran unidades sueltas.
- **B2B (mayoreo):** comercios y revendedores que compran en volumen y acceden a condiciones diferenciadas (descuentos por tipo de cliente).

Al ser marca propia, cada modelo se distingue técnicamente por su **tipo de suela** (Hule, Flex o TPU), atributo determinante para el uso previsto del calzado según la superficie de juego. El crecimiento en volumen de mercadería ha generado los siguientes problemas operativos que la empresa busca resolver mediante un sistema de base de datos relacional centralizado:

1. **Control de inventario disperso o manual:** no existe trazabilidad confiable de existencias por modelo, categoría de edad, talla y color, lo que genera sobreventas o quiebres de stock no detectados a tiempo.
2. **Falta de historial de movimientos:** entradas por compra, salidas por venta, y devoluciones no quedan registradas de forma auditable (kardex).
3. **Recepción de mercadería sin trazabilidad de furgón:** la mercadería llega en furgones completos; actualmente no existe una estructura que permita rastrear qué mercadería llegó en cada furgón, dificultando la identificación de problemas de calidad o faltantes por entrega.
4. **Segmentación de clientes inexistente en el sistema:** no se diferencia formalmente entre venta al detalle y venta al por mayor, lo que impide aplicar reglas de negocio (precios, descuentos) de forma consistente.
5. **Sin control de acceso por rol:** cualquier persona con acceso al sistema actual puede realizar cualquier operación, sin distinción entre funciones de bodega, ventas y administración.

## 2. Propuesta de solución

Se propone diseñar e implementar un **sistema de base de datos relacional** en MySQL que centralice:

- Catálogo de modelos propios de calzado de fútbol, clasificados por categoría de edad (Niño/Juvenil/Adulto) y tipo de suela (Hule/Flex/TPU), con variantes por talla y color, cada una con su propio nivel de stock.
- Gestión de furgones e ingresos de mercadería, registrando el furgón mediante el cual llega cada carga, el ingreso a bodega y el detalle de los productos recibidos (sin gestionar logística externa ni aduanas).
- Gestión de clientes (individuales y mayoristas) y procesamiento de pedidos/ventas con su detalle.
- Registro completo de movimientos de stock (entradas, salidas, devoluciones de cliente y devoluciones), permitiendo reconstruir el kardex de cualquier variante de producto.
- Seguridad basada en roles (Administrador, Bodeguero, Vendedor) con privilegios diferenciados a nivel de base de datos.

El sistema se acompañará de una interfaz web mínima (a partir de la Entrega 2) que consumirá esta base de datos, siguiendo los estándares de calidad de código y seguridad definidos en la guía del proyecto (consultas parametrizadas, separación de capas, manejo controlado de errores).

## 3. Alcance de la Entrega 1

Esta entrega cubre exclusivamente la fase de **análisis y diseño conceptual**: identificación de requerimientos, modelo Entidad-Relación en notación Chen, y planificación del proyecto. No incluye implementación de DDL (que inicia en Entrega 2, tras aprobación del ER, según la Consideración General #9 de la guía).

---

## 4. Requerimientos Funcionales (RF)

### Módulo 1 — Gestión de Inventario de Calzado de Fútbol
| ID | Requerimiento |
|---|---|
| RF01 | El sistema debe permitir registrar modelos propios de calzado de fútbol, clasificados por categoría de edad (Niño, Juvenil, Adulto) y tipo de suela (Hule, Flex, TPU). |
| RF02 | El sistema debe permitir registrar variantes de un modelo por combinación única de talla y color, cada una con su propio stock. |
| RF03 | El sistema debe permitir consultar el stock disponible de cualquier variante en tiempo real. |
| RF04 | El sistema debe permitir identificar variantes cuyo stock esté por debajo de un umbral mínimo definido. |
| RF05 | El sistema debe permitir actualizar el precio de venta de un modelo. |

### Módulo 2 — Recepción de Furgones e Ingreso de Mercadería
| ID | Requerimiento |
|---|---|
| RF06 | El sistema debe permitir registrar los furgones que transportan la mercadería hacia Pavanamoon. |
| RF07 | El sistema debe permitir registrar un ingreso de mercadería asociado a un furgón, incluyendo la fecha, bodega de destino y responsable del registro. |
| RF08 | El sistema debe registrar el detalle de cada ingreso, incluyendo las variantes de producto y cantidades recibidas, y actualizar el stock correspondiente. |
| RF09 | El sistema debe permitir consultar el historial de ingresos filtrado por fecha, bodega o número de furgón. |

### Módulo 3 — Clientes y Pedidos/Distribución
| ID | Requerimiento |
|---|---|
| RF10 | El sistema debe permitir registrar clientes, diferenciando entre tipo individual y tipo mayorista/comercio. |
| RF11 | El sistema debe permitir registrar un pedido asociado a un cliente, con el detalle de variantes, cantidades y precios de venta. |
| RF12 | El sistema debe calcular automáticamente el total de un pedido a partir de su detalle. |
| RF13 | El sistema debe aplicar un descuento diferenciado a clientes de tipo mayorista según la regla de negocio definida. |
| RF14 | El sistema debe permitir consultar el historial de pedidos de un cliente. |

### Módulo 4 — Movimientos de Stock
| ID | Requerimiento |
|---|---|
| RF15 | El sistema debe registrar todo movimiento de stock (entrada, salida y devolución de cliente) con fecha y responsable. |
| RF16 | El sistema debe mantener un historial completo y auditable de movimientos por variante de producto (kardex). |
| RF17 | El sistema debe permitir procesar devoluciones de clientes, ajustando el stock correspondiente automáticamente. |
| RF18 | El sistema debe permitir generar un reporte de movimientos filtrado por variante y rango de fechas. |

### Módulo 5 — Usuarios y Control de Acceso
| ID | Requerimiento |
|---|---|
| RF19 | El sistema debe permitir gestionar roles de usuario: Administrador, Bodeguero y Vendedor. |
| RF20 | El sistema debe autenticar usuarios mediante credenciales únicas antes de permitir operaciones. |
| RF21 | El sistema debe restringir las operaciones disponibles según el rol asignado al usuario autenticado. |

---

## 5. Requerimientos de Datos (RD)

| ID | Requerimiento de datos |
|---|---|
| RD01 | Todo producto debe estar asociado obligatoriamente a una categoría de edad (Niño, Juvenil o Adulto). |
| RD02 | Una variante de producto se identifica de forma única por la combinación producto + talla + color. |
| RD03 | El stock de una variante nunca puede ser negativo (restricción CHECK). |
| RD04 | Todo pedido debe estar asociado a un cliente y a un empleado (vendedor) responsable. |
| RD05 | Todo ingreso de mercadería debe estar asociado obligatoriamente a un furgón, a un empleado responsable y a una bodega de destino. |
| RD06 | La fecha de cada movimiento de stock, ingreso de mercadería y pedido debe registrarse automáticamente al momento de la transacción. |
| RD07 | El NIT/identificador fiscal del cliente debe ser único. |
| RD08 | El nombre de usuario (username) debe ser único por usuario del sistema. |
| RD09 | Todo usuario del sistema debe tener asignado exactamente un rol. |
<<<<<<< HEAD
| RD10 | El tipo de movimiento de stock debe restringirse a un conjunto cerrado de valores (entrada, salida, devolución de cliente, ajuste). |
=======
| RD10 | El tipo de movimiento de stock debe restringirse a un conjunto cerrado de valores (entrada, salida, devolución de cliente, devolución). |
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08
| RD11 | El precio/costo unitario y la cantidad en el detalle de ingresos/pedidos deben ser valores positivos. |

---

## 6. Matriz de trazabilidad (Requerimiento → Entidad)

| Requerimiento | Entidad(es) principal(es) relacionada(s) | Módulo |
|---|---|---|
| RF01, RF05, RD01 | PRODUCTO, CATEGORIA | Inventario |
| RF02, RF03, RF04, RD02, RD03 | VARIANTE_PRODUCTO, TALLA, COLOR | Inventario |
| RF06 | FURGON | Recepción |
| RF07, RF08, RF09, RD05, RD11 | FURGON, INGRESO_MERCADERIA, DETALLE_INGRESO | Recepción / Inventario |
| RF08 | INGRESO_MERCADERIA, DETALLE_INGRESO, VARIANTE_PRODUCTO, MOVIMIENTO_STOCK | Recepción / Inventario |
<<<<<<< HEAD
| RF10, RD07 | CLIENTE, TIPO_CLIENTE | Clientes |
| RF11, RF12, RF13, RF14, RD04, RD11 | PEDIDO, DETALLE_PEDIDO, CLIENTE, PRESENTACION_VENTA | Pedidos |
=======
| RF10, RD07 | CLIENTE | Clientes |
| RF11, RF12, RF13, RF14, RD04, RD11 | PEDIDO, DETALLE_PEDIDO, CLIENTE | Pedidos |
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08
| RF15, RF16, RF17, RF18, RD06, RD10 | MOVIMIENTO_STOCK, VARIANTE_PRODUCTO | Movimientos |
| RF19, RF20, RF21, RD08, RD09 | ROL, USUARIO, EMPLEADO | Seguridad |

*Esta matriz se actualizará en cada entrega conforme avance la implementación (estándar D4).*

---

## 7. Diseño conceptual — Modelo Entidad-Relación (Notación Chen)

> **Nota de actualización posterior a la calificación de la Entrega 1 (31/08/2026):**
> el catedrático (Ivan Antonio De León Fuentes) señaló que el diagrama `.drawio`
> introducía `TIPO_CLIENTE` y `PRESENTACION_VENTA`, ausentes en esta sección
> escrita. Al revisar a fondo se encontraron además otras 4 discrepancias menores
> entre el texto y la implementación real (DDL ya ejecutado y probado contra
> MySQL desde la Entrega 2): la cardinalidad de la relación `transporta`
> (FURGON–INGRESO_MERCADERIA), los atributos de `CLIENTE` y `EMPLEADO`, y los
> valores permitidos de `tipo_movimiento`. Toda la Sección 7 se actualizó para
> que el texto, el diagrama (`docs/diagramas/Pavanamoon_er_chen_corregido.drawio`)
> y el DDL (`sql/ddl/`) digan exactamente lo mismo. El detalle de cada cambio
> queda documentado en `docs/entrega-2/ENTREGA2_DISENO_LOGICO.md`, Sección 1, y
> en la Bitácora de IA, Entrada 11.

### 7.1 Nota metodológica sobre herramientas de diagramación

La guía del proyecto exige notación Chen (óvalos para atributos, rombos para relaciones, rectángulos para entidades). **Ni Mermaid.js ni PlantUML soportan nativamente notación Chen**; ambas generan diagramas ER en notación Crow's Foot / IE. Por lo tanto, el diagrama Chen oficial (editable + PNG/PDF, estándar D3) es la fuente de verdad del modelo, elaborado en draw.io y guardado en `docs/diagramas/Pavanamoon_er_chen_corregido.drawio`; la especificación textual de esta sección es su transcripción fiel, y la vista Mermaid de la Sección 7.5 es solo una ayuda visual referencial en notación distinta.

### 7.2 Entidades principales (15)

> Convención: **PK** = llave primaria, **FK** = llave foránea, *[multivaluado]*, *{derivado}*, *UK* = único.

1. **ROL** (rol_id **PK**, nombre_rol *UK*, descripcion)
<<<<<<< HEAD
2. **USUARIO** (usuario_id **PK**, username *UK*, password_hash, estado, fecha_creacion, rol_id **FK**, empleado_id **FK** *UK*)
3. **EMPLEADO** (empleado_id **PK**, nombres_apellidos, dpi *UK*, telefono *[multivaluado]*)
4. **TIPO_CLIENTE** (tipo_cliente_id **PK**, nombre *UK* {individual|mayorista}, descripcion)
5. **CLIENTE** (cliente_id **PK**, tipo_cliente_id **FK**, nombre_cliente, nit *UK*, telefono *[multivaluado]*)
6. **CATEGORIA** (categoria_id **PK**, nombre_categoria *UK* {nino|juvenil|adulto})
7. **PRODUCTO** (producto_id **PK**, categoria_id **FK**, modelo, tipo_suela {hule|flex|tpu}, precio_venta) — *sin campo `marca`: Pavanamoon es marca propia, todos los modelos pertenecen a la misma marca, por lo que ese atributo sería redundante. `precio_venta` es la única fuente de precio del sistema (ver nota de consistencia de precio en ENTREGA2_DISENO_LOGICO.md).*
8. **TALLA** (talla_id **PK**, valor_talla *UK*)
9. **COLOR** (color_id **PK**, nombre_color *UK*)
10. **VARIANTE_PRODUCTO** (variante_id **PK**, producto_id **FK**, talla_id **FK**, color_id **FK**, sku *UK* (generado por la aplicación a partir de producto+talla+color), stock_actual, stock_minimo)
11. **PRESENTACION_VENTA** (presentacion_id **PK**, nombre *UK* {unidad|caja}, cantidad_pares, estado) — *sin precio propio: representa únicamente la forma en que se agrupan los pares para la venta (ver nota de consistencia de precio); `MAYORISTA` es un valor de `TIPO_CLIENTE`, nunca una presentación.*
12. **FURGON** (furgon_id **PK**, numero_furgon *UK*, fecha_llegada, procedencia, transportista, estado)
13. **INGRESO_MERCADERIA** (ingreso_id **PK**, furgon_id **FK**, empleado_id **FK**, fecha_ingreso, bodega_destino, estado)
14. **PEDIDO** (pedido_id **PK**, cliente_id **FK**, empleado_id **FK**, fecha_pedido, total_pedido *{derivado}*, estado)
15. **MOVIMIENTO_STOCK** (movimiento_id **PK**, variante_id **FK**, empleado_id **FK**, tipo_movimiento {entrada|salida|devolucion_cliente|ajuste}, cantidad, fecha_movimiento)

> **Nota de diseño (decisión de negocio):** el equipo evaluó modelar una entidad `PROVEEDOR` independiente, pero se descartó porque Pavanamoon no gestiona relación comercial ni catálogo de proveedores externos — únicamente necesita trazabilidad del **furgón** que transporta cada carga hasta bodega. Por eso `FURGON` reemplaza lo que en versiones anteriores era `PROVEEDOR` + `COMPRA`.

> **Nota sobre atributos multivaluados:** `EMPLEADO.telefono` y `CLIENTE.telefono` son multivaluados en el modelo conceptual; se resuelven en el modelo relacional (Entrega 2) mediante las tablas `EMPLEADO_TELEFONO` y `CLIENTE_TELEFONO` (normalización 1FN, ver ENTREGA2_DISENO_LOGICO.md, Sección 3.1).

### 7.3 Entidades asociativas — Relaciones N:M resueltas (2 requeridas, mínimo cumplido)

- **DETALLE_INGRESO** (ingreso_id **FK**, variante_id **FK**, cantidad, costo_unitario, subtotal *{derivado}*) → resuelve **INGRESO_MERCADERIA (N,M) VARIANTE_PRODUCTO**; llave primaria compuesta (ingreso_id, variante_id).
- **DETALLE_PEDIDO** (pedido_id **FK**, variante_id **FK**, presentacion_id **FK**, cantidad, precio_unitario, subtotal *{derivado}*) → resuelve **PEDIDO (N,M) VARIANTE_PRODUCTO**; llave primaria compuesta (pedido_id, variante_id). Cada línea además indica en qué `PRESENTACION_VENTA` se vendió (relación `se_utiliza_en`).
=======
2. **USUARIO** (usuario_id **PK**, username *UK*, password_hash, estado, fecha_creacion, rol_id **FK**, empleado_id **FK**)
3. **EMPLEADO** (empleado_id **PK**, nombres, apellidos, dpi *UK*, telefono *[multivaluado]*, fecha_contratacion, salario)
4. **CLIENTE** (cliente_id **PK**, tipo_cliente {individual|mayorista}, nombre_razon_social, nit *UK*, telefono *[multivaluado]*, email, direccion, porcentaje_descuento)
5. **CATEGORIA** (categoria_id **PK**, nombre_categoria {Niño|Juvenil|Adulto}, descripcion)
6. **PRODUCTO** (producto_id **PK**, categoria_id **FK**, modelo, tipo_suela {Hule|Flex|TPU}, descripcion, precio_venta, fecha_registro) — *sin campo `marca`: Pavanamoon es marca propia, todos los modelos pertenecen a la misma marca, por lo que ese atributo sería redundante.*
7. **TALLA** (talla_id **PK**, valor_talla *UK*)
8. **COLOR** (color_id **PK**, nombre_color *UK*, codigo_hex)
9. **VARIANTE_PRODUCTO** (variante_id **PK**, producto_id **FK**, talla_id **FK**, color_id **FK**, sku *{derivado: producto+talla+color}* *UK*, stock_actual, stock_minimo)
10. **FURGON** (furgon_id **PK**, numero_furgon *UK*, fecha_llegada, procedencia, transportista, estado)
11. **INGRESO_MERCADERIA** (ingreso_id **PK**, furgon_id **FK**, empleado_id **FK**, fecha_ingreso, bodega_destino, estado)
12. **PEDIDO** (pedido_id **PK**, cliente_id **FK**, empleado_id **FK**, fecha_pedido, tipo_venta {detalle|mayorista}, total_pedido *{derivado}*, estado)
13. **MOVIMIENTO_STOCK** (movimiento_id **PK**, variante_id **FK**, empleado_id **FK**, tipo_movimiento {entrada|salida|devolucion_cliente}, cantidad, fecha_movimiento, referencia_documento, observaciones)

> **Nota de diseño (decisión de negocio):** el equipo evaluó modelar una entidad `PROVEEDOR` independiente, pero se descartó porque Pavanamoon no gestiona relación comercial ni catálogo de proveedores externos — únicamente necesita trazabilidad del **furgón** que transporta cada carga hasta bodega. Por eso `FURGON` reemplaza lo que en versiones anteriores era `PROVEEDOR` + `COMPRA`.

### 7.3 Entidades asociativas — Relaciones N:M resueltas (2 requeridas, mínimo cumplido)

- **DETALLE_INGRESO** (ingreso_id **FK**, variante_id **FK**, cantidad, costo_unitario, subtotal *{derivado}*) → resuelve **INGRESO_MERCADERIA (N,M) VARIANTE_PRODUCTO**
- **DETALLE_PEDIDO** (pedido_id **FK**, variante_id **FK**, cantidad, precio_unitario, subtotal *{derivado}*) → resuelve **PEDIDO (N,M) VARIANTE_PRODUCTO**
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08

### 7.4 Relaciones (con cardinalidades, notación (mín,máx))

| Relación (rombo Chen) | Entidad A | Cardinalidad | Entidad B | Cardinalidad |
|---|---|---|---|---|
| tiene | ROL | (1,N) | USUARIO | (1,1) |
| posee | EMPLEADO | (0,1) | USUARIO | (1,1) |
| registra | EMPLEADO | (0,N) | INGRESO_MERCADERIA | (1,1) |
| atiende | EMPLEADO | (0,N) | PEDIDO | (1,1) |
| ejecuta | EMPLEADO | (0,N) | MOVIMIENTO_STOCK | (1,1) |
<<<<<<< HEAD
| transporta | FURGON | (0,N) | INGRESO_MERCADERIA | (1,1) |
| clasifica | TIPO_CLIENTE | (1,N) | CLIENTE | (1,1) |
=======
| transporta | FURGON | (1,1) | INGRESO_MERCADERIA | (1,1) |
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08
| realiza | CLIENTE | (0,N) | PEDIDO | (1,1) |
| clasifica | CATEGORIA | (1,N) | PRODUCTO | (1,1) |
| genera_variante | PRODUCTO | (1,N) | VARIANTE_PRODUCTO | (1,1) |
<<<<<<< HEAD
| define_talla | TALLA | (1,N) | VARIANTE_PRODUCTO | (1,1) |
| define_color | COLOR | (1,N) | VARIANTE_PRODUCTO | (1,1) |
=======
| se_define_en_talla | TALLA | (1,N) | VARIANTE_PRODUCTO | (1,1) |
| se_define_en_color | COLOR | (1,N) | VARIANTE_PRODUCTO | (1,1) |
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08
| **contiene** (N:M) | INGRESO_MERCADERIA | (1,N) | VARIANTE_PRODUCTO | (0,N) *(vía DETALLE_INGRESO)* |
| **incluye** (N:M) | PEDIDO | (1,N) | VARIANTE_PRODUCTO | (0,N) *(vía DETALLE_PEDIDO)* |
| se_utiliza_en | PRESENTACION_VENTA | (0,N) | DETALLE_PEDIDO | (1,1) |
| genera_movimiento | VARIANTE_PRODUCTO | (0,N) | MOVIMIENTO_STOCK | (1,1) |

<<<<<<< HEAD
> Notas: `FURGON` representa el medio de transporte mediante el cual llega la mercadería; la relación `transporta` es **1:N** (no 1:1) porque un mismo furgón puede corresponder a más de un ingreso a bodega (ej. descargas parciales). `INGRESO_MERCADERIA` registra la recepción en bodega y `DETALLE_INGRESO` registra las variantes y cantidades recibidas. No se modela logística externa ni aduanas. `TIPO_CLIENTE` centraliza el segmento comercial (individual/mayorista) como catálogo, no como valor fijo dentro de `CLIENTE`, lo que permite agregar nuevos segmentos sin alterar el esquema.
=======
> Nota: `FURGON` representa el medio de transporte mediante el cual llega la mercadería. `INGRESO_MERCADERIA` registra la recepción en bodega y `DETALLE_INGRESO` registra las variantes y cantidades recibidas. No se modela logística externa ni aduanas.
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08

### 7.5 Vista de apoyo — Mermaid ER (notación Crow's Foot, referencial, actualizada)

```mermaid
erDiagram
    ROL ||--o{ USUARIO : tiene
    EMPLEADO ||--o| USUARIO : posee
    EMPLEADO ||--o{ INGRESO_MERCADERIA : registra
    EMPLEADO ||--o{ PEDIDO : atiende
    EMPLEADO ||--o{ MOVIMIENTO_STOCK : ejecuta
<<<<<<< HEAD
    FURGON ||--o{ INGRESO_MERCADERIA : transporta
    TIPO_CLIENTE ||--o{ CLIENTE : clasifica
=======
    FURGON ||--|| INGRESO_MERCADERIA : transporta
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08
    CLIENTE ||--o{ PEDIDO : realiza
    CATEGORIA ||--o{ PRODUCTO : clasifica
    PRODUCTO ||--o{ VARIANTE_PRODUCTO : genera
    TALLA ||--o{ VARIANTE_PRODUCTO : define
    COLOR ||--o{ VARIANTE_PRODUCTO : define
    INGRESO_MERCADERIA ||--o{ DETALLE_INGRESO : contiene
    VARIANTE_PRODUCTO ||--o{ DETALLE_INGRESO : incluida_en
    PEDIDO ||--o{ DETALLE_PEDIDO : incluye
    VARIANTE_PRODUCTO ||--o{ DETALLE_PEDIDO : incluida_en
    PRESENTACION_VENTA ||--o{ DETALLE_PEDIDO : se_utiliza_en
    VARIANTE_PRODUCTO ||--o{ MOVIMIENTO_STOCK : genera

    ROL {
        int rol_id PK
        string nombre_rol
    }
    USUARIO {
        int usuario_id PK
        string username
        int rol_id FK
        int empleado_id FK
    }
    EMPLEADO {
        int empleado_id PK
        string nombres_apellidos
        string dpi
    }
    TIPO_CLIENTE {
        int tipo_cliente_id PK
        string nombre "individual, mayorista"
        string descripcion
    }
    CLIENTE {
        int cliente_id PK
        int tipo_cliente_id FK
        string nombre_cliente
        string nit
    }
    FURGON {
        int furgon_id PK
        string numero_furgon
        date fecha_llegada
        string procedencia
        string transportista
    }
    INGRESO_MERCADERIA {
        int ingreso_id PK
        int furgon_id FK
        int empleado_id FK
        date fecha_ingreso
        string bodega_destino
    }
    DETALLE_INGRESO {
        int ingreso_id FK
        int variante_id FK
        int cantidad
        decimal costo_unitario
    }
    CATEGORIA {
        int categoria_id PK
        string nombre_categoria "nino, juvenil, adulto"
    }
    PRODUCTO {
        int producto_id PK
        int categoria_id FK
        string modelo
        string tipo_suela "hule, flex, tpu"
        decimal precio_venta
    }
    TALLA {
        int talla_id PK
        string valor_talla
    }
    COLOR {
        int color_id PK
        string nombre_color
    }
    VARIANTE_PRODUCTO {
        int variante_id PK
        int producto_id FK
        int talla_id FK
        int color_id FK
        string sku
        int stock_actual
        int stock_minimo
    }
<<<<<<< HEAD
    PRESENTACION_VENTA {
        int presentacion_id PK
        string nombre "unidad, caja"
        int cantidad_pares
    }
=======
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08
    PEDIDO {
        int pedido_id PK
        int cliente_id FK
        int empleado_id FK
        date fecha_pedido
        string estado
    }
    DETALLE_PEDIDO {
        int pedido_id FK
        int variante_id FK
        int presentacion_id FK
        int cantidad
        decimal precio_unitario
    }
    MOVIMIENTO_STOCK {
        int movimiento_id PK
        int variante_id FK
        int empleado_id FK
        string tipo_movimiento
        int cantidad
    }
```

### 7.6 Resumen de cumplimiento de requisitos mínimos del sistema

| Requisito mínimo del proyecto | Cumplimiento en este diseño |
|---|---|
<<<<<<< HEAD
| ≥8 entidades principales | ✅ 15 entidades principales (sin contar asociativas) |
| ≥2 relaciones N:M resueltas | ✅ INGRESO_MERCADERIA↔VARIANTE_PRODUCTO y PEDIDO↔VARIANTE_PRODUCTO, vía DETALLE_INGRESO y DETALLE_PEDIDO |
| Normalización 3FN | ✅ Demostrada con ejemplo en Entrega 2 (`ENTREGA2_DISENO_LOGICO.md`, Sección 3): separación de TALLA/COLOR/CATEGORIA como catálogos evita dependencias transitivas y redundancia en VARIANTE_PRODUCTO y PRODUCTO; EMPLEADO_TELEFONO/CLIENTE_TELEFONO resuelven 1FN |
| ≥15 restricciones explícitas | ✅ Implementadas en DDL (Entrega 2, `sql/ddl/`): 19 PK + 20 FK + 13 UNIQUE + 10 CHECK, ejecutadas y probadas contra MySQL real (ver `docs/casos-prueba/CASOS_PRUEBA.md`) |
| ≥2 triggers / procedimientos | Planeado para Entrega 3: trigger de actualización automática de stock al insertar DETALLE_INGRESO/DETALLE_PEDIDO/MOVIMIENTO_STOCK; procedimiento de cálculo de total de pedido con descuento por tipo de cliente |
| ≥3 roles de seguridad | Administrador, Bodeguero, Vendedor — ya reflejados en entidad ROL y cargados en `sql/dml/00_seed_minimo.sql` |
=======
| ≥8 entidades principales | ✅ 13 entidades principales (sin contar asociativas) |
| ≥2 relaciones N:M resueltas | ✅ INGRESO_MERCADERIA↔VARIANTE_PRODUCTO y PEDIDO↔VARIANTE_PRODUCTO, vía DETALLE_INGRESO y DETALLE_PEDIDO |
| Normalización 3FN | Se demostrará con ejemplo en Entrega 2 (ej. separación de TALLA/COLOR/CATEGORIA como catálogos evita dependencias transitivas y redundancia en VARIANTE_PRODUCTO y PRODUCTO) |
| ≥15 restricciones explícitas | Se implementan en DDL (Entrega 2): PKs, FKs, UNIQUE (nit, username, sku, numero_furgon), CHECK (stock_actual >= 0, cantidad > 0, tipo_suela IN ('Hule','Flex','TPU'), nombre_categoria IN ('Niño','Juvenil','Adulto'), tipo_movimiento IN (...)), NOT NULL |
| ≥2 triggers / procedimientos | Planeado para Entrega 3: trigger de actualización automática de stock al insertar DETALLE_INGRESO/DETALLE_PEDIDO/MOVIMIENTO_STOCK; procedimiento de cálculo de total de pedido con descuento mayorista |
| ≥3 roles de seguridad | Administrador, Bodeguero, Vendedor — ya reflejados en entidad ROL |
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08

---

## 8. Planificación — Cronograma (Gantt textual, 12 semanas)

| Semana | Actividad | Entregable | Responsable(s) |
|---|---|---|---|
| 1 | Levantamiento del caso de negocio (fútbol, edades, suelas, furgones) y RF/RD | Borrador de requerimientos | Todo el equipo |
| 2 | Diseño del modelo ER (Chen) y matriz de trazabilidad | ER conceptual v1 | Todo el equipo |
| 3 | Redacción de propuesta, README, cierre Entrega 1 | **ENTREGA 1 (tag entrega-1)** | Todo el equipo |
| 4 | Modelo relacional, normalización 3FN, diccionario de datos | Modelo lógico | Todo el equipo |
| 5 | Scripts DDL, INSTALL.md, login + 2 CRUD web (30%) | **ENTREGA 2 (tag entrega-2)** | Todo el equipo |
| 6 | DML de carga de datos de prueba (≥50 registros/tabla) | Scripts DML | Bodeguero de datos (rotativo) |
| 7 | Vistas, triggers, procedimientos almacenados | Scripts SQL avanzados | Todo el equipo |
| 8 | Seguridad (3 roles BD), casos de prueba, app web 70% | **ENTREGA 3 (tag entrega-3)** | Todo el equipo |
| 9 | Completar módulos web restantes | Avance funcional | Todo el equipo |
| 10 | Control de acceso por rol en la app, manuales | Documentación técnica/usuario | Todo el equipo |
| 11 | Pruebas de integración, instalación desde cero | Informe final borrador | Todo el equipo |
| 12 | Integración final, defensa oral | **ENTREGA 4 + Defensa (tag entrega-4)** | Todo el equipo |

---

## 9. Declaración de uso de agentes de IA

<<<<<<< HEAD
El equipo utilizó agentes de IA (Claude de Anthropic y Gemini) como asistentes en: (1) la redacción inicial de la propuesta, RF/RD, matriz de trazabilidad y modelo ER conceptual; (2) la corrección de la estructura del repositorio conforme a la Sección 7 de la guía; (3) el ajuste del modelo de negocio al enfoque real de Pavanamoon como marca propia especializada en calzado de fútbol (eliminación del campo `marca`, incorporación de `tipo_suela`, categorías por edad); (4) el rediseño del módulo de recepción de mercadería, reemplazando `PROVEEDOR`/`COMPRA` por `FURGON`/`INGRESO_MERCADERIA`/`DETALLE_INGRESO`, tras confirmar con el equipo que Pavanamoon no requiere catálogo de proveedores; y (5) la resincronización completa de esta sección (7) con el diagrama `.drawio` y el DDL real tras la retroalimentación del catedrático sobre la Entrega 1 (agregado de `TIPO_CLIENTE` y `PRESENTACION_VENTA`, corrección de la cardinalidad `transporta`, y ajuste de atributos de `CLIENTE`/`EMPLEADO`). El detalle completo del uso, prompts y validación se documenta en `docs/bitacora-ia/BITACORA_IA.md`, conforme al estándar S8/R-Bitácora del proyecto.
=======
El equipo utilizó agentes de IA (Claude de Anthropic y Gemini) como asistentes en: (1) la redacción inicial de la propuesta, RF/RD, matriz de trazabilidad y modelo ER conceptual; (2) la corrección de la estructura del repositorio conforme a la Sección 7 de la guía; (3) el ajuste del modelo de negocio al enfoque real de Pavanamoon como marca propia especializada en calzado de fútbol (eliminación del campo `marca`, incorporación de `tipo_suela`, categorías por edad); y (4) el rediseño del módulo de recepción de mercadería, reemplazando `PROVEEDOR`/`COMPRA` por `FURGON`/`INGRESO_MERCADERIA`/`DETALLE_INGRESO`, tras confirmar con el equipo que Pavanamoon no requiere catálogo de proveedores. El detalle completo del uso, prompts y validación se documenta en `docs/bitacora-ia/BITACORA_IA.md`, conforme al estándar S8/R-Bitácora del proyecto.
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08

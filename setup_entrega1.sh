#!/usr/bin/env bash
###############################################################################
# setup_entrega1.sh
# Proyecto: Pavanamoon - Sistema de Gestion de Inventario y Distribucion
# Universidad Mariano Galvez de Guatemala
# SGBD: MySQL
#
# Este script:
#   1. Crea la estructura de carpetas obligatoria del proyecto (Seccion 7).
#   2. Genera los archivos .md de la Entrega 1 con su contenido.
#   3. Genera el diagrama ER en notacion Chen (pavanamoon_ER_chen.drawio)
#      listo para abrir en app.diagrams.net y exportar a PNG/PDF.
#   4. Crea .gitignore y .env.example (variables MySQL).
#   5. Inicializa git (si aplica), hace commit, crea el tag entrega-1 y
#      hace push al repositorio remoto.
#
# Uso:
#   1. Colocar este script en la carpeta donde quieras crear el proyecto.
#   2. chmod +x setup_entrega1.sh
#   3. ./setup_entrega1.sh
#
# Requisitos previos:
#   - Tener git instalado y configurado (user.name / user.email).
#   - Si el repo remoto YA existe en GitHub, ejecutar antes:
#       git remote add origin https://github.com/tu-usuario/pavanamoon.git
###############################################################################

set -e

PROJECT_DIR="pavanamoon"

echo ">> Creando estructura de carpetas obligatoria..."
mkdir -p "$PROJECT_DIR"/docs/entrega-1
mkdir -p "$PROJECT_DIR"/docs/entrega-2
mkdir -p "$PROJECT_DIR"/docs/entrega-3
mkdir -p "$PROJECT_DIR"/docs/entrega-4
mkdir -p "$PROJECT_DIR"/docs/diagramas
mkdir -p "$PROJECT_DIR"/docs/certificaciones
mkdir -p "$PROJECT_DIR"/docs/bitacora-ia
mkdir -p "$PROJECT_DIR"/docs/casos-prueba
mkdir -p "$PROJECT_DIR"/sql/ddl
mkdir -p "$PROJECT_DIR"/sql/dml
mkdir -p "$PROJECT_DIR"/sql/views
mkdir -p "$PROJECT_DIR"/sql/triggers
mkdir -p "$PROJECT_DIR"/sql/procedures
mkdir -p "$PROJECT_DIR"/sql/security
mkdir -p "$PROJECT_DIR"/web

cd "$PROJECT_DIR"

echo ">> Generando docs/entrega-1/ENTREGA1_PROPUESTA.md..."
cat > "docs/entrega-1/ENTREGA1_PROPUESTA.md" << 'MDEOF'
# ENTREGA 1 — Análisis, Propuesta y Diseño Conceptual
## Sistema de Gestión de Inventario y Distribución de Calzado — Pavanamoon

**Universidad Mariano Gálvez de Guatemala**
**Curso:** Bases de Datos
**SGBD seleccionado:** MySQL *(confirmado — dentro de las opciones permitidas por la guía del proyecto, Sección 3)*
**Fecha:** Semana 1–3

---

## 1. Descripción del problema real

Pavanamoon es una empresa dedicada a la comercialización y distribución de calzado deportivo (fútbol) y casual/urbano. Atiende dos segmentos de cliente con dinámicas distintas:

- **B2C (detalle):** clientes individuales que compran unidades sueltas.
- **B2B (mayoreo):** comercios y revendedores que compran en volumen y acceden a condiciones diferenciadas (descuentos por tipo de cliente).

El crecimiento en volumen de mercadería ha generado los siguientes problemas operativos que la empresa busca resolver mediante un sistema de base de datos relacional centralizado:

1. **Control de inventario disperso o manual:** no existe trazabilidad confiable de existencias por modelo, talla y color, lo que genera sobreventas o quiebres de stock no detectados a tiempo.
2. **Falta de historial de movimientos:** entradas por compra, salidas por venta, y devoluciones no quedan registradas de forma auditable.
3. **Gestión de proveedores no estructurada:** no hay un registro histórico de qué se compró, a quién y cuándo, dificultando la negociación y el control de costos.
4. **Segmentación de clientes inexistente en el sistema:** no se diferencia formalmente entre venta al detalle y venta al por mayor, lo que impide aplicar reglas de negocio (precios, descuentos) de forma consistente.
5. **Sin control de acceso por rol:** cualquier persona con acceso al sistema actual puede realizar cualquier operación, sin distinción entre funciones de bodega, ventas y administración.

## 2. Propuesta de solución

Se propone diseñar e implementar un **sistema de base de datos relacional** en MySQL que centralice:

- Catálogo de productos (categoría deportivo/casual, marca, modelo) y sus variantes por talla y color, cada una con su propio nivel de stock.
- Gestión de proveedores y órdenes de compra con detalle de mercadería ingresada.
- Gestión de clientes (individuales y mayoristas) y procesamiento de pedidos/ventas con su detalle.
- Registro completo de movimientos de stock (entradas, salidas, devoluciones de cliente y devoluciones a proveedor), permitiendo reconstruir el kardex de cualquier variante de producto.
- Seguridad basada en roles (Administrador, Bodeguero, Vendedor) con privilegios diferenciados a nivel de base de datos.

El sistema se acompañará de una interfaz web mínima (a partir de la Entrega 2) que consumirá esta base de datos, siguiendo los estándares de calidad de código y seguridad definidos en la guía del proyecto (consultas parametrizadas, separación de capas, manejo controlado de errores).

## 3. Alcance de la Entrega 1

Esta entrega cubre exclusivamente la fase de **análisis y diseño conceptual**: identificación de requerimientos, modelo Entidad-Relación en notación Chen, y planificación del proyecto. No incluye implementación de DDL (que inicia en Entrega 2, tras aprobación del ER, según la Consideración General #9 de la guía).

---

## 4. Requerimientos Funcionales (RF)

### Módulo 1 — Gestión de Inventario y Productos
| ID | Requerimiento |
|---|---|
| RF01 | El sistema debe permitir registrar productos, clasificados por categoría (deportivo/casual), marca y modelo. |
| RF02 | El sistema debe permitir registrar variantes de un producto por combinación única de talla y color, cada una con su propio stock. |
| RF03 | El sistema debe permitir consultar el stock disponible de cualquier variante en tiempo real. |
| RF04 | El sistema debe permitir identificar variantes cuyo stock esté por debajo de un umbral mínimo definido. |
| RF05 | El sistema debe permitir actualizar el precio de venta de un producto. |

### Módulo 2 — Compras y Proveedores
| ID | Requerimiento |
|---|---|
| RF06 | El sistema debe permitir registrar proveedores con su información de contacto. |
| RF07 | El sistema debe permitir registrar una orden de compra asociada a un proveedor, con el detalle de variantes y cantidades adquiridas. |
| RF08 | El sistema debe registrar el ingreso de mercadería a bodega y actualizar automáticamente el stock de las variantes correspondientes. |
| RF09 | El sistema debe permitir consultar el historial de compras realizadas a un proveedor específico. |

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
| RF15 | El sistema debe registrar todo movimiento de stock (entrada, salida, devolución de cliente, devolución a proveedor) con fecha y responsable. |
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
| RD01 | Todo producto debe estar asociado obligatoriamente a una categoría. |
| RD02 | Una variante de producto se identifica de forma única por la combinación producto + talla + color. |
| RD03 | El stock de una variante nunca puede ser negativo (restricción CHECK). |
| RD04 | Todo pedido debe estar asociado a un cliente y a un empleado (vendedor) responsable. |
| RD05 | Toda compra debe estar asociada a un proveedor y a un empleado (bodeguero/comprador) responsable. |
| RD06 | La fecha de cada movimiento de stock, compra y pedido debe registrarse automáticamente al momento de la transacción. |
| RD07 | El NIT/identificador fiscal de cliente y proveedor debe ser único. |
| RD08 | El nombre de usuario (username) debe ser único por usuario del sistema. |
| RD09 | Todo usuario del sistema debe tener asignado exactamente un rol. |
| RD10 | El tipo de movimiento de stock debe restringirse a un conjunto cerrado de valores (entrada, salida, devolución de cliente, devolución a proveedor). |
| RD11 | El precio unitario y la cantidad en el detalle de compras/pedidos deben ser valores positivos. |

---

## 6. Matriz de trazabilidad (Requerimiento → Entidad)

| Requerimiento | Entidad(es) principal(es) relacionada(s) | Módulo |
|---|---|---|
| RF01, RF05, RD01 | PRODUCTO, CATEGORIA | Inventario |
| RF02, RF03, RF04, RD02, RD03 | VARIANTE_PRODUCTO, TALLA, COLOR | Inventario |
| RF06, RD07 | PROVEEDOR | Compras |
| RF07, RF09, RD05, RD11 | COMPRA, DETALLE_COMPRA | Compras |
| RF08 | COMPRA, DETALLE_COMPRA, VARIANTE_PRODUCTO, MOVIMIENTO_STOCK | Compras / Inventario |
| RF10, RD07 | CLIENTE | Clientes |
| RF11, RF12, RF13, RF14, RD04, RD11 | PEDIDO, DETALLE_PEDIDO, CLIENTE | Pedidos |
| RF15, RF16, RF17, RF18, RD06, RD10 | MOVIMIENTO_STOCK, VARIANTE_PRODUCTO | Movimientos |
| RF19, RF20, RF21, RD08, RD09 | ROL, USUARIO, EMPLEADO | Seguridad |

*Esta matriz se actualizará en cada entrega conforme avance la implementación (estándar D4).*

---

## 7. Diseño conceptual — Modelo Entidad-Relación (Notación Chen)

### 7.1 Nota metodológica sobre herramientas de diagramación

La guía del proyecto exige notación Chen (óvalos para atributos, rombos para relaciones, rectángulos para entidades). **Ni Mermaid.js ni PlantUML soportan nativamente notación Chen**; ambas herramientas generan diagramas ER en notación Crow's Foot / IE. Por lo tanto:

- Se incluye a continuación la **especificación textual completa en notación Chen** (entidades, atributos clasificados, relaciones con cardinalidades), que es la fuente de verdad del modelo.
- Se incluye un **diagrama Mermaid como vista rápida de apoyo** (no reemplaza el diagrama Chen oficial).
- El **diagrama Chen oficial en formato editable + PNG/PDF** (estándar D3) debe elaborarse en **draw.io o Lucidchart** a partir de esta especificación, y guardarse en `/docs/diagramas/`.

### 7.2 Entidades principales (13)

> Convención: **PK** = llave primaria, **FK** = llave foránea, *[multivaluado]*, *{derivado}*, *UK* = único.

1. **ROL** (rol_id **PK**, nombre_rol *UK*, descripcion)
2. **USUARIO** (usuario_id **PK**, username *UK*, password_hash, estado, fecha_creacion, rol_id **FK**, empleado_id **FK**)
3. **EMPLEADO** (empleado_id **PK**, nombres, apellidos, dpi *UK*, telefono *[multivaluado]*, fecha_contratacion, salario)
4. **CLIENTE** (cliente_id **PK**, tipo_cliente {individual|mayorista}, nombre_razon_social, nit *UK*, telefono *[multivaluado]*, email, direccion, porcentaje_descuento)
5. **PROVEEDOR** (proveedor_id **PK**, nombre_empresa, nit *UK*, telefono, email, direccion, contacto_nombre)
6. **CATEGORIA** (categoria_id **PK**, nombre_categoria {deportivo|casual}, descripcion)
7. **PRODUCTO** (producto_id **PK**, categoria_id **FK**, marca, modelo, descripcion, precio_venta, genero, fecha_registro)
8. **TALLA** (talla_id **PK**, valor_talla *UK*)
9. **COLOR** (color_id **PK**, nombre_color *UK*, codigo_hex)
10. **VARIANTE_PRODUCTO** (variante_id **PK**, producto_id **FK**, talla_id **FK**, color_id **FK**, sku *{derivado: producto+talla+color}* *UK*, stock_actual, stock_minimo)
11. **COMPRA** (compra_id **PK**, proveedor_id **FK**, empleado_id **FK**, fecha_compra, total_compra *{derivado}*, estado)
12. **PEDIDO** (pedido_id **PK**, cliente_id **FK**, empleado_id **FK**, fecha_pedido, tipo_venta {detalle|mayorista}, total_pedido *{derivado}*, estado)
13. **MOVIMIENTO_STOCK** (movimiento_id **PK**, variante_id **FK**, empleado_id **FK**, tipo_movimiento {entrada|salida|devolucion_cliente|devolucion_proveedor}, cantidad, fecha_movimiento, referencia_documento, observaciones)

### 7.3 Entidades asociativas — Relaciones N:M resueltas (2 requeridas, mínimo cumplido)

- **DETALLE_COMPRA** (compra_id **FK**, variante_id **FK**, cantidad, costo_unitario, subtotal *{derivado}*) → resuelve **COMPRA (N,M) VARIANTE_PRODUCTO**
- **DETALLE_PEDIDO** (pedido_id **FK**, variante_id **FK**, cantidad, precio_unitario, subtotal *{derivado}*) → resuelve **PEDIDO (N,M) VARIANTE_PRODUCTO**

### 7.4 Relaciones (con cardinalidades, notación (mín,máx))

| Relación (rombo Chen) | Entidad A | Cardinalidad | Entidad B | Cardinalidad |
|---|---|---|---|---|
| tiene | ROL | (1,1) | USUARIO | (0,N) |
| posee | EMPLEADO | (0,1) | USUARIO | (1,1) |
| registra | EMPLEADO | (0,N) | COMPRA | (1,1) |
| atiende | EMPLEADO | (0,N) | PEDIDO | (1,1) |
| ejecuta | EMPLEADO | (0,N) | MOVIMIENTO_STOCK | (1,1) |
| suministra | PROVEEDOR | (0,N) | COMPRA | (1,1) |
| realiza | CLIENTE | (0,N) | PEDIDO | (1,1) |
| clasifica | CATEGORIA | (1,N) | PRODUCTO | (1,1) |
| genera | PRODUCTO | (1,N) | VARIANTE_PRODUCTO | (1,1) |
| se_define_en_talla | TALLA | (1,N) | VARIANTE_PRODUCTO | (1,1) |
| se_define_en_color | COLOR | (1,N) | VARIANTE_PRODUCTO | (1,1) |
| **contiene** (N:M) | COMPRA | (1,N) | VARIANTE_PRODUCTO | (0,N) *(vía DETALLE_COMPRA)* |
| **incluye** (N:M) | PEDIDO | (1,N) | VARIANTE_PRODUCTO | (0,N) *(vía DETALLE_PEDIDO)* |
| genera_movimiento | VARIANTE_PRODUCTO | (0,N) | MOVIMIENTO_STOCK | (1,1) |

### 7.5 Vista de apoyo — Mermaid ER (notación Crow's Foot, referencial)

```mermaid
erDiagram
    ROL ||--o{ USUARIO : tiene
    EMPLEADO ||--o| USUARIO : posee
    EMPLEADO ||--o{ COMPRA : registra
    EMPLEADO ||--o{ PEDIDO : atiende
    EMPLEADO ||--o{ MOVIMIENTO_STOCK : ejecuta
    PROVEEDOR ||--o{ COMPRA : suministra
    CLIENTE ||--o{ PEDIDO : realiza
    CATEGORIA ||--o{ PRODUCTO : clasifica
    PRODUCTO ||--o{ VARIANTE_PRODUCTO : genera
    TALLA ||--o{ VARIANTE_PRODUCTO : define
    COLOR ||--o{ VARIANTE_PRODUCTO : define
    COMPRA ||--o{ DETALLE_COMPRA : contiene
    VARIANTE_PRODUCTO ||--o{ DETALLE_COMPRA : incluida_en
    PEDIDO ||--o{ DETALLE_PEDIDO : incluye
    VARIANTE_PRODUCTO ||--o{ DETALLE_PEDIDO : incluida_en
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
        string nombres
        string apellidos
        string dpi
    }
    CLIENTE {
        int cliente_id PK
        string tipo_cliente
        string nit
    }
    PROVEEDOR {
        int proveedor_id PK
        string nit
    }
    CATEGORIA {
        int categoria_id PK
        string nombre_categoria
    }
    PRODUCTO {
        int producto_id PK
        int categoria_id FK
        string marca
        string modelo
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
    }
    COMPRA {
        int compra_id PK
        int proveedor_id FK
        int empleado_id FK
        date fecha_compra
    }
    DETALLE_COMPRA {
        int compra_id FK
        int variante_id FK
        int cantidad
        decimal costo_unitario
    }
    PEDIDO {
        int pedido_id PK
        int cliente_id FK
        int empleado_id FK
        date fecha_pedido
    }
    DETALLE_PEDIDO {
        int pedido_id FK
        int variante_id FK
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
| ≥8 entidades principales | ✅ 13 entidades principales (sin contar asociativas) |
| ≥2 relaciones N:M resueltas | ✅ COMPRA↔VARIANTE_PRODUCTO y PEDIDO↔VARIANTE_PRODUCTO, vía DETALLE_COMPRA y DETALLE_PEDIDO |
| Normalización 3FN | Se demostrará con ejemplo en Entrega 2 (ej. separación de TALLA/COLOR como catálogos evita dependencias transitivas y redundancia en VARIANTE_PRODUCTO) |
| ≥15 restricciones explícitas | Se implementan en DDL (Entrega 2): PKs, FKs, UNIQUE (nit, username, sku), CHECK (stock_actual >= 0, cantidad > 0, tipo_movimiento IN (...)), NOT NULL |
| ≥2 triggers / procedimientos | Planeado para Entrega 3: trigger de actualización automática de stock al insertar DETALLE_COMPRA/DETALLE_PEDIDO/MOVIMIENTO_STOCK; procedimiento de cálculo de total de pedido con descuento mayorista |
| ≥3 roles de seguridad | Administrador, Bodeguero, Vendedor — ya reflejados en entidad ROL |

---

## 8. Planificación — Cronograma (Gantt textual, 12 semanas)

| Semana | Actividad | Entregable | Responsable(s) |
|---|---|---|---|
| 1 | Levantamiento del caso de negocio y RF/RD | Borrador de requerimientos | Todo el equipo |
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

El equipo utilizó un agente de IA (Claude, Anthropic) como asistente en la redacción de esta propuesta, el diseño conceptual del modelo ER y la generación del script de automatización de repositorio. El detalle completo del uso, prompts y validación se documenta en `docs/bitacora-ia/BITACORA_IA.md`, conforme al estándar S8/R-Bitácora del proyecto.

MDEOF

echo ">> Generando README.md..."
cat > "README.md" << 'MDEOF'
# Pavanamoon — Sistema de Gestión de Inventario y Distribución de Calzado

Proyecto de base de datos relacional para la Universidad Mariano Gálvez de Guatemala. Sistema para centralizar la gestión de inventario, compras a proveedores, clientes (detalle y mayoreo), pedidos, movimientos de stock y control de acceso por roles de la empresa Pavanamoon.

## Integrantes

| Nombre completo | Carné |
|---|---|
| _(completar)_ | _(completar)_ |
| _(completar)_ | _(completar)_ |
| _(completar)_ | _(completar)_ |

## SGBD

**MySQL**

## Estructura del repositorio

```
pavanamoon/
├── README.md
├── .gitignore
├── .env.example
├── INSTALL.md
├── docs/
│   ├── entrega-1/ entrega-2/ entrega-3/ entrega-4/
│   ├── diagramas/
│   ├── certificaciones/
│   ├── bitacora-ia/
│   └── casos-prueba/
├── sql/
│   ├── ddl/ dml/ views/ triggers/ procedures/ security/
└── web/                # Aplicación web (desde Entrega 2)
```

## Estado del proyecto

| Entrega | Estado | Tag |
|---|---|---|
| Entrega 1 — Análisis y diseño conceptual | ✅ Completada | `entrega-1` |
| Entrega 2 — Diseño lógico e implementación base | ⏳ Pendiente | `entrega-2` |
| Entrega 3 — Implementación avanzada y seguridad | ⏳ Pendiente | `entrega-3` |
| Entrega 4 — Integración y defensa oral | ⏳ Pendiente | `entrega-4` |

## Instalación

Ver [`INSTALL.md`](./INSTALL.md) (se completará a partir de la Entrega 2, cuando existan scripts DDL ejecutables).

## Documentación

- Propuesta y diseño conceptual: [`docs/entrega-1/ENTREGA1_PROPUESTA.md`](./docs/entrega-1/ENTREGA1_PROPUESTA.md)
- Bitácora de uso de IA: [`docs/bitacora-ia/BITACORA_IA.md`](./docs/bitacora-ia/BITACORA_IA.md)
- Certificaciones de calidad por entrega: [`docs/certificaciones/`](./docs/certificaciones/)

## Enlaces

- Repositorio: _(agregar URL de GitHub)_
- Aplicación desplegada: _(se agregará desde Entrega 2)_

MDEOF

echo ">> Generando docs/bitacora-ia/BITACORA_IA.md..."
cat > "docs/bitacora-ia/BITACORA_IA.md" << 'MDEOF'
# Bitácora de Agentes de IA — Pavanamoon

Registro obligatorio de uso de agentes de inteligencia artificial durante el desarrollo del proyecto (Sección 10 de la guía). Cada entrada debe completarse honestamente y ser verificada por el equipo antes de cada tag de entrega.

---

## Entrada 1

| Campo | Detalle |
|---|---|
| **Fecha** | _(completar con la fecha real de la sesión)_ |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Redactar la propuesta de Entrega 1: descripción del problema, requerimientos funcionales (RF) y de datos (RD), matriz de trazabilidad, diseño conceptual del modelo Entidad-Relación en notación Chen (13 entidades, 2 relaciones N:M resueltas), cronograma Gantt textual, y generar plantillas de README, certificación y script de automatización Git. |
| **Prompt utilizado** | Resumen: "Actúa como Arquitecto Senior de BD... genera Entrega 1 para el caso de negocio Pavanamoon (sistema de inventario y distribución de calzado) con: propuesta, RF/RD, matriz de trazabilidad, diagrama ER en notación Chen (Mermaid/PlantUML), cronograma, README, bitácora IA, certificación y script bash de automatización Git." |
| **Resultado obtenido** | Documento `ENTREGA1_PROPUESTA.md` completo, `README.md`, plantilla de bitácora, plantilla de certificación, y script `setup_entrega1.sh` que crea la estructura de carpetas y ejecuta commit/tag/push. |
| **Validación del grupo** | _(completar: el equipo debe revisar que el número de entidades, las relaciones N:M, y los RF/RD reflejen fielmente el caso de negocio real que conocen; corregir/ajustar nombres, reglas de negocio de descuentos mayoristas, y confirmar el SGBD con el catedrático)_ |
| **Estándares aplicados (post-IA)** | Se verificó que la estructura de carpetas coincide con la Sección 7 de la guía; que el modelo cumple los mínimos de la Sección 5 (≥8 entidades, ≥2 N:M); que el diagrama Chen se documenta como especificación textual dado que Mermaid/PlantUML no soportan notación Chen nativa (transparencia metodológica, estándar D3). |
| **Responsable** | _(nombre del integrante que validó esta entrada)_ |

---

## Entrada 2 _(plantilla para próximo uso)_

| Campo | Detalle |
|---|---|
| **Fecha** | |
| **Herramienta** | |
| **Objetivo** | |
| **Prompt utilizado** | |
| **Resultado obtenido** | |
| **Validación del grupo** | |
| **Estándares aplicados (post-IA)** | |
| **Responsable** | |

MDEOF

echo ">> Generando docs/certificaciones/CERTIFICACION_ENTREGA_1.md..."
cat > "docs/certificaciones/CERTIFICACION_ENTREGA_1.md" << 'MDEOF'
# Certificación de Calidad — Entrega 1
## Proyecto Pavanamoon — Sistema de Gestión de Inventario y Distribución de Calzado

Nosotros, los integrantes del equipo abajo firmantes, certificamos que la Entrega 1 cumple con lo siguiente:

- [ ] Cumplimos la estructura de carpetas obligatoria (Sección 7 de la guía)
- [ ] Cumplimos los estándares SQL aplicables a esta etapa (Sección 6.2) — *no aplica DDL aún; se retoma en Entrega 2*
- [ ] Cumplimos los estándares del repositorio Git (Sección 6.1): README, commits descriptivos, tag `entrega-1`
- [ ] La bitácora de IA está actualizada (`docs/bitacora-ia/BITACORA_IA.md`)
- [ ] Los casos de prueba fueron ejecutados y documentados — *no aplica en Entrega 1*
- [ ] No hay credenciales expuestas en el repositorio

## Firmas

| Nombre completo | Carné | Firma / Confirmación |
|---|---|---|
| | | |
| | | |
| | | |

**Fecha de firma:** _____________________

> Nota: sin este certificado firmado, la entrega obtiene máximo 70% en el bloque "Calidad y estándares" (Sección 8 de la guía).

MDEOF

echo ">> Generando docs/diagramas/GUIA_IMPORTAR_DRAWIO.md..."
cat > "docs/diagramas/GUIA_IMPORTAR_DRAWIO.md" << 'MDEOF'
# Guía — Importar el diagrama ER (Chen) a draw.io y exportar PNG/PDF

Archivo: `pavanamoon_ER_chen.drawio` (contiene 13 entidades, 14 relaciones —12 de tipo 1:N y 2 de tipo N:M con atributos propios— y 45 atributos, en notación Chen: rectángulo = entidad, rombo = relación, óvalo = atributo).

## Paso a paso

1. Abre **https://app.diagrams.net** (draw.io) en el navegador. No necesitas cuenta si eliges "Decide más tarde" / trabajar sin guardar en la nube.
2. En la pantalla de inicio, elige **"Abrir archivo existente"** (Open Existing Diagram) → selecciona el archivo `pavanamoon_ER_chen.drawio`.
   - Alternativa: en el lienzo en blanco ve a **File → Import from → Device** y selecciona el archivo.
3. El diagrama se cargará automáticamente con todas las formas ya conectadas y posicionadas por módulo (Seguridad, Catálogo, Compras, Ventas, Movimientos).
4. **Ajustes recomendados antes de exportar:**
   - Revisa que ninguna etiqueta se superponga; arrastra los óvalos de atributos si es necesario (todas las conexiones se mantienen).
   - Puedes seleccionar todo (`Ctrl+A`) y usar **Arrange → Layout → Organic** o mover manualmente si prefieres reordenar.
   - La leyenda (esquina superior izquierda) explica la notación: PK subrayada, atributos derivados con línea punteada, atributos multivaluados con borde grueso, relaciones N:M en rombo naranja con atributos propios.
5. **Exportar como PNG** (para el repositorio):
   - Ve a **File → Export as → PNG**.
   - Marca la opción **"Selection"** desmarcada (para exportar todo el diagrama) y **"Transparent Background"** desmarcada (fondo blanco para mejor lectura).
   - Resolución recomendada: 200% o 300% de escala para buena nitidez.
   - Guarda como `pavanamoon_ER_chen.png`.
6. **Exportar como PDF**:
   - Ve a **File → Export as → PDF**.
   - Elige **"Fit page(s) to drawing"** para que no se corte el diagrama.
   - Guarda como `pavanamoon_ER_chen.pdf`.
7. **Guardar el archivo editable** (obligatorio por el estándar D3 — "ER y relacional en editable + PNG/PDF"):
   - Ve a **File → Save as** y confirma que se guarde en formato `.drawio` (XML editable).
8. Coloca los 3 archivos resultantes en la carpeta del repositorio:
   ```
   docs/diagramas/pavanamoon_ER_chen.drawio   (editable)
   docs/diagramas/pavanamoon_ER_chen.png      (imagen)
   docs/diagramas/pavanamoon_ER_chen.pdf      (PDF)
   ```
9. Haz commit de los 3 archivos:
   ```bash
   git add docs/diagramas/
   git commit -m "docs(diagrama): agrega diagrama ER en notacion Chen (editable, PNG, PDF)"
   git push
   ```

## Nota metodológica (para tu defensa oral)

Las relaciones **N:M** (`contiene` entre COMPRA–VARIANTE_PRODUCTO, e `incluye` entre PEDIDO–VARIANTE_PRODUCTO) se modelaron con **atributos propios sobre el rombo** (cantidad, costo_unitario/precio_unitario, subtotal derivado), que es la forma correcta en notación Chen pura. Estas relaciones N:M se traducirán a las tablas `DETALLE_COMPRA` y `DETALLE_PEDIDO` durante el paso de **modelo relacional** en la Entrega 2 (regla estándar de transformación ER→Relacional: toda relación N:M se convierte en una tabla con las FK de ambas entidades participantes más sus atributos propios como PK compuesta o PK propia).

MDEOF

echo ">> Generando docs/diagramas/pavanamoon_ER_chen.drawio (diagrama ER Chen)..."
cat > docs/diagramas/pavanamoon_ER_chen.drawio.b64 << 'B64EOF'
PG14ZmlsZSBob3N0PSJhcHAuZGlhZ3JhbXMubmV0IiBhZ2VudD0icGF2YW5hbW9vbi1nZW5lcmF0b3IiIHZlcnNpb249IjI0LjAuMCI+CiAgPGRpYWdyYW0gaWQ9InBhdmFuYW1vb24tZXItY2hlbiIgbmFtZT0iRVItQ2hlbi1QYXZhbmFtb29uIj4KICAgIDxteEdyYXBoTW9kZWwgZHg9IjE4MDAiIGR5PSIxMjAwIiBncmlkPSIxIiBncmlkU2l6ZT0iMTAiIGd1aWRlcz0iMSIgdG9vbHRpcHM9IjEiIGNvbm5lY3Q9IjEiIGFycm93cz0iMSIgZm9sZD0iMSIgcGFnZT0iMSIgcGFnZVNjYWxlPSIxIiBwYWdlV2lkdGg9IjE2MDAiIHBhZ2VIZWlnaHQ9IjEyMDAiIG1hdGg9IjAiIHNoYWRvdz0iMCI+CiAgICAgIDxyb290PgogICAgICAgIDxteENlbGwgaWQ9IjAiIC8+CiAgICAgICAgPG14Q2VsbCBpZD0iMSIgcGFyZW50PSIwIiAvPgo8bXhDZWxsIGlkPSJuMyIgdmFsdWU9IlJPTCIgc3R5bGU9InJvdW5kZWQ9MDt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZGFlOGZjO3N0cm9rZUNvbG9yPSMxYTUyNzY7Zm9udFNpemU9MTM7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI0MCIgeT0iNDAiIHdpZHRoPSIxNzAiIGhlaWdodD0iNjAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNCIgdmFsdWU9IlVTVUFSSU8iIHN0eWxlPSJyb3VuZGVkPTA7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2RhZThmYztzdHJva2VDb2xvcj0jMWE1Mjc2O2ZvbnRTaXplPTEzO2ZvbnRTdHlsZT0xO3N0cm9rZVdpZHRoPTI7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iNDAiIHk9IjI2MCIgd2lkdGg9IjE3MCIgaGVpZ2h0PSI2MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im41IiB2YWx1ZT0iRU1QTEVBRE8iIHN0eWxlPSJyb3VuZGVkPTA7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2RhZThmYztzdHJva2VDb2xvcj0jMWE1Mjc2O2ZvbnRTaXplPTEzO2ZvbnRTdHlsZT0xO3N0cm9rZVdpZHRoPTI7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMzIwIiB5PSIxNTAiIHdpZHRoPSIxNzAiIGhlaWdodD0iNjAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNiIgdmFsdWU9IkNBVEVHT1JJQSIgc3R5bGU9InJvdW5kZWQ9MDt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZGFlOGZjO3N0cm9rZUNvbG9yPSMxYTUyNzY7Zm9udFNpemU9MTM7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI2MjAiIHk9IjQwIiB3aWR0aD0iMTcwIiBoZWlnaHQ9IjYwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjciIHZhbHVlPSJQUk9EVUNUTyIgc3R5bGU9InJvdW5kZWQ9MDt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZGFlOGZjO3N0cm9rZUNvbG9yPSMxYTUyNzY7Zm9udFNpemU9MTM7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI2MjAiIHk9IjIyMCIgd2lkdGg9IjE3MCIgaGVpZ2h0PSI2MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im44IiB2YWx1ZT0iVEFMTEEiIHN0eWxlPSJyb3VuZGVkPTA7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2RhZThmYztzdHJva2VDb2xvcj0jMWE1Mjc2O2ZvbnRTaXplPTEzO2ZvbnRTdHlsZT0xO3N0cm9rZVdpZHRoPTI7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iOTAwIiB5PSI0MCIgd2lkdGg9IjE3MCIgaGVpZ2h0PSI2MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im45IiB2YWx1ZT0iQ09MT1IiIHN0eWxlPSJyb3VuZGVkPTA7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2RhZThmYztzdHJva2VDb2xvcj0jMWE1Mjc2O2ZvbnRTaXplPTEzO2ZvbnRTdHlsZT0xO3N0cm9rZVdpZHRoPTI7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTA4MCIgeT0iNDAiIHdpZHRoPSIxNzAiIGhlaWdodD0iNjAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTAiIHZhbHVlPSJWQVJJQU5URV9QUk9EVUNUTyIgc3R5bGU9InJvdW5kZWQ9MDt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZGFlOGZjO3N0cm9rZUNvbG9yPSMxYTUyNzY7Zm9udFNpemU9MTM7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI5MDAiIHk9IjQwMCIgd2lkdGg9IjIwMCIgaGVpZ2h0PSI2MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMSIgdmFsdWU9IlBST1ZFRURPUiIgc3R5bGU9InJvdW5kZWQ9MDt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZGFlOGZjO3N0cm9rZUNvbG9yPSMxYTUyNzY7Zm9udFNpemU9MTM7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI0MCIgeT0iNTYwIiB3aWR0aD0iMTcwIiBoZWlnaHQ9IjYwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEyIiB2YWx1ZT0iQ09NUFJBIiBzdHlsZT0icm91bmRlZD0wO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNkYWU4ZmM7c3Ryb2tlQ29sb3I9IzFhNTI3Njtmb250U2l6ZT0xMztmb250U3R5bGU9MTtzdHJva2VXaWR0aD0yOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjMyMCIgeT0iNTYwIiB3aWR0aD0iMTcwIiBoZWlnaHQ9IjYwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEzIiB2YWx1ZT0iQ0xJRU5URSIgc3R5bGU9InJvdW5kZWQ9MDt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZGFlOGZjO3N0cm9rZUNvbG9yPSMxYTUyNzY7Zm9udFNpemU9MTM7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIxNDAwIiB5PSIyMjAiIHdpZHRoPSIxNzAiIGhlaWdodD0iNjAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTQiIHZhbHVlPSJQRURJRE8iIHN0eWxlPSJyb3VuZGVkPTA7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2RhZThmYztzdHJva2VDb2xvcj0jMWE1Mjc2O2ZvbnRTaXplPTEzO2ZvbnRTdHlsZT0xO3N0cm9rZVdpZHRoPTI7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTQwMCIgeT0iNDAwIiB3aWR0aD0iMTcwIiBoZWlnaHQ9IjYwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjE1IiB2YWx1ZT0iTU9WSU1JRU5UT19TVE9DSyIgc3R5bGU9InJvdW5kZWQ9MDt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZGFlOGZjO3N0cm9rZUNvbG9yPSMxYTUyNzY7Zm9udFNpemU9MTM7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI5MDAiIHk9IjY2MCIgd2lkdGg9IjIxMCIgaGVpZ2h0PSI2MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xNiIgdmFsdWU9InRpZW5lIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZDVlOGQ0O3N0cm9rZUNvbG9yPSMyZTdkMzI7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iNDAiIHk9IjE1MCIgd2lkdGg9IjE1MCIgaGVpZ2h0PSI3MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xNyIgdmFsdWU9IigxLDEpIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSM1NTU1NTU7Zm9udFNpemU9MTA7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjMiIHRhcmdldD0ibjE2Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xOCIgdmFsdWU9IigwLE4pIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSM1NTU1NTU7Zm9udFNpemU9MTA7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjQiIHRhcmdldD0ibjE2Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xOSIgdmFsdWU9InBvc2VlIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZDVlOGQ0O3N0cm9rZUNvbG9yPSMyZTdkMzI7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMjAwIiB5PSIyNjAiIHdpZHRoPSIxNTAiIGhlaWdodD0iNzAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMjAiIHZhbHVlPSIoMCwxKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im41IiB0YXJnZXQ9Im4xOSI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMjEiIHZhbHVlPSIoMSwxKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im40IiB0YXJnZXQ9Im4xOSI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMjIiIHZhbHVlPSJyZWdpc3RyYSIgc3R5bGU9InJob21idXM7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2Q1ZThkNDtzdHJva2VDb2xvcj0jMmU3ZDMyO2ZvbnRTaXplPTExO2ZvbnRTdHlsZT0xOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjMyMCIgeT0iNDAwIiB3aWR0aD0iMTUwIiBoZWlnaHQ9IjcwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjIzIiB2YWx1ZT0iKDAsTikiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuNSIgdGFyZ2V0PSJuMjIiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjI0IiB2YWx1ZT0iKDEsMSkiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTIiIHRhcmdldD0ibjIyIj48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4yNSIgdmFsdWU9ImF0aWVuZGUiIHN0eWxlPSJyaG9tYnVzO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNkNWU4ZDQ7c3Ryb2tlQ29sb3I9IzJlN2QzMjtmb250U2l6ZT0xMTtmb250U3R5bGU9MTsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI3MDAiIHk9IjQwMCIgd2lkdGg9IjE0MCIgaGVpZ2h0PSI3MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4yNiIgdmFsdWU9IigwLE4pIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSM1NTU1NTU7Zm9udFNpemU9MTA7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjUiIHRhcmdldD0ibjI1Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4yNyIgdmFsdWU9IigxLDEpIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSM1NTU1NTU7Zm9udFNpemU9MTA7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjE0IiB0YXJnZXQ9Im4yNSI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMjgiIHZhbHVlPSJlamVjdXRhIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZDVlOGQ0O3N0cm9rZUNvbG9yPSMyZTdkMzI7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iNTUwIiB5PSI2NjAiIHdpZHRoPSIxNTAiIGhlaWdodD0iNzAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMjkiIHZhbHVlPSIoMCxOKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im41IiB0YXJnZXQ9Im4yOCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMzAiIHZhbHVlPSIoMSwxKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xNSIgdGFyZ2V0PSJuMjgiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjMxIiB2YWx1ZT0ic3VtaW5pc3RyYSIgc3R5bGU9InJob21idXM7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2Q1ZThkNDtzdHJva2VDb2xvcj0jMmU3ZDMyO2ZvbnRTaXplPTExO2ZvbnRTdHlsZT0xOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjQwIiB5PSI0NjAiIHdpZHRoPSIxNTAiIGhlaWdodD0iNzAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMzIiIHZhbHVlPSIoMCxOKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMSIgdGFyZ2V0PSJuMzEiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjMzIiB2YWx1ZT0iKDEsMSkiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTIiIHRhcmdldD0ibjMxIj48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4zNCIgdmFsdWU9InJlYWxpemEiIHN0eWxlPSJyaG9tYnVzO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNkNWU4ZDQ7c3Ryb2tlQ29sb3I9IzJlN2QzMjtmb250U2l6ZT0xMTtmb250U3R5bGU9MTsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIxNDAwIiB5PSIzMjAiIHdpZHRoPSIxNTAiIGhlaWdodD0iNzAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMzUiIHZhbHVlPSIoMCxOKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMyIgdGFyZ2V0PSJuMzQiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjM2IiB2YWx1ZT0iKDEsMSkiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTQiIHRhcmdldD0ibjM0Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4zNyIgdmFsdWU9ImNsYXNpZmljYSIgc3R5bGU9InJob21idXM7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2Q1ZThkNDtzdHJva2VDb2xvcj0jMmU3ZDMyO2ZvbnRTaXplPTExO2ZvbnRTdHlsZT0xOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjYyMCIgeT0iMTQwIiB3aWR0aD0iMTUwIiBoZWlnaHQ9IjcwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjM4IiB2YWx1ZT0iKDEsTikiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuNiIgdGFyZ2V0PSJuMzciPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjM5IiB2YWx1ZT0iKDEsMSkiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuNyIgdGFyZ2V0PSJuMzciPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjQwIiB2YWx1ZT0iZ2VuZXJhX3ZhcmlhbnRlIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZDVlOGQ0O3N0cm9rZUNvbG9yPSMyZTdkMzI7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iNzgwIiB5PSIzMDAiIHdpZHRoPSIxNjAiIGhlaWdodD0iNzAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNDEiIHZhbHVlPSIoMSxOKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im43IiB0YXJnZXQ9Im40MCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNDIiIHZhbHVlPSIoMSwxKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMCIgdGFyZ2V0PSJuNDAiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjQzIiB2YWx1ZT0iZGVmaW5lX3RhbGxhIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZDVlOGQ0O3N0cm9rZUNvbG9yPSMyZTdkMzI7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iOTAwIiB5PSIyMjAiIHdpZHRoPSIxNTAiIGhlaWdodD0iNzAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNDQiIHZhbHVlPSIoMSxOKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im44IiB0YXJnZXQ9Im40MyI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNDUiIHZhbHVlPSIoMSwxKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMCIgdGFyZ2V0PSJuNDMiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjQ2IiB2YWx1ZT0iZGVmaW5lX2NvbG9yIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZDVlOGQ0O3N0cm9rZUNvbG9yPSMyZTdkMzI7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTA4MCIgeT0iMjIwIiB3aWR0aD0iMTUwIiBoZWlnaHQ9IjcwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjQ3IiB2YWx1ZT0iKDEsTikiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuOSIgdGFyZ2V0PSJuNDYiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjQ4IiB2YWx1ZT0iKDEsMSkiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTAiIHRhcmdldD0ibjQ2Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im40OSIgdmFsdWU9ImdlbmVyYV9tb3ZpbWllbnRvIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZDVlOGQ0O3N0cm9rZUNvbG9yPSMyZTdkMzI7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iOTUwIiB5PSI1NjAiIHdpZHRoPSIxNzAiIGhlaWdodD0iNzAiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNTAiIHZhbHVlPSIoMCxOKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMCIgdGFyZ2V0PSJuNDkiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjUxIiB2YWx1ZT0iKDEsMSkiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTUiIHRhcmdldD0ibjQ5Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im41MiIgdmFsdWU9ImNvbnRpZW5lIiBzdHlsZT0icmhvbWJ1czt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZlNmNjO3N0cm9rZUNvbG9yPSNkMzU0MDA7Zm9udFNpemU9MTE7Zm9udFN0eWxlPTE7c3Ryb2tlV2lkdGg9MzsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI0ODAiIHk9IjQ4MCIgd2lkdGg9IjE3MCIgaGVpZ2h0PSI3MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im41MyIgdmFsdWU9IigxLE4pIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSM1NTU1NTU7Zm9udFNpemU9MTA7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjEyIiB0YXJnZXQ9Im41MiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNTQiIHZhbHVlPSIoMCxOKSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jNTU1NTU1O2ZvbnRTaXplPTEwOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMCIgdGFyZ2V0PSJuNTIiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjU1IiB2YWx1ZT0iaW5jbHV5ZSIgc3R5bGU9InJob21idXM7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZTZjYztzdHJva2VDb2xvcj0jZDM1NDAwO2ZvbnRTaXplPTExO2ZvbnRTdHlsZT0xO3N0cm9rZVdpZHRoPTM7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTEzMCIgeT0iNDgwIiB3aWR0aD0iMTcwIiBoZWlnaHQ9IjcwIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjU2IiB2YWx1ZT0iKDEsTikiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9IzU1NTU1NTtmb250U2l6ZT0xMDsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTQiIHRhcmdldD0ibjU1Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im41NyIgdmFsdWU9IigwLE4pIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSM1NTU1NTU7Zm9udFNpemU9MTA7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjEwIiB0YXJnZXQ9Im41NSI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNTgiIHZhbHVlPSJjYW50aWRhZCIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjM4MCIgeT0iNjAwIiB3aWR0aD0iMTEwIiBoZWlnaHQ9IjQyIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjU5IiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjUyIiB0YXJnZXQ9Im41OCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNjAiIHZhbHVlPSJjb3N0b191bml0YXJpbyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjU2MCIgeT0iNjAwIiB3aWR0aD0iMTEwIiBoZWlnaHQ9IjQyIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjYxIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjUyIiB0YXJnZXQ9Im42MCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNjIiIHZhbHVlPSJzdWJ0b3RhbCIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwO2Rhc2hlZD0xOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjQ4MCIgeT0iMzgwIiB3aWR0aD0iMTEwIiBoZWlnaHQ9IjQyIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjYzIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjUyIiB0YXJnZXQ9Im42MiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNjQiIHZhbHVlPSJjYW50aWRhZCIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjEwNTAiIHk9IjYwMCIgd2lkdGg9IjExMCIgaGVpZ2h0PSI0MiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im42NSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im41NSIgdGFyZ2V0PSJuNjQiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjY2IiB2YWx1ZT0icHJlY2lvX3VuaXRhcmlvIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTIzMCIgeT0iNjAwIiB3aWR0aD0iMTEwIiBoZWlnaHQ9IjQyIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjY3IiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjU1IiB0YXJnZXQ9Im42NiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNjgiIHZhbHVlPSJzdWJ0b3RhbCIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwO2Rhc2hlZD0xOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjExNTAiIHk9IjM4MCIgd2lkdGg9IjExMCIgaGVpZ2h0PSI0MiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im42OSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im41NSIgdGFyZ2V0PSJuNjgiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjcwIiB2YWx1ZT0iJmx0O3UmZ3Q7cm9sX2lkJmx0Oy91Jmd0OyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9Ii0xNDAiIHk9IjEwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjcxIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjMiIHRhcmdldD0ibjcwIj48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im43MiIgdmFsdWU9Im5vbWJyZV9yb2wiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSItMTQwIiB5PSI3MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im43MyIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4zIiB0YXJnZXQ9Im43MiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNzQiIHZhbHVlPSImbHQ7dSZndDt1c3VhcmlvX2lkJmx0Oy91Jmd0OyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9Ii0xNjAiIHk9IjI2MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im43NSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im40IiB0YXJnZXQ9Im43NCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNzYiIHZhbHVlPSJ1c2VybmFtZSIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9Ii0xNjAiIHk9IjMyMCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im43NyIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im40IiB0YXJnZXQ9Im43NiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNzgiIHZhbHVlPSJlc3RhZG8iIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSItMTYwIiB5PSIzODAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuNzkiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuNCIgdGFyZ2V0PSJuNzgiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjgwIiB2YWx1ZT0iJmx0O3UmZ3Q7ZW1wbGVhZG9faWQmbHQ7L3UmZ3Q7IiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMzIwIiB5PSI0MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im44MSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im41IiB0YXJnZXQ9Im44MCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuODIiIHZhbHVlPSJub21icmVzX2FwZWxsaWRvcyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjUwMCIgeT0iNDAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuODMiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuNSIgdGFyZ2V0PSJuODIiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjg0IiB2YWx1ZT0iZHBpIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMzIwIiB5PSItMzAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuODUiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuNSIgdGFyZ2V0PSJuODQiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjg2IiB2YWx1ZT0idGVsZWZvbm8iIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDtzdHJva2VXaWR0aD0zOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjE1MCIgeT0iNDAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuODciIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuNSIgdGFyZ2V0PSJuODYiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjg4IiB2YWx1ZT0iJmx0O3UmZ3Q7Y2F0ZWdvcmlhX2lkJmx0Oy91Jmd0OyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjYyMCIgeT0iLTYwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjg5IiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjYiIHRhcmdldD0ibjg4Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im45MCIgdmFsdWU9Im5vbWJyZV9jYXRlZ29yaWEiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI0NjAiIHk9Ii02MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im45MSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im42IiB0YXJnZXQ9Im45MCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuOTIiIHZhbHVlPSImbHQ7dSZndDtwcm9kdWN0b19pZCZsdDsvdSZndDsiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI0NjAiIHk9IjI2MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im45MyIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im43IiB0YXJnZXQ9Im45MiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuOTQiIHZhbHVlPSJtYXJjYV9tb2RlbG8iIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI0NjAiIHk9IjE4MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im45NSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im43IiB0YXJnZXQ9Im45NCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuOTYiIHZhbHVlPSJwcmVjaW9fdmVudGEiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI2MjAiIHk9IjMyMCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im45NyIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im43IiB0YXJnZXQ9Im45NiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuOTgiIHZhbHVlPSImbHQ7dSZndDt0YWxsYV9pZCZsdDsvdSZndDsiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI5MDAiIHk9Ii02MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im45OSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im44IiB0YXJnZXQ9Im45OCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTAwIiB2YWx1ZT0idmFsb3JfdGFsbGEiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIxMDQwIiB5PSItNjAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTAxIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjgiIHRhcmdldD0ibjEwMCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTAyIiB2YWx1ZT0iJmx0O3UmZ3Q7Y29sb3JfaWQmbHQ7L3UmZ3Q7IiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTI1MCIgeT0iNDAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTAzIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjkiIHRhcmdldD0ibjEwMiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTA0IiB2YWx1ZT0ibm9tYnJlX2NvbG9yIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTI1MCIgeT0iMTAwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEwNSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im45IiB0YXJnZXQ9Im4xMDQiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEwNiIgdmFsdWU9IiZsdDt1Jmd0O3ZhcmlhbnRlX2lkJmx0Oy91Jmd0OyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjExNTAiIHk9IjQwMCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMDciIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTAiIHRhcmdldD0ibjEwNiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTA4IiB2YWx1ZT0ic2t1IiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7ZGFzaGVkPTE7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTE1MCIgeT0iNDYwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEwOSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMCIgdGFyZ2V0PSJuMTA4Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMTAiIHZhbHVlPSJzdG9ja19hY3R1YWwiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI5MDAiIHk9IjUwMCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMTEiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTAiIHRhcmdldD0ibjExMCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTEyIiB2YWx1ZT0ic3RvY2tfbWluaW1vIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iNzAwIiB5PSI0NjAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTEzIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjEwIiB0YXJnZXQ9Im4xMTIiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjExNCIgdmFsdWU9IiZsdDt1Jmd0O3Byb3ZlZWRvcl9pZCZsdDsvdSZndDsiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSItMTQwIiB5PSI1NjAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTE1IiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjExIiB0YXJnZXQ9Im4xMTQiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjExNiIgdmFsdWU9Im5vbWJyZV9lbXByZXNhIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iLTE0MCIgeT0iNjMwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjExNyIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMSIgdGFyZ2V0PSJuMTE2Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMTgiIHZhbHVlPSJuaXQiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSItMTQwIiB5PSI2OTAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTE5IiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjExIiB0YXJnZXQ9Im4xMTgiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEyMCIgdmFsdWU9IiZsdDt1Jmd0O2NvbXByYV9pZCZsdDsvdSZndDsiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIzMjAiIHk9IjY2MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMjEiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTIiIHRhcmdldD0ibjEyMCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTIyIiB2YWx1ZT0iZmVjaGFfY29tcHJhIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iNTAwIiB5PSI2NjAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTIzIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjEyIiB0YXJnZXQ9Im4xMjIiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEyNCIgdmFsdWU9InRvdGFsX2NvbXByYSIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwO2Rhc2hlZD0xOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjMyMCIgeT0iNzIwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEyNSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMiIgdGFyZ2V0PSJuMTI0Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMjYiIHZhbHVlPSImbHQ7dSZndDtjbGllbnRlX2lkJmx0Oy91Jmd0OyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjE2NTAiIHk9IjE1MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMjciIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTMiIHRhcmdldD0ibjEyNiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTI4IiB2YWx1ZT0idGlwb19jbGllbnRlIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTY1MCIgeT0iMjIwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEyOSIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xMyIgdGFyZ2V0PSJuMTI4Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMzAiIHZhbHVlPSJuaXQiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIxNjUwIiB5PSIyOTAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTMxIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjEzIiB0YXJnZXQ9Im4xMzAiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEzMiIgdmFsdWU9InRlbGVmb25vIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7c3Ryb2tlV2lkdGg9MzsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIxNjIwIiB5PSI5MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMzMiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTMiIHRhcmdldD0ibjEzMiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTM0IiB2YWx1ZT0iJmx0O3UmZ3Q7cGVkaWRvX2lkJmx0Oy91Jmd0OyIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjE2NTAiIHk9IjQwMCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMzUiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTQiIHRhcmdldD0ibjEzNCI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTM2IiB2YWx1ZT0iZmVjaGFfcGVkaWRvIiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iMTY1MCIgeT0iNDYwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjQ2IiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjEzNyIgc3R5bGU9ImVkZ2VTdHlsZT1ub25lO2h0bWw9MTtlbmRBcnJvdz1ub25lO3N0YXJ0QXJyb3c9bm9uZTtzdHJva2VDb2xvcj0jYjc5NTBiOyIgZWRnZT0iMSIgcGFyZW50PSIxIiBzb3VyY2U9Im4xNCIgdGFyZ2V0PSJuMTM2Ij48bXhHZW9tZXRyeSByZWxhdGl2ZT0iMSIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xMzgiIHZhbHVlPSJ0b3RhbF9wZWRpZG8iIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDtkYXNoZWQ9MTsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIxNjUwIiB5PSI1MjAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTM5IiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjE0IiB0YXJnZXQ9Im4xMzgiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjE0MCIgdmFsdWU9IiZsdDt1Jmd0O21vdmltaWVudG9faWQmbHQ7L3UmZ3Q7IiBzdHlsZT0iZWxsaXBzZTt3aGl0ZVNwYWNlPXdyYXA7aHRtbD0xO2ZpbGxDb2xvcj0jZmZmMmNjO3N0cm9rZUNvbG9yPSNiNzk1MGI7Zm9udFNpemU9MTA7IiB2ZXJ0ZXg9IjEiIHBhcmVudD0iMSI+PG14R2VvbWV0cnkgeD0iOTAwIiB5PSI3ODAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTQxIiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjE1IiB0YXJnZXQ9Im4xNDAiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjE0MiIgdmFsdWU9InRpcG9fbW92aW1pZW50byIgc3R5bGU9ImVsbGlwc2U7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZmZjJjYztzdHJva2VDb2xvcj0jYjc5NTBiO2ZvbnRTaXplPTEwOyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjEwODAiIHk9Ijc4MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xNDMiIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTUiIHRhcmdldD0ibjE0MiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTQ0IiB2YWx1ZT0iY2FudGlkYWQiIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSIxMjYwIiB5PSI3ODAiIHdpZHRoPSIxMjAiIGhlaWdodD0iNDYiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTQ1IiBzdHlsZT0iZWRnZVN0eWxlPW5vbmU7aHRtbD0xO2VuZEFycm93PW5vbmU7c3RhcnRBcnJvdz1ub25lO3N0cm9rZUNvbG9yPSNiNzk1MGI7IiBlZGdlPSIxIiBwYXJlbnQ9IjEiIHNvdXJjZT0ibjE1IiB0YXJnZXQ9Im4xNDQiPjxteEdlb21ldHJ5IHJlbGF0aXZlPSIxIiBhcz0iZ2VvbWV0cnkiLz48L214Q2VsbD4KPG14Q2VsbCBpZD0ibjE0NiIgdmFsdWU9ImZlY2hhX21vdmltaWVudG8iIHN0eWxlPSJlbGxpcHNlO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNmZmYyY2M7c3Ryb2tlQ29sb3I9I2I3OTUwYjtmb250U2l6ZT0xMDsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSI5MDAiIHk9Ijg0MCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI0NiIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xNDciIHN0eWxlPSJlZGdlU3R5bGU9bm9uZTtodG1sPTE7ZW5kQXJyb3c9bm9uZTtzdGFydEFycm93PW5vbmU7c3Ryb2tlQ29sb3I9I2I3OTUwYjsiIGVkZ2U9IjEiIHBhcmVudD0iMSIgc291cmNlPSJuMTUiIHRhcmdldD0ibjE0NiI+PG14R2VvbWV0cnkgcmVsYXRpdmU9IjEiIGFzPSJnZW9tZXRyeSIvPjwvbXhDZWxsPgo8bXhDZWxsIGlkPSJuMTQ4IiB2YWx1ZT0iTEVZRU5EQSAtIE5vdGFjaW9uIENoZW4KLSBSZWN0YW5ndWxvID0gRW50aWRhZAotIFJvbWJvIHZlcmRlID0gUmVsYWNpb24gMTpOCi0gUm9tYm8gbmFyYW5qYSAoYm9yZGUgZ3J1ZXNvKSA9IFJlbGFjaW9uIE46TSBjb24gYXRyaWJ1dG9zIHByb3Bpb3MKLSBPdmFsbyA9IEF0cmlidXRvIHNpbXBsZSB8IHN1YnJheWFkbyA9IGxsYXZlIHByaW1hcmlhIChQSykKLSBPdmFsbyBwdW50ZWFkbyA9IEF0cmlidXRvIGRlcml2YWRvCi0gT3ZhbG8gYm9yZGUgZ3J1ZXNvID0gQXRyaWJ1dG8gbXVsdGl2YWx1YWRvCi0gRXRpcXVldGFzIChtaW4sbWF4KSBzb2JyZSBsYXMgbGluZWFzID0gY2FyZGluYWxpZGFkIiBzdHlsZT0icm91bmRlZD0xO3doaXRlU3BhY2U9d3JhcDtodG1sPTE7ZmlsbENvbG9yPSNlYWYyZjg7c3Ryb2tlQ29sb3I9IzY2NjY2Njtmb250U2l6ZT0xMDthbGlnbj1sZWZ0O3ZlcnRpY2FsQWxpZ249dG9wO3NwYWNpbmc9NjsiIHZlcnRleD0iMSIgcGFyZW50PSIxIj48bXhHZW9tZXRyeSB4PSItMTYwIiB5PSItMjYwIiB3aWR0aD0iNDIwIiBoZWlnaHQ9IjIwMCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CjxteENlbGwgaWQ9Im4xNDkiIHZhbHVlPSJQQVZBTkFNT09OIC0gU2lzdGVtYSBkZSBHZXN0aW9uIGRlIEludmVudGFyaW8geSBEaXN0cmlidWNpb24gZGUgQ2FsemFkbwpEaWFncmFtYSBFbnRpZGFkLVJlbGFjaW9uIChOb3RhY2lvbiBDaGVuKSAtIEVudHJlZ2EgMQpVbml2ZXJzaWRhZCBNYXJpYW5vIEdhbHZleiBkZSBHdWF0ZW1hbGEiIHN0eWxlPSJyb3VuZGVkPTE7d2hpdGVTcGFjZT13cmFwO2h0bWw9MTtmaWxsQ29sb3I9I2ZkZWJkMDtzdHJva2VDb2xvcj0jNjY2NjY2O2ZvbnRTaXplPTEwO2FsaWduPWxlZnQ7dmVydGljYWxBbGlnbj10b3A7c3BhY2luZz02OyIgdmVydGV4PSIxIiBwYXJlbnQ9IjEiPjxteEdlb21ldHJ5IHg9IjYyMCIgeT0iLTI2MCIgd2lkdGg9IjU2MCIgaGVpZ2h0PSI4MCIgYXM9Imdlb21ldHJ5Ii8+PC9teENlbGw+CiAgICAgIDwvcm9vdD4KICAgIDwvbXhHcmFwaE1vZGVsPgogIDwvZGlhZ3JhbT4KPC9teGZpbGU+Cg==
B64EOF
base64 -d docs/diagramas/pavanamoon_ER_chen.drawio.b64 > docs/diagramas/pavanamoon_ER_chen.drawio
rm docs/diagramas/pavanamoon_ER_chen.drawio.b64

echo ">> Generando .gitignore..."
cat > .gitignore << 'GITEOF'
# Entorno y credenciales
.env
*.env
!.env.example

# Dependencias
node_modules/
vendor/
__pycache__/
*.pyc

# Binarios / temporales
*.log
*.tmp
.DS_Store
Thumbs.db

# Editor
.vscode/
.idea/
GITEOF

echo ">> Generando .env.example (MySQL)..."
cat > .env.example << 'ENVEOF'
# Copiar este archivo como .env y completar con valores reales.
# NUNCA subir el archivo .env con credenciales reales al repositorio (estandar R6).

DB_ENGINE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_NAME=pavanamoon
DB_USER=pavanamoon_app
DB_PASSWORD=change_me
ENVEOF

echo ">> Generando INSTALL.md (placeholder, se completa en Entrega 2)..."
cat > INSTALL.md << 'INSTEOF'
# Instalacion

Este archivo se completara en la Entrega 2, cuando existan scripts DDL
ejecutables (sql/ddl/) y el modelo relacional normalizado.

SGBD: MySQL 8.x

Pendiente:
- Requisitos de MySQL (version, motor InnoDB para integridad referencial).
- Pasos para crear la base de datos y el usuario de aplicacion.
- Orden de ejecucion de scripts SQL (sql/ddl -> sql/dml -> sql/views ->
  sql/triggers -> sql/procedures -> sql/security).
- Variables de entorno requeridas (ver .env.example).
INSTEOF

echo ">> Estructura y archivos generados correctamente."
echo ""
echo ">> Inicializando control de versiones Git..."

if [ ! -d ".git" ]; then
    git init
    echo "Repositorio git inicializado."
else
    echo "Repositorio git ya existente, se reutiliza."
fi

git add .
git commit -m "feat(entrega-1): propuesta, requerimientos, modelo ER conceptual (Chen), diagrama editable, documentacion base y estructura de carpetas"

echo ">> Creando tag entrega-1..."
git tag -a entrega-1 -m "Entrega 1 - Analisis, propuesta y diseno conceptual"

echo ""
echo ">> Listo para push. Si aun no configuraste el remoto, ejecuta primero:"
echo "     git remote add origin https://github.com/TU-USUARIO/pavanamoon.git"
echo ""
read -p "Deseas hacer 'git push' al remoto 'origin' ahora? (s/n): " CONFIRM_PUSH

if [ "$CONFIRM_PUSH" = "s" ] || [ "$CONFIRM_PUSH" = "S" ]; then
    git branch -M main
    git push -u origin main
    git push origin entrega-1
    echo ">> Push completado (rama main + tag entrega-1)."
else
    echo ">> Push omitido. Puedes hacerlo manualmente despues con:"
    echo "     git push -u origin main"
    echo "     git push origin entrega-1"
fi

echo ""
echo "=============================================================="
echo " Entrega 1 lista. Recuerda:"
echo "   1. Completar nombres y carnes en README.md y CERTIFICACION_ENTREGA_1.md"
echo "   2. Firmar (o confirmar) la certificacion en docs/certificaciones/"
echo "   3. Abrir docs/diagramas/pavanamoon_ER_chen.drawio en app.diagrams.net,"
echo "      revisar/ajustar y exportar PNG + PDF a la misma carpeta"
echo "      (ver docs/diagramas/GUIA_IMPORTAR_DRAWIO.md paso a paso)."
echo "   4. SGBD confirmado: MySQL."
echo "=============================================================="

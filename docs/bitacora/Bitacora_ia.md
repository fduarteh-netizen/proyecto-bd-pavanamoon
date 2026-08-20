# Bitácora de Agentes de IA — Pavanamoon

Registro obligatorio de uso de agentes de inteligencia artificial durante el desarrollo del proyecto (Sección 10 de la guía). Equipo: Fernando Rafael Duarte Hernández, Luis Adolfo Martínez Hernández, Cristian Otoniel Pérez Ríos, José Alejandro Cabrera Gramajo.

---

## Entrada 1

| Campo | Detalle |
|---|---|
| **Fecha** | 17/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Redactar la propuesta inicial de Entrega 1, RF/RD, matriz de trazabilidad, diseño conceptual del modelo Entidad-Relación en notación Chen, cronograma, y generar plantillas de README, certificación y script de automatización Git. |
| **Prompt utilizado** | "Actúa como Arquitecto Senior de BD... genera Entrega 1 para el caso de negocio Pavanamoon con: propuesta, RF/RD, matriz de trazabilidad, diagrama ER en notación Chen, cronograma, README, bitácora IA, certificación y script bash de automatización Git." |
| **Resultado obtenido** | Documento de propuesta completo, README, plantilla de bitácora, certificación, y script de automatización de estructura y Git. |
| **Validación del grupo** | Se revisó que el número de entidades, relaciones N:M y RF/RD reflejaran el caso de negocio real; se confirmó MySQL como SGBD final. |
| **Estándares aplicados (post-IA)** | Estructura de carpetas Sección 7; mínimos de la Sección 5 (≥8 entidades, ≥2 N:M); transparencia metodológica sobre notación Chen en Mermaid (estándar D3). |
| **Responsable** | Fernando Rafael Duarte Hernández |

## Entrada 2

| Campo | Detalle |
|---|---|
| **Fecha** | 19/08/2026 |
| **Herramienta** | Gemini |
| **Objetivo** | Redacción de la propuesta conceptual y de negocio (segmentos B2C/B2B, tipos de suela, furgones de mercadería). |
| **Prompt utilizado** | "Genera el archivo de propuesta para Pavanamoon abarcando B2C, B2B, suelas y furgones." |
| **Resultado obtenido** | Documento base de propuesta comercial y contexto de negocio. |
| **Validación del grupo** | Se ajustaron términos de ventas al por mayor y tipos de suela para reflejar el modelo real de Pavanamoon (marca propia, sin campo `marca`). |
| **Estándares aplicados** | D1, D2 (Ortografía y versionado en Markdown) |
| **Responsable** | Luis Adolfo Martínez Hernández |

## Entrada 3

| Campo | Detalle |
|---|---|
| **Fecha** | 19/08/2026 |
| **Herramienta** | Gemini |
| **Objetivo** | Definición de requerimientos funcionales (RF) y de datos (RD) del sistema. |
| **Prompt utilizado** | "Define los requerimientos funcionales (RF) y de datos (RD) para el control de inventario y ventas de Pavanamoon." |
| **Resultado obtenido** | Listado de 21 RF y 11 RD detallados. |
| **Validación del grupo** | Se filtraron requerimientos no aplicables a la Entrega 1 y se ajustaron a categorías por edad y recepción por furgón. |
| **Estándares aplicados** | D4 (Trazabilidad de requerimientos) |
| **Responsable** | Cristian Otoniel Pérez Ríos |

## Entrada 4

| Campo | Detalle |
|---|---|
| **Fecha** | 19/08/2026 |
| **Herramienta** | Gemini |
| **Objetivo** | Diseño del diagrama Entidad-Relación conceptual. |
| **Prompt utilizado** | "Diseña el modelo ER en notación Mermaid con 13 entidades, cardinalidades y atributos PK/FK para Pavanamoon." |
| **Resultado obtenido** | Código Mermaid con diagrama ER completo y especificación de entidades. |
| **Validación del grupo** | Se verificó la correcta resolución de las 2 relaciones N:M (Ingreso↔Variante, Pedido↔Variante) y las llaves primarias/foráneas. |
| **Estándares aplicados** | Requisitos 1 y 2 de la Sección 5 (≥8 entidades, relaciones N:M) |
| **Responsable** | José Alejandro Cabrera Gramajo |

## Entrada 5

| Campo | Detalle |
|---|---|
| **Fecha** | 19/08/2026 |
| **Herramienta** | Gemini |
| **Objetivo** | Estructura del repositorio y plantilla del certificado de calidad. |
| **Prompt utilizado** | "Estructura el archivo de certificación y la jerarquía de carpetas según la sección 6 y 7 del proyecto." |
| **Resultado obtenido** | Plantilla del certificado de calidad y mapa del repositorio. |
| **Validación del grupo** | Se confirmó el cumplimiento de la estructura de carpetas obligatoria (Sección 7). |
| **Estándares aplicados** | R1, R2 (Estructura de carpetas y README) |
| **Responsable** | Fernando Rafael Duarte Hernández |

## Entrada 6

| Campo | Detalle |
|---|---|
| **Fecha** | 20/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Auditoría del repositorio Git (tag desactualizado, PNG/PDF faltantes, autoría de commits, carpetas sql/web no rastreadas) y generación de correcciones: README, certificación firmada, bitácora consolidada y comandos de corrección. |
| **Prompt utilizado** | "Actúa como auditor de software... revisa el repositorio completo contra el PDF de la guía y entrega un reporte de cumplimiento con correcciones exactas." |
| **Resultado obtenido** | Reporte de auditoría con 7 hallazgos y versiones corregidas de los documentos y comandos Git de corrección. |
| **Validación del grupo** | El equipo revisó y aplicó las correcciones antes de mover el tag `entrega-1` al commit final. |
| **Estándares aplicados** | R1, R4, R5, D3, D4, S8 |
| **Responsable** | Luis Adolfo Martínez Hernández |

## Entrada 7

| Campo | Detalle |
|---|---|
| **Fecha** | 20/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Rediseño del módulo de recepción de mercadería (reemplazo de `PROVEEDOR`/`COMPRA` por `FURGON`/`INGRESO_MERCADERIA`/`DETALLE_INGRESO`), corrección de un bug de ID duplicado en el diagrama `.drawio`, corrección del atributo `tipo_suela` faltante en `PRODUCTO`, y sincronización completa entre la propuesta y el diagrama ER. |
| **Prompt utilizado** | "Ya corregí la propuesta y el diagrama ER, analízalos y decime qué queda pendiente; confirmo que ya no se necesita catálogo de proveedores." |
| **Resultado obtenido** | Diagrama `.drawio` validado (sin IDs duplicados ni referencias rotas), Sección 7 de la propuesta renumerada y sincronizada (13 entidades, `DETALLE_INGRESO`, bloque Mermaid corregido), nota de decisión de diseño documentando por qué se descartó `PROVEEDOR`. |
| **Validación del grupo** | Se confirmó explícitamente que Pavanamoon no requiere catálogo de proveedores, solo registro de furgón; se validó que el diagrama y el documento quedaran 100% consistentes entre sí. |
| **Estándares aplicados** | D3 (diagramas editable + PNG/PDF), D4 (trazabilidad), S1 (nomenclatura consistente), S8 (validación IA) |
| **Responsable** | José Alejandro Cabrera Gramajo |

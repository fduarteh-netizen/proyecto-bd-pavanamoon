# Bitácora de Agentes de IA — Pavanamoon

Registro obligatorio de uso de agentes de inteligencia artificial durante el desarrollo del proyecto (Sección 10 de la guía). Equipo: Fernando Rafael Duarte Hernández, Luis Adolfo Martínez Hernández, Cristian Otoniel Pérez Ríos, José Alejandro Cabrera Gramajo.

**Forma de trabajo con IA.** La IA no se usa como "una consulta y listo":
cada entrega se trabaja en varias consultas encadenadas, una por cada cosa que
se construye o corrige (pedir → revisar contra el repositorio y la guía →
ejecutar en MySQL real → corregir lo que falla → volver a probar). Cada
**entrada** es una sesión de trabajo y cada **consulta** (ej. 12.5) es un
prompt distinto dentro de esa sesión, con su propio resultado y validación.

### Índice

| Entrada | Fecha | Herramienta | Tema | Consultas |
|---|---|---|---|---|
| 1 | 17/08/2026 | Claude | Arranque de la Entrega 1: propuesta, RF/RD, ER, cronograma, estructura | 4 |
| 2 | 19/08/2026 | Gemini | Propuesta de negocio (B2C/B2B, suelas, furgones) | 1 |
| 3 | 19/08/2026 | Gemini | Requerimientos funcionales y de datos | 1 |
| 4 | 19/08/2026 | Gemini | Diagrama ER conceptual | 1 |
| 5 | 19/08/2026 | Gemini | Estructura del repositorio y certificado | 1 |
| 6 | 20/08/2026 | Claude | Auditoría del repositorio Git | 1 |
| 7 | 20/08/2026 | Claude | Rediseño de recepción por furgón | 1 |
| 8 | 30/08/2026 | Claude | Entrega 2: modelo relacional, 3FN, diccionario, DDL, web 30 % | 6 |
| 9 | 30/08/2026 | Claude | Incorporación del diagrama ER corregido | 1 |
| 10 | 31/08/2026 | Claude | Auditoría final de la Entrega 2 | 5 |
| 11 | 31/08/2026 | Claude | Retroalimentación del catedrático (Entrega 1) | 3 |
| 12 | 29/09/2026 | Claude | Entrega 3: DML, vistas, triggers, procedimientos, roles, web 70 %, pruebas | 10 |
| 13 | 01/10/2026 | Claude | Verificación de los 3 roles de MySQL y guion de presentación | 5 |
| 14 | 01/10/2026 | Claude | Regresión en el módulo de pedidos | 4 |
| 15 | 01/10/2026 | Claude | Charset de triggers/procedimientos y script de casos BD | 4 |
| 16 | 09/10/2026 | Claude | Reestructuración de esta bitácora | 3 |
| 17 | 17–20/10/2026 | Claude | Entrega 4, Lotes 1 a 5: módulos, cancelación, reportes, seguridad y concurrencia | 4 |
| 18 | 20/10/2026 | Asistente de IA (ver entrada) | Paquete de instalación de la base en Railway a partir del dump local | 1 |
| 19 | 20/10/2026 | Claude | Revisión del paquete de Railway, auditoría de la Entrega 4 y pruebas locales | 3 |
| 20 | 25–27/10/2026 | Claude | Sincronización de Railway, documentación, manuales, diagramas y revisión contra la guía | 5 |
| | | | **Total** | **64** |

---


## Entrada 1 — Arranque de la Entrega 1

| Campo | Detalle |
|---|---|
| **Fecha** | 17/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Generar la base de la Entrega 1 (propuesta, requerimientos, modelo ER, cronograma y estructura del repositorio). |
| **Consultas** | 5 (ver abajo) |
| **Responsable** | Fernando Rafael Duarte Hernández |

### Consulta 1.1 — Propuesta, RF/RD y matriz de trazabilidad

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Actúa como Arquitecto Senior de BD. Para el caso de negocio Pavanamoon redacta la propuesta inicial con requerimientos funcionales y de datos, y una matriz de trazabilidad requerimiento → entidad." |
| **Resultado obtenido** | Borrador de la propuesta con descripción del problema, solución, RF/RD agrupados por módulo y la matriz de trazabilidad. |
| **Validación del grupo** | Se revisó que los RF/RD reflejaran el negocio real de Pavanamoon (calzado de fútbol, ventas al detalle y por mayor); se confirmó MySQL como SGBD final. |
| **Estándares aplicados (post-IA)** | D4 (trazabilidad), Sección 5 de la guía |

### Consulta 1.2 — Diseño conceptual ER en notación Chen

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Con esos requerimientos diseña el modelo Entidad-Relación en notación Chen, con al menos 8 entidades y 2 relaciones N:M." |
| **Resultado obtenido** | Primera versión del modelo con entidades, cardinalidades y las 2 relaciones N:M, más una vista de apoyo en Mermaid. |
| **Validación del grupo** | Se verificó el mínimo de la guía (≥ 8 entidades, ≥ 2 N:M). Se dejó explícito que Mermaid no dibuja Chen nativamente (nota metodológica). |
| **Estándares aplicados (post-IA)** | Sección 5 (req. 1 y 2), D3 (transparencia sobre la herramienta de diagramación) |

### Consulta 1.3 — Cronograma y plantillas de documentos

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Genera el cronograma de 12 semanas y las plantillas del README, la bitácora de IA y la certificación de calidad." |
| **Resultado obtenido** | Cronograma tipo Gantt textual y plantillas de README, `BITACORA_IA.md` y certificación. |
| **Validación del grupo** | El equipo ajustó las fechas del cronograma a las entregas del curso. |
| **Estándares aplicados (post-IA)** | R2 (README), Sección 10 (bitácora) |

### Consulta 1.4 — Script de estructura y Git

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Haz un script bash que cree la estructura de carpetas de la Sección 7 y haga el primer commit." |
| **Resultado obtenido** | Script `setup_entrega1.sh` que creaba carpetas y hacía el commit inicial. |
| **Validación del grupo** | Se usó para el primer commit. Más adelante (Entrada 11) se detectó que generaba carpetas con nombres incorrectos y se eliminó. |
| **Estándares aplicados (post-IA)** | R1 (estructura de carpetas) |

---

## Entrada 2 — Propuesta de negocio

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

---

## Entrada 3 — Requerimientos funcionales y de datos

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

---

## Entrada 4 — Diagrama ER conceptual

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

---

## Entrada 5 — Estructura del repositorio y certificado

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

---

## Entrada 6 — Auditoría del repositorio Git

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

---

## Entrada 7 — Rediseño de recepción por furgón

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

---

## Entrada 8 — Entrega 2: diseño lógico, DDL y web 30 %

| Campo | Detalle |
|---|---|
| **Fecha** | 30/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Construir la Entrega 2: modelo relacional, normalización 3FN, diccionario de datos, DDL ejecutable, datos semilla y la app web (login + CRUD de Producto y Cliente) en Node.js/Express/EJS. |
| **Consultas** | 6 (ver abajo) |
| **Responsable** | Fernando Rafael Duarte Hernández |

### Consulta 8.1 — ¿Cuál es el modelo vigente?

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Continuemos con la Entrega 2 según la guía adjunta. Antes de empezar, revisa el repositorio." |
| **Resultado obtenido** | El agente detectó que `ENTREGA1_PROPUESTA.md` (con PROVEEDOR/COMPRA) no coincidía con el diagrama `Pavanamoon_er_chen.drawio` (con FURGON/INGRESO_MERCADERIA/TIPO_CLIENTE/PRESENTACION_VENTA) y **preguntó al equipo cuál era el vigente** antes de seguir. |
| **Validación del grupo** | El equipo respondió que el diagrama es la fuente de verdad (decisión ya tomada en la Entrada 7). |
| **Estándares aplicados (post-IA)** | D4 (trazabilidad), S8 (no avanzar sobre un supuesto sin confirmar) |

### Consulta 8.2 — Modelo relacional y normalización 3FN

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "El diagrama es el correcto. Pásalo a modelo relacional y demuestra la normalización hasta 3FN con ejemplos de nuestro propio caso." |
| **Resultado obtenido** | El agente extrajo la estructura del `.drawio` de forma programática (sin transcribir a mano) y aplicó las reglas ER → relacional: 19 tablas (15 entidades + 2 asociativas N:M + 2 tablas de teléfonos por 1FN). Demostración 1FN/2FN/3FN con ejemplos de Pavanamoon. |
| **Validación del grupo** | Se revisó que cada relación N:M quedara resuelta (`detalle_ingreso`, `detalle_pedido`) y que los ejemplos de normalización fueran del negocio real. |
| **Estándares aplicados (post-IA)** | S7 (sin redundancia), D4 |

### Consulta 8.3 — Diccionario de datos

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Genera el diccionario de datos de todas las tablas: tipo, nulidad, llaves, restricciones y descripción." |
| **Resultado obtenido** | Diccionario de las 19 tablas en `ENTREGA2_DISENO_LOGICO.md` (Sección 4). |
| **Validación del grupo** | Se cotejó tabla por tabla contra el DDL para que los tipos y restricciones coincidieran. |
| **Estándares aplicados (post-IA)** | S1 (snake_case), D4 |

### Consulta 8.4 — Scripts DDL y datos semilla

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Escribe los scripts DDL separados por tipo de tabla y un seed mínimo con roles y un usuario administrador." |
| **Resultado obtenido** | 5 scripts en `sql/ddl/` y `sql/dml/00_seed_minimo.sql`. Se agregaron 2 columnas que el diagrama no tenía (`cliente.nombre_cliente`, `pedido.estado`), documentadas como adición justificada. |
| **Validación del grupo** | Los 5 scripts y el seed se ejecutaron desde cero sin errores en una instancia MySQL/MariaDB real. |
| **Estándares aplicados (post-IA)** | S1, S2 (un script, un propósito), S3 (encabezados), S4 (ON DELETE/ON UPDATE en cada FK), S7 (subtotal como columna generada) |

### Consulta 8.5 — App web: login y CRUD

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Con Node.js + Express + EJS haz el login contra la tabla usuario y los CRUD de Producto y Cliente, con capas separadas y consultas parametrizadas." |
| **Resultado obtenido** | Carpeta `web/` con servidor Express, modelos con consultas parametrizadas, middleware de autenticación y errores, validación de entrada, vistas EJS y CSS propio. |
| **Validación del grupo** | Login y ambos CRUD probados de extremo a extremo contra la BD real, incluido un NIT duplicado sin que se caiga el servidor. |
| **Estándares aplicados (post-IA)** | A1–A5 (capas, errores, validación, consultas parametrizadas, legibilidad) |

### Consulta 8.6 — Pruebas de integridad

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Prueba las restricciones contra la base real y documenta los casos con su resultado." |
| **Resultado obtenido** | 10 pruebas de restricciones (NIT duplicado, precio negativo, FK inexistente, stock negativo, SKU duplicado, combinación duplicada, borrado restringido, columna generada), 10/10 exitosas, en `docs/casos-prueba/CASOS_PRUEBA.md`. |
| **Validación del grupo** | Pendiente en ese momento: decidir si las 2 columnas agregadas se pasaban también al `.drawio` (se resolvió en la Entrada 9). |
| **Estándares aplicados (post-IA)** | S8 (validación real, no solo sintáctica) |

---

## Entrada 9 — Incorporación del diagrama ER corregido

| Campo | Detalle |
|---|---|
| **Fecha** | 30/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Incorporar `Pavanamoon_er_chen_corregido.drawio` (versión del diagrama corregida por el equipo tras la Entrada 8) y ajustar el DDL/diccionario de datos de la Entrega 2 para que coincidan exactamente con las correcciones aplicadas. |
| **Prompt utilizado** | El equipo subió el archivo `Pavanamoon_er_chen_corregido.drawio` sin instrucciones adicionales, esperando que el agente detectara y aplicara las diferencias relevantes. |
| **Resultado obtenido** | El agente extrajo de nuevo la estructura completa del `.drawio` corregido y la comparó atributo por atributo y cardinalidad por cardinalidad contra la versión anterior. Encontró 3 cambios con impacto real en el esquema: (1) `INGRESO_MERCADERIA.empleado_id` ya no está marcado como PK, confirmando la corrección aplicada en la Entrada 8; (2) la relación `FURGON`–`INGRESO_MERCADERIA` cambió de `(1,1)-(1,1)` a `(0,N)-(1,1)`, por lo que se quitó el `UNIQUE(furgon_id)` en `ingreso_mercaderia` (un furgón ahora puede tener varios ingresos); (3) `DETALLE_PEDIDO` ahora define una llave primaria compuesta explícita `(pedido_id, variante_id)`, por lo que se reemplazó la PK sustituta `detalle_pedido_id` que se había usado antes. También se detectaron 2 cambios sin impacto en el DDL (cardinalidad `ROL`–`USUARIO` corregida, y renombrado de relaciones duplicadas `corresponde_a` → `corresponde_a_ingreso`/`corresponde_a_pedido`). Se actualizaron `sql/ddl/05_tablas_transacciones.sql` y `docs/entrega-2/ENTREGA2_DISENO_LOGICO.md` (Secciones 1.2, 2, 3.2 y el diccionario de datos) para reflejar exactamente el diagrama corregido, y se volvió a validar la sintaxis de todo el DDL con un parser de MySQL. |
| **Validación del grupo** | Confirmado por el agente al ejecutar la base real: `ingreso_mercaderia` no tiene `UNIQUE(furgon_id)` (permite varios ingresos por furgón) y se insertó más de un ingreso para el mismo `furgon_id` sin error, confirmando que la relación 1:N funciona como se documentó. Se revisó el resto del `.drawio` corregido de forma programática (no solo los 3 puntos con impacto en DDL) y no se encontraron más discrepancias con la implementación. |
| **Estándares aplicados (post-IA)** | S4 (integridad referencial re-verificada tras el cambio de cardinalidad), S8 (comparación programática del diagrama en vez de revisión visual manual, para no pasar por alto diferencias pequeñas), D3 (el archivo `.drawio` corregido se incorporó a `docs/diagramas/`), D4 (trazabilidad: cada cambio de DDL queda ligado a la cardinalidad específica que lo originó) |
| **Responsable** | Luis Adolfo Martínez Hernández |

---

## Entrada 10 — Auditoría final de la Entrega 2

| Campo | Detalle |
|---|---|
| **Fecha** | 31/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Revisar la Entrega 2 contra la lista de requisitos del equipo y dejarla lista para GitHub. |
| **Consultas** | 5 (ver abajo) |
| **Responsable** | Cristian Otoniel Pérez Ríos |

### Consulta 10.1 — Estructura y credenciales

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Revisa que la raíz tenga README, INSTALL, .gitignore y .env.example, que no se suba ningún .env real ni node_modules, y que existan todas las carpetas de docs/ y sql/." |
| **Resultado obtenido** | Se encontró `web/.env` con credenciales reales en el paquete y se eliminó. Se crearon `.gitignore` y `.env.example` en la raíz. Se crearon `docs/entrega-1`, `docs/casos-prueba` y las 4 subcarpetas de `sql/` con un README. |
| **Validación del grupo** | El equipo confirmó que el `.env` no se subió a GitHub. |
| **Estándares aplicados (post-IA)** | R6 (sin credenciales en el repo), R1 (estructura) |

### Consulta 10.2 — Precio duplicado

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Unifica la lógica de precio entre PRODUCTO y PRESENTACION_VENTA; MAYORISTA debe ser tipo de cliente, no presentación." |
| **Resultado obtenido** | Se quitó `precio_venta` de `PRESENTACION_VENTA` en el `.drawio`, el DDL, el diccionario y el seed; las presentaciones quedaron como `unidad`/`caja` sin precio propio. |
| **Validación del grupo** | El equipo confirmó que el precio vive solo en `producto` y el descuento depende del tipo de cliente. |
| **Estándares aplicados (post-IA)** | S7 (un dato en un solo lugar) |

### Consulta 10.3 — Verificación de modelo y diagrama

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Verifica que usuarioModel.js use nombres_apellidos y que el .drawio no tenga elementos huérfanos." |
| **Resultado obtenido** | `usuarioModel.js` ya estaba correcto; se limpió un detalle en `authRoutes.js`. El `.drawio` no tenía huérfanos y la relación `registra` ya conectaba EMPLEADO–INGRESO_MERCADERIA. |
| **Validación del grupo** | Sin cambios necesarios en el diagrama. |
| **Estándares aplicados (post-IA)** | D3, S8 |

### Consulta 10.4 — Ejecución real y evidencias

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "No me basta con validar sintaxis: ejecútalo de verdad y guarda evidencia." |
| **Resultado obtenido** | Se instaló MariaDB, se ejecutaron DDL + seed desde cero, 10 pruebas de restricciones (10/10) y 7 pruebas de la app (login, CRUD, NIT duplicado, guard de autenticación, logout), con capturas en `docs/casos-prueba/evidencias/`. |
| **Validación del grupo** | Pendiente: que el equipo revise las capturas y, si quiere, las reemplace por propias. |
| **Estándares aplicados (post-IA)** | S8 |

### Consulta 10.5 — Exportes de diagramas

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Regenera el PNG y el PDF de ambos diagramas para que coincidan con la implementación." |
| **Resultado obtenido** | PNG y PDF del ER Chen (desde el `.drawio`) y del modelo relacional (desde el DDL real). Quedó documentado el ajuste manual pendiente en el `.mwb`. |
| **Validación del grupo** | El equipo aplicó el ajuste del `.mwb` en MySQL Workbench (confirmado en la Entrada 11). |
| **Estándares aplicados (post-IA)** | D3 (diagramas en los 3 formatos) |

---

## Entrada 11 — Retroalimentación del catedrático (Entrega 1)

| Campo | Detalle |
|---|---|
| **Fecha** | 31/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Corregir los puntos del comentario del catedrático (Ivan Antonio De León Fuentes) sobre el "Intento 1" de la Entrega 1. |
| **Consultas** | 3 (ver abajo) |
| **Responsable** | José Alejandro Cabrera Gramajo |

### Consulta 11.1 — Rutas rotas y archivos obsoletos

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: (se compartieron dos capturas con el comentario del catedrático) "Aplica los cambios que señala el ingeniero." |
| **Resultado obtenido** | `docs/entrega-2/` no existía en el repo aunque el README la enlazaba; se restauró. Se eliminaron `setup_entrega1.sh` (generaba carpetas mal nombradas) y el diagrama viejo `pavanamoon_ER_chen.drawio` (con COMPRA/DETALLE_COMPRA); se actualizó `GUIA_IMPORTAR_DRAWIO.md`. |
| **Validación del grupo** | Se verificó que todos los enlaces del README apuntan a archivos existentes. |
| **Estándares aplicados (post-IA)** | R1, R2 |

### Consulta 11.2 — Texto de la propuesta vs. diagrama

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "El ingeniero dice que TIPO_CLIENTE y PRESENTACION_VENTA no están en el modelo escrito. Sincroniza la propuesta con el diagrama." |
| **Resultado obtenido** | Sección 7 de `ENTREGA1_PROPUESTA.md` resincronizada: 13 → 15 entidades, cardinalidad `transporta` corregida a (0,N), atributos alineados al DDL, Mermaid y matriz actualizados, con una nota fechada sobre la corrección posterior a la calificación. |
| **Validación del grupo** | Pendiente que todos confirmen que la Sección 7 refleja decisiones acordadas. |
| **Estándares aplicados (post-IA)** | D4, S8 (la corrección queda fechada, no se oculta) |

### Consulta 11.3 — Tag y participación en commits

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "¿Cómo corregimos el tag desactualizado y la participación desigual en los commits?" |
| **Resultado obtenido** | No se puede corregir desde un ZIP; el agente explicó el procedimiento: mover o recrear el tag `entrega-1` y hacer commits reales y distribuidos. |
| **Validación del grupo** | Pendiente en Git real por parte del equipo. |
| **Estándares aplicados (post-IA)** | R4 (participación visible) |

---

## Entrada 12 — Entrega 3: implementación avanzada

| Campo | Detalle |
|---|---|
| **Fecha** | 29/09/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Completar la Entrega 3: DML, vistas, triggers, procedimientos, 3 roles en MySQL, 8 casos de prueba con trazabilidad y web ≈70 % con control por rol. |
| **Consultas** | 10 (ver abajo) |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

### Consulta 12.1 — Auditoría del repositorio

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Revisa el repositorio contra la guía de la Entrega 3 (productos y tabla de ponderación) y dime qué falta." |
| **Resultado obtenido** | Carpetas `sql/views`, `triggers`, `procedures` y `security` vacías. Se encontró un conflicto de merge sin resolver en esta bitácora (marcadores `<<<<<<<`/`>>>>>>>` alrededor de la Entrada 11); se resolvió conservando la Entrada 11. |
| **Validación del grupo** | El equipo confirmó la lista de pendientes antes de empezar a generar. |
| **Estándares aplicados (post-IA)** | R1, D4 |

### Consulta 12.2 — Descuento por tipo de cliente

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "El mayorista debe tener descuento. ¿Dónde se guarda?" |
| **Resultado obtenido** | `tipo_cliente` no tenía la columna de descuento que su comentario prometía. Se agregó `porcentaje_descuento` con `sql/ddl/06_ajustes_entrega3.sql` (ALTER en script nuevo, para que el cambio sea trazable por entrega). |
| **Validación del grupo** | Se validó que el mayorista queda con 15 % y el individual con 0 %. |
| **Estándares aplicados (post-IA)** | S2, S7, D4 (RF13) |

### Consulta 12.3 — Datos de prueba (DML)

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Genera al menos 50 registros por tabla principal, que sean consistentes: el stock debe cuadrar con el kardex." |
| **Resultado obtenido** | Generador Python con semilla fija (`sql/dml/generador/gen_datos_prueba.py`) y `sql/dml/01_datos_prueba.sql`: 60 clientes, 55 productos, 165 variantes, 55 furgones, 60 ingresos, 60 pedidos, 291 movimientos, más los usuarios `bodega` y `ventas`. |
| **Validación del grupo** | Consulta de verificación stock = suma del kardex: 0 inconsistencias. |
| **Estándares aplicados (post-IA)** | Sección 5 req. 7, S7 |

### Consulta 12.4 — Vistas

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Haz las vistas que la app va a necesitar para no repetir JOINs: stock con alerta, resumen de pedidos, kardex legible e historial de ingresos." |
| **Resultado obtenido** | `vw_stock_variantes` (alerta calculada, RF03/RF04), `vw_pedidos_resumen` (RF14), `vw_kardex` (RF16/RF18), `vw_ingresos_detalle` (RF09). |
| **Validación del grupo** | Cada vista se consultó contra los datos de prueba y se usa en al menos un módulo web. |
| **Estándares aplicados (post-IA)** | S2, S3, S6 (regla de negocio en el encabezado), S7 |

### Consulta 12.5 — Triggers

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Necesito triggers para que el stock y el kardex se actualicen solos al recibir mercadería y al vender, y que no deje vender sin stock." |
| **Resultado obtenido** | `trg_detalle_ingreso_ai` (suma stock + kardex `entrada`), `trg_detalle_pedido_bi` (rechaza con SIGNAL 45000 si no hay stock o el pedido no está pendiente), `trg_detalle_pedido_ai` (descuenta stock, kardex `salida`, recalcula total). |
| **Validación del grupo** | CP3-01 (ingreso +20), CP3-03 (venta −12, total Q2,652) y CP3-04 (rechazo por stock) pasan. El DML se carga **antes** de los triggers para no mover dos veces el stock histórico. |
| **Estándares aplicados (post-IA)** | S6, S8 |

### Consulta 12.6 — Función y procedimientos

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "El vendedor no debe digitar precios. Haz una función que calcule el precio con el descuento y procedimientos para crear pedido, agregar línea y registrar devolución." |
| **Resultado obtenido** | `fn_calcular_precio_linea`, `sp_crear_pedido`, `sp_agregar_linea_pedido` y `sp_registrar_devolucion` (transaccional con `EXIT HANDLER` → ROLLBACK + RESIGNAL). |
| **Validación del grupo** | CP3-02 (Q260 × 12 × 0.85 = Q2,652.00, igual al cálculo manual) y CP3-05 (devolución inválida rechazada, válida suma +2) pasan. |
| **Estándares aplicados (post-IA)** | S6, S7 (precio en un solo lugar) |

### Consulta 12.7 — Seguridad: 3 roles en MySQL

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Crea los 3 roles de MySQL (administrador, bodeguero, vendedor) con mínimo privilegio, alineados con los roles de la app." |
| **Resultado obtenido** | `sql/security/01_roles_privilegios.sql`: roles y usuarios `pvm_admin`, `pvm_bodega`, `pvm_ventas`. El vendedor no tiene INSERT en `pedido`: solo vende por procedimiento. Nadie salvo admin ve la tabla `usuario`. |
| **Validación del grupo** | CP3-06 y CP3-07: cada usuario puede lo suyo y recibe `ERROR 1142` en lo demás. |
| **Estándares aplicados (post-IA)** | R6 (contraseñas placeholder), S2, S3 |

### Consulta 12.8 — Módulos web nuevos

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Lleva la app al 70 %: Inventario, Furgones, Ingresos, Pedidos y Kardex usando las vistas y procedimientos." |
| **Resultado obtenido** | 5 módulos nuevos. Ingresos y pedidos son transaccionales (todo o nada); los SIGNAL de la BD se muestran como mensaje de negocio en el formulario. |
| **Validación del grupo** | Probado en navegador con capturas `e3_01` a `e3_09`. |
| **Estándares aplicados (post-IA)** | A1–A6, transacciones |

### Consulta 12.9 — Control de acceso por rol en la web

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Cada rol solo debe ver sus módulos, y si escribe la URL a mano que le salga 403." |
| **Resultado obtenido** | Matriz única `web/src/config/permisos.js` que alimenta el menú, las tarjetas de inicio y `requireRole` en `auth.js`. El responsable de pedidos/ingresos se toma de la sesión, no del formulario. |
| **Validación del grupo** | CP3-08: matriz de rutas 200/403 por rol según lo esperado. |
| **Estándares aplicados (post-IA)** | RF21, A1 |

### Consulta 12.10 — Casos de prueba, trazabilidad y bug de acentos

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Instala todo desde cero en MySQL 8 real, corre los 8 casos y arma la matriz de trazabilidad." |
| **Resultado obtenido** | 8/8 casos exitosos y matriz requerimiento → implementación → prueba en `CASOS_PRUEBA_ENTREGA3.md`. Durante las pruebas los acentos salían corruptos ("SalcajÃ¡"); se corrigió con `SET NAMES utf8mb4` en los DML. Las evidencias se guardaron como `.txt` porque `.gitignore` excluye `*.log`. |
| **Validación del grupo** | Pendiente: que cada integrante pueda defender al menos un objeto de BD y firme la certificación. |
| **Estándares aplicados (post-IA)** | S8, D4 |

---

## Entrada 13 — Verificación de roles de MySQL y guion de presentación

| Campo | Detalle |
|---|---|
| **Fecha** | 01/10/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Confirmar si los usuarios/roles de seguridad de MySQL realmente existen y funcionan (criterio "Seguridad: 3 roles en BD" y "roles BD OK" de la revisión funcional) y preparar cómo presentarlos al catedrático. |
| **Prompt utilizado** | "Revisa el repositorio: hay que presentarle al ingeniero los niveles de seguridad/acceso, pero no sé si están creados esos usuarios o si me puedes ayudar a crearlos." |
| **Resultado obtenido** | Los 3 roles (`rol_administrador`, `rol_bodeguero`, `rol_vendedor`) y sus 3 usuarios (`pvm_admin`, `pvm_bodega`, `pvm_ventas`) ya estaban definidos en `sql/security/01_roles_privilegios.sql`; no hubo que crearlos de nuevo. Se confirmó ejecutándolos en MySQL 8.0.46 real. Se agregaron: `docs/casos-prueba/scripts/demo_seguridad_presentacion.sql` (matriz de privilegios tabla × rol legible, solo lectura), su salida en `evidencias/entrega3_demo_seguridad.txt`, y el guion `docs/entrega-3/PRESENTACION_SEGURIDAD.md`. Se reescribió `sql/security/README.md`, que seguía diciendo "se llenará en la Entrega 3" y mostraba nombres de usuario distintos a los reales. |
| **Validación del grupo** | Pendiente que el equipo: ensaye el guion en su máquina con Workbench y que cada integrante pueda explicar al menos un rol (qué puede, qué no y por qué). |
| **Estándares aplicados (post-IA)** | S2, S3 (script nuevo con encabezado, un propósito), S8 (verificación en MySQL real, no solo lectura del script), R6 (solo contraseñas placeholder), D4 (README y guion coherentes con el script real) |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

**Secuencia de consultas:**

1. **Revisión del repositorio.** Se clonó el repo y se leyó `sql/security/`, `INSTALL.md`, `web/src/config/permisos.js` y `web/src/middleware/auth.js`. Hallazgo: los roles existen en el script, pero el README de la carpeta estaba desactualizado.
2. **¿Funcionan de verdad?** Se instaló MySQL 8 y se ejecutó todo `INSTALL.md` desde cero; `mysql.user` mostró las 6 cuentas. Se corrió `entrega3_casos_seguridad.sh`: mismos resultados que la evidencia de la Entrada 12 (7 denegaciones `ERROR 1142` esperadas, `CALL` permitido al vendedor).
3. **¿Cómo se lo muestro al ingeniero?** `SHOW GRANTS` es difícil de leer en una presentación, así que se escribió una consulta que cruza `information_schema.TABLES` con `mysql.tables_priv` para mostrar una matriz tabla × rol. Primera versión: el paso 6 no imprimía nada cuando el resultado era vacío; se cambió a `COUNT(*)` para que muestre un 0 explícito.
4. **Guion paso a paso.** Se redactaron las consultas "permitido vs. denegado" para Workbench y se ejecutó cada una con `pvm_ventas` y `pvm_bodega` para confirmar que el resultado anotado en el guion es el real (incluido el `INSERT` directo a `pedido`, que el vendedor no puede hacer).
5. **Preguntas probables.** Se documentó por qué la app usa un usuario técnico (`pavanamoon_app`) en vez de los `pvm_*`, para que el equipo pueda responderlo.

---

## Entrada 14 — Regresión en el módulo de pedidos

| Campo | Detalle |
|---|---|
| **Fecha** | 01/10/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Corregir dos fallas del módulo de pedidos introducidas en el commit "Corregir módulo de pedidos y devoluciones" (30/09/2026), detectadas al volver a correr los casos de prueba web durante la Entrada 13. |
| **Prompt utilizado** | Derivada de la Entrada 13 (hallazgo durante la verificación; el agente reportó la falla y propuso la corrección). |
| **Resultado obtenido** | (1) `pedidoModel.crear()` llamaba a `CALL sp_agregar_variante_pedido(...)`, un procedimiento que no existe en la BD (el real es `sp_agregar_linea_pedido`): **crear un pedido desde la web devolvía HTTP 500**. Se corrigió el nombre. (2) `pedidoModel.listar()` dejó de recibir `clienteId`, así que el filtro "Historial por cliente (RF14)" de `/pedidos` no filtraba (mostraba 60 pedidos en vez de 4 para el cliente 50). Se restauró el parámetro con consulta parametrizada. (3) El commit había borrado la descripción del encabezado del archivo; se restauró (estándar S3). Los cambios visuales de `detalle.ejs` del commit original se conservaron. |
| **Validación del grupo** | Validado por el agente contra la app corriendo: CP3-08 (c) vuelve a pasar (pedido mayorista total Q2,652.00, stock −12), CP3-08 (d) muestra el mensaje de negocio "Stock insuficiente…", el filtro por cliente devuelve 4 pedidos, y completar pedido + devolución (inválida y válida) funcionan desde el detalle. Pendiente que Luis revise el cambio, ya que modifica su commit. |
| **Estándares aplicados (post-IA)** | A2 (errores comprensibles en vez de HTTP 500), A4 (consulta parametrizada en el filtro), S3 (encabezado restaurado), S8 (prueba de regresión antes de entregar), D4 (RF14 vuelve a cumplirse según la matriz de trazabilidad) |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

**Secuencia de consultas:**

1. Al correr `entrega3_casos_web.sh`, el caso (c) devolvió `POST /pedidos -> HTTP 500` y el stock no cambió. Se revisó el log del servidor: `ER_SP_DOES_NOT_EXIST: sp_agregar_variante_pedido`.
2. Se comparó con `git show 7b7f8dc` para ver qué había cambiado en ese commit. Además del nombre del procedimiento, `listar()` había perdido el parámetro `clienteId` que la ruta sigue enviando.
3. Para no asumir, se probó el filtro antes y después de corregir: sin corrección, `/pedidos?cliente=50` devolvía 60 pedidos; con corrección, 4 (igual que `SELECT COUNT(*) FROM pedido WHERE cliente_id = 50`).
4. Se volvió a correr toda la batería web y se probaron a mano completar pedido y devolución (50 pares → rechazo; 2 pares → stock +2 y kardex `devolucion_cliente`).

---

## Entrada 15 — Charset y script de casos BD

| Campo | Detalle |
|---|---|
| **Fecha** | 01/10/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Corregir dos problemas de reproducibilidad detectados en la Entrada 14: acentos corruptos en los mensajes de error de triggers/procedimientos y un comando de casos de prueba que no ejecutaba todos los casos. |
| **Prompt utilizado** | Derivada de la Entrada 14 (hallazgo durante la verificación). |
| **Resultado obtenido** | (1) En la web, el mensaje de devolución inválida salía como "invÃ¡lida". Causa: los scripts de vistas, triggers y procedimientos no fijaban el charset de la sesión, y MySQL guarda cada rutina con el charset del cliente que la creó (aquí `latin1`). Es el mismo bug que la Entrada 12 corrigió en los DML. Se agregó `SET NAMES utf8mb4;` a los 11 scripts de `sql/views`, `sql/triggers` y `sql/procedures`. (2) El comando documentado `mysql -t -u root -p < entrega3_casos_bd.sql` se detiene en CP3-04, que falla **a propósito**, así que CP3-05 y la verificación stock = kardex nunca se ejecutaban. Se agregó `--force` en `INSTALL.md` y en el encabezado del script. (3) Se reinstaló todo desde cero y se regeneraron las evidencias. |
| **Validación del grupo** | Validado por el agente: `information_schema.ROUTINES` muestra `utf8mb4` en las 4 rutinas; el mensaje sale "inválida" en la web; `entrega3_casos_bd.txt` ahora llega hasta el final (CP3-01 a CP3-05 + 0 inconsistencias). Las evidencias de seguridad y web regeneradas son idénticas a las de la Entrada 12, lo que confirma que los resultados son reproducibles. |
| **Estándares aplicados (post-IA)** | S8 (instalación desde cero repetida tras el cambio), A2 (mensajes de negocio legibles), D4 (INSTALL.md coincide con lo que realmente funciona) |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

**Secuencia de consultas:**

1. Se consultó `information_schema.ROUTINES.CHARACTER_SET_CLIENT` y `TRIGGERS`: todas en `latin1`. Se confirmó que los DML sí tenían `SET NAMES` y los demás scripts no.
2. Se agregó `SET NAMES utf8mb4` justo después de `USE pavanamoon;` en cada script y se reinstaló la base desde cero; las rutinas quedaron en `utf8mb4`.
3. Al regenerar la evidencia de casos BD, la salida se cortaba en CP3-04. Se comparó con la evidencia anterior (que sí llegaba al final, por lo que fue generada con `--force`) y se corrigió la documentación.
4. Última instalación limpia y ejecución completa: BD, seguridad y web.

---

## Entrada 16 — Reestructuración de esta bitácora

| Campo | Detalle |
|---|---|
| **Fecha** | 09/10/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Atender el comentario del catedrático: la bitácora debe mostrar varias consultas por tarea, no un solo prompt por entrega. |
| **Consultas** | 3 (ver abajo) |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

### Consulta 16.1 — Índice y forma de trabajo

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | "Necesito mejorar la bitácora: el ingeniero quiere que haya muchas más consultas y que no le pidamos a la IA una sola consulta y ya." (01/10/2026) |
| **Resultado obtenido** | Se agregó al inicio la explicación de la forma de trabajo iterativa y un índice. Las Entradas 13–15 se documentaron con su secuencia de consultas. |
| **Validación del grupo** | El equipo revisó que las entradas nuevas correspondieran a lo hecho en esa sesión. |
| **Estándares aplicados (post-IA)** | D4 |

### Consulta 16.2 — Una consulta por cada cosa hecha

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | "Arregla la bitácora: el inge no quiere que sea un solo prompt, sino varios para las diferentes cosas que hicimos." (09/10/2026) |
| **Resultado obtenido** | Las sesiones que abarcaban varios entregables (Entradas 1, 8, 10, 11 y 12) se dividieron en consultas numeradas (ej. 12.5 Triggers). Cada consulta tiene su propio prompt, resultado, validación y estándares, y se conservó el contenido técnico original. Las entradas de un solo propósito (2–7, 9, 13–15) no cambiaron. |
| **Validación del grupo** | El campo Responsable se completó el 27/10/2026: los cuatro integrantes son responsables de las sesiones. |
| **Estándares aplicados (post-IA)** | D4, S8 (transparencia del uso de IA) |

### Consulta 16.3 — Subir los cambios en commits separados

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Necesito subir los cambios de forma que se vea qué hice." |
| **Resultado obtenido** | Script que aplica las correcciones de las Entradas 13–15 y esta bitácora en 5 commits temáticos (fix web, fix SQL, fix pruebas, docs seguridad, docs bitácora) en lugar de un solo commit grande. |
| **Validación del grupo** | Ejecutado por el integrante responsable desde su propia cuenta de Git. |
| **Estándares aplicados (post-IA)** | R4 (participación visible), R5 (mensajes de commit descriptivos) |

---

## Entrada 17 — Entrega 4, Lotes 1 a 5

| Campo | Detalle |
|---|---|
| **Fecha** | 17/10/2026 a 20/10/2026 |
| **Herramienta** | Claude (Anthropic), IA principal del proyecto. Al inicio del proyecto se usó Gemini para redactar algunos prompts |
| **Objetivo de la sesión** | Implementar la Entrega 4: cancelación de pedidos, devolución acumulada, kardex ligado al pedido, reportes de ventas, módulos Empleados, Usuarios y Catálogos, endurecimiento de seguridad web y concurrencia. |
| **Consultas** | 4, una por entrega de código. El texto literal de los prompts no se conservó; abajo se resume lo pedido y lo obtenido a partir de los commits |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

Consultas, reconstruidas a partir de los commits (resumen de lo pedido y del resultado):

| Commit | Fecha | Contenido |
|---|---|---|
| `cb63d67` | 17/10/2026 | "integra lotes 1 y 2": `sql/ddl/07_ajustes_entrega4.sql`, `sp_cancelar_pedido`, devolución acumulada, vistas 05 y 06, privilegios E4, Empleados, Usuarios, Reportes, casos CP4-01 a CP4-15 |
| `5abeb76` | 19/10/2026 | Catálogos, variantes y teléfonos de clientes; CP4-16 a CP4-22 y unitarias |
| `ece0f84` | 19/10/2026 | Dependencias corregidas según `npm audit` |
| `246f4bc` | 20/10/2026 | Lote 5: `seguridad.js`, `FOR UPDATE`, pruebas SEG e INT, `instalar_bd_prueba.cjs` |

**Validación del grupo:** el equipo revisó cada lote antes de integrarlo en `main` (PR #2), y las baterías de estos lotes se ejecutaron desde cero en la Entrada 19 (resultados en `CASOS_PRUEBA_ENTREGA4.md`).

**Estándares aplicados (post-IA):** S2, S3, S6, S8, A1–A4.

---

## Entrada 18 — Paquete de instalación de la base en Railway

| Campo | Detalle |
|---|---|
| **Fecha** | 20/10/2026 |
| **Herramienta** | Asistente de IA en una conversación separada de las Entradas 19 y 20. En esa conversación el integrante pregunta si pasarle el archivo "a Claude", así que no fue esta misma sesión. No se registró con certeza qué herramienta era (la IA principal del proyecto fue Claude) |
| **Objetivo** | Instalar la estructura de la base en el servicio MySQL de Railway sin copiar datos ni contraseñas de la base local. |
| **Prompt utilizado** | Resumen: el integrante exportó la base local con `mysqldump --no-data --routines` (archivo `pavanamoon_estructura_railway.sql`) y pidió adaptarlo para la base `railway`. El texto literal no se conservó |
| **Resultado obtenido** | Paquete con `pavanamoon_railway_estructura_segura.sql` (sin `DEFINER=root@localhost`, dirigido a `railway`, sin `DROP`), `pavanamoon_railway_datos_demo.sql` (datos ficticios) e instrucciones. Se importó en Railway con Workbench → Data Import. |
| **Validación del grupo** | La importación terminó sin errores. **Problema detectado después (Entrada 19):** el dump provenía de una base local con objetos de versiones anteriores, así que Railway quedó distinta del repositorio (9 vistas, 2 funciones y 9 procedimientos frente a 6, 1 y 4). |
| **Estándares aplicados (post-IA)** | R6 (sin credenciales en el paquete) |
| **Responsable** | Fernando Duarte (solicitó el paquete); validación: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

**Lección:** una base de producción se instala desde los scripts
versionados de `sql/`, no desde un dump de una base de desarrollo.

---

## Entrada 19 — Revisión del paquete de Railway, auditoría y pruebas locales

| Campo | Detalle |
|---|---|
| **Fecha** | 20/10/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Revisar el paquete de la Entrada 18, auditar el estado real de la Entrega 4 y ejecutar las pruebas desde cero. |
| **Consultas** | 3 (ver abajo) |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

### Consulta 19.1 — ¿El paquete de Railway está bien?

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Se pegó la conversación de la Entrada 18 con la pregunta "¿puedes ver si está bien?". |
| **Resultado obtenido** | El agente importó el paquete en MySQL 8.0.46 con binlog activo (como Railway): 19 tablas, 9 vistas, 9 procedimientos, 2 funciones y 3 triggers, sin `DEFINER`, `DROP` ni datos reales. También hizo una prueba funcional (ingreso, pedido mayorista Q2,142.00, devolución, cancelación, stock final correcto). Concluyó que el paquete estaba bien y advirtió sobre las mayúsculas en nombres de tablas (Linux) y la zona horaria UTC. |
| **Validación del grupo** | **Error del agente:** validó que el paquete fuera coherente consigo mismo, pero no lo comparó con `sql/` del repositorio. Lo detectó y lo reconoció en la consulta 19.2. |
| **Estándares aplicados (post-IA)** | S8 (prueba en MySQL real); D4 incumplido en esta consulta (sin trazabilidad contra el repositorio) |

### Consulta 19.2 — Auditoría técnica de la Entrega 4

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Actúa como auditor técnico… revisa el estado real del proyecto y determina qué falta para entregarlo el 27 de octubre. Primero auditoría; no modifiques archivos ni despliegues. Completado / Pendiente / Bloqueante." |
| **Resultado obtenido** | Instalación desde cero sin errores y todas las baterías aprobadas. **Bloqueante:** la base de Railway no coincidía con el repositorio. `vw_pedidos_resumen` y `sp_crear_pedido` eran versiones antiguas y había 10 objetos ajenos (uno cancela sin devolver stock). La app de `main` conectada a una copia del esquema de Railway dio **HTTP 500** en el filtro por cliente (RF14) y 200 con el esquema del repositorio. **Otros pendientes:** documentación de la Entrega 4, diagrama sin `movimiento_stock.pedido_id`, README de `sql/` desactualizados, bitácora, certificación, etiqueta, zona horaria y el requisito de usuarios de `entrega4_seguridad.test.cjs`. |
| **Validación del grupo** | El equipo confirmó el defecto y decidió corregir Railway antes de documentar. |
| **Estándares aplicados (post-IA)** | S8, D4 (comparación objeto por objeto contra `sql/`), A2 |

### Consulta 19.3 — Pruebas locales, evidencias y scripts de sincronización

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Prepara los documentos de la Entrega 4 sobre `docs/entrega4-final`. Antes de modificar Railway, entrégame el script con la lista de objetos, el respaldo, el plan de recuperación, las consultas de verificación y las pruebas en una base aislada. No inventes evidencias ni firmas." |
| **Resultado obtenido** | (1) Ejecución desde cero de todas las baterías con salida sin editar en `docs/casos-prueba/evidencias/entrega4_*.txt`. Para SEG se crearon los usuarios `cabrito` y `fernanflo` desde `/usuarios`. Una primera evidencia de regresión salió con acentos corruptos (cliente `mysql` sin locale UTF-8) y se regeneró. (2) `railway_sincronizar_con_repo.sql`, `railway_verificar.sql` (solo lectura) y `railway_revertir_sincronizacion.sql`, probados sobre una copia del paquete de la Entrada 18: sincronización, repetición, reversión, interrupción a mitad, respaldo restaurado en otro servidor y sobre el mismo esquema, control negativo y app conectada. Dos anotaciones de la prueba estaban mal (el login rechazado responde 401, no 200; una ruta relativa) y se corrigieron, repitiendo toda la batería desde una base nueva. La sesión se agotó antes de entregar los documentos. |
| **Validación del grupo** | Pendiente: re-ejecución de las baterías por un integrante (sección 5 de `CASOS_PRUEBA_ENTREGA4.md`). |
| **Estándares aplicados (post-IA)** | S8, R6 (las evidencias no contienen contraseñas), D4 |

---

## Entrada 20 — Sincronización de Railway y documentación de la Entrega 4

| Campo | Detalle |
|---|---|
| **Fecha** | 25/10/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo de la sesión** | Corregir la base de Railway de forma segura y dejar la documentación esencial de la Entrega 4. |
| **Consultas** | 4 (ver abajo) |
| **Responsable** | Equipo completo: Fernando Duarte, Luis Martínez, Cristian Pérez y Alejandro Cabrera |

### Consulta 20.1 — Paquete de sincronización para ejecutar en producción

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Entrégame el SQL de sincronización completo y descargable, con los objetos que modifica, cómo respaldar y comprobar el respaldo, cómo importarlo desde Workbench, consultas de verificación y qué hacer si hay un error. No borres tablas ni datos. Si no puedes demostrar que es seguro, detente." |
| **Resultado obtenido** | El agente comprobó que `main` seguía en `28f1176` y que `sql/` no había cambiado desde las pruebas. Entregó el paquete con `GUIA_SINCRONIZACION_RAILWAY.md`: verificar (veredicto `ESTADO ANTERIOR`), respaldar con Data Export y comprobarlo en PowerShell, ejecutar con Data Import (mismo cliente `mysql` de las pruebas), volver a verificar, y planes A (reversión) y B (respaldo). Dejó explícito el límite: no se probó con Workbench en Windows ni con la versión exacta de MySQL de Railway. |
| **Validación del grupo** | Ejecutado en Railway por el equipo el 25/10/2026: `railway_verificar.sql` dio `IGUAL AL REPOSITORIO` (19 / 6 / 1 / 4 / 3), el filtro por cliente funciona sin HTTP 500, se cerró el acceso público de MySQL y se cambió la contraseña del administrador. _(Agregar las capturas a `docs/casos-prueba/evidencias/`.)_ |
| **Estándares aplicados (post-IA)** | S8 (verificación antes y después), R6 (rotación de la contraseña compartida), D4 |

### Consulta 20.2 — Documentación esencial de la Entrega 4

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Resumen: "Prepara los archivos reales: ENTREGA4_IMPLEMENTACION, CASOS_PRUEBA_ENTREGA4, README, bitácora, README de vistas, procedimientos y triggers, y la certificación con firmas pendientes. No hagas manuales ni diagramas. No inventes resultados, capturas ni firmas. Distingue lo local de Railway." |
| **Resultado obtenido** | Archivos completos para la rama `docs/entrega4-final`: `ENTREGA4_IMPLEMENTACION.md`, `CASOS_PRUEBA_ENTREGA4.md` (matriz de trazabilidad, tabla RW-01 a RW-08 vacía y tabla de re-ejecución), `README.md`, los tres README de `sql/`, las Entradas 17 a 20 de esta bitácora, `CERTIFICACION_ENTREGA_4.md` (casillas sin marcar), las evidencias de la Entrada 19 y `docs/entrega-4/despliegue-railway/`. No modificó código, SQL de `sql/` ni Railway. |
| **Validación del grupo** | El equipo revisó los archivos, los subió a `main` el 27/10/2026 y completó los campos pendientes de la bitácora. |
| **Estándares aplicados (post-IA)** | D4, R4 (commits hechos por los integrantes desde su cuenta) |

### Consulta 20.3 — Informe final, declaración de integridad y guía de defensa

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Se compartió la tabla de ponderación de la Entrega 4 y se preguntó qué faltaba. Luego: "¿me puedes entregar todo lo faltante para concluir hoy?". |
| **Resultado obtenido** | El agente cruzó la rúbrica con el estado real y encontró dos productos que no estaban en su lista (informe final y declaración de integridad) y un riesgo en "CRUD en todas las tablas principales": ingresos y pedidos no se editan ni se borran por diseño (auditoría del kardex). Entregó `ENTREGA4_INFORME_FINAL.md` (con la justificación del CRUD), `ENTREGA4_DECLARACION_INTEGRIDAD.md` (sin firmas) y `ENTREGA4_GUIA_DEFENSA.md`. Corrigió una afirmación de su propio borrador: la app no tiene pantalla de movimientos de `ajuste`. |
| **Validación del grupo** | Pendiente: revisión del informe y firmas de la declaración. |
| **Estándares aplicados (post-IA)** | D4 |

### Consulta 20.4 — Manuales técnico y de usuario y diagramas actualizados

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | "Hazlo desde 0 (manuales y diagramas) para poder subirlo todo de una vez hoy." |
| **Resultado obtenido** | (1) **Manual de usuario** con 26 capturas reales, tomadas con un navegador automatizado recorriendo cada flujo en la app instalada desde cero. Las primeras capturas salieron con la fecha 28/10/2026 por el reloj del entorno; se repitieron con MySQL a la fecha real (25/10/2026). (2) **Manual técnico:** arquitectura, variables, flujo de datos, CRUD y su justificación, despliegue, pruebas, mantenimiento y solución de problemas. Antes de redactarlo se verificaron en el código los mensajes y las reglas citadas, y se corrigió una afirmación sobre el borrado de productos. (3) **Diagrama ER:** se agregaron la relación "origina" PEDIDO (0,N) — MOVIMIENTO_STOCK (0,1) y el atributo `porcentaje_descuento` de TIPO_CLIENTE, y se exportaron el PNG y el PDF con el visor de draw.io. (4) **Modelo relacional (.mwb):** se agregaron `pedido_id`, `fk_movimiento_pedido` con su índice, `cancelacion` en el ENUM y `tipo_cliente.porcentaje_descuento`. Esta última faltaba desde la Entrega 3 y se detectó comparando el modelo con la base real tabla por tabla: 19 de 19 tablas iguales y 21 de 21 FK, con 0 referencias internas rotas. |
| **Validación del grupo** | El 27/10/2026 se subió todo a `main` con la etiqueta `entrega-4`. Después, el agente generó el PNG y el PDF del modelo relacional a partir de los datos del `.mwb`: las mismas posiciones y el estilo de Workbench, 19 tablas, 21 FK, y en el PDF se verificó que aparecen `pedido_id` y `porcentaje_descuento`. No son una exportación de Workbench. Pendiente opcional: abrir el `.mwb` en Workbench para confirmar que abre. |
| **Estándares aplicados (post-IA)** | S8 (flujos ejecutados, no descritos de memoria), D4 (modelo comparado con la base real) |

### Consulta 20.5 — Revisión contra la guía del proyecto (secciones 5, 6.1, 6.3, 7, 8 y D2)

| Campo | Detalle |
|---|---|
| **Prompt utilizado** | Se compartió el PDF *Proyecto – Base de datos* con la pregunta: "aquí puedes encontrar la sección 6.3… entrégame lo que puedes hacer para subirlo de una vez". |
| **Resultado obtenido** | El agente revisó la guía contra el código y el repositorio. **A1, A2, A4 y A5** se cumplían, con evidencia citada. **A6** no: 50 de las 78 funciones de `web/src/models/` no tenían comentario. Se agregaron 50 comentarios de una línea, se verificó que fueran el **único** cambio en el código (0 líneas distintas a comentarios) y se repitieron las pruebas (unitarias 10/10, web 46/46, catálogos 65/65). **D2:** los 5 documentos nuevos se renombraron con el prefijo `ENTREGA4_` y se actualizaron sus enlaces. **Sección 8:** a la certificación le faltaba la casilla de estándares de repositorio (6.1) y se agregó. **Repositorio final:** la evidencia de la Entrega 2 (`pruebas_restricciones_sql.log`) nunca se subió porque `.gitignore` excluye `*.log`. No se reconstruyó el registro original: se escribió `scripts/entrega2_restricciones.sql` con los mismos 10 casos y se re-ejecutó, marcado como re-ejecución del 27/10/2026. La primera versión del script falló en CP-10 por un error del agente (subconsulta sobre la tabla que modifica el trigger, error 1442); se corrigió y el resultado fue 10/10. **Sección 13:** se informó al equipo que la fecha de la Entrega 4 y la defensa es el 03/11/2026. Todo quedó documentado en `ENTREGA4_IMPLEMENTACION.md`, sección 9. |
| **Validación del grupo** | Pendiente: revisión del equipo antes del commit. |
| **Estándares aplicados (post-IA)** | A1–A6, R1–R8, D2, D4 |


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

## Entrada 8

| Campo | Detalle |
|---|---|
| **Fecha** | 30/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Construir la Entrega 2 completa: modelo relacional, normalización 1FN/2FN/3FN con ejemplos propios, diccionario de datos, scripts DDL ejecutables, datos semilla, y la aplicación web (login + CRUD de Producto y Cliente) en Node.js/Express/EJS. |
| **Prompt utilizado** | Resumen: "Continuemos con la Entrega 2 del proyecto Pavanamoon: modelo relacional, 3FN, diccionario de datos, scripts DDL y la app web (login + 2 CRUD) según la guía adjunta." Stack elegido por el equipo: Node.js + Express + EJS. |
| **Resultado obtenido** | Al revisar el repositorio contra la guía, el agente detectó que `docs/entrega-1/ENTREGA1_PROPUESTA.md` (modelo con PROVEEDOR/COMPRA) no coincidía con el diagrama ER vigente (`Pavanamoon_er_chen.drawio`, modelo con FURGON/INGRESO_MERCADERIA/TIPO_CLIENTE/PRESENTACION_VENTA, confirmado como el diseño final en la Entrada 7 de esta misma bitácora). Se le preguntó explícitamente al equipo cuál modelo era el vigente antes de continuar. El equipo confirmó que el diagrama es la fuente de verdad. Con esa confirmación, el agente extrajo programáticamente la estructura exacta del `.drawio` (entidades, atributos, cardinalidades) para evitar transcribir el modelo a mano, generó los 5 scripts DDL (`sql/ddl/`), el script de datos semilla (`sql/dml/00_seed_minimo.sql`), el documento de diseño lógico con diccionario de datos y demostración de 3FN (`docs/entrega-2/ENTREGA2_DISENO_LOGICO.md`, incluyendo una sección que documenta la inconsistencia detectada y las 2 correcciones/2 adiciones aplicadas sobre el diagrama), y la aplicación web completa (`web/`: servidor Express, modelos con consultas parametrizadas, middlewares de autenticación/errores, validación de entrada, vistas EJS y CSS propio). |
| **Validación del grupo** | Validado por el agente contra una instancia MySQL/MariaDB real (no solo sintaxis): los 5 scripts DDL y el seed se ejecutaron desde cero sin errores; se corrieron 10 pruebas de restricciones de integridad (NIT duplicado, precio negativo, FK inexistente, stock negativo, SKU duplicado, combinación duplicada, borrado restringido, columna generada) con 10/10 exitosas; se probó el login y ambos CRUD (Producto y Cliente) de extremo a extremo contra la base real, incluyendo la creación de registros reales y el manejo de un NIT duplicado sin caída del servidor. Evidencia completa en `docs/casos-prueba/CASOS_PRUEBA.md`. Las 2 adiciones (`cliente.nombre_cliente`, `pedido.estado`) se mantienen: son necesarias para que la aplicación web funcione (sin nombre no se puede listar clientes; sin estado no se puede distinguir un pedido cancelado) y así quedó confirmado al construir y probar el CRUD real. Pendiente: que el equipo revise si desea agregarlas también al `.drawio` para que el diagrama quede 100% completo (hoy quedan documentadas como adición justificada, no como parte del diagrama). |
| **Estándares aplicados (post-IA)** | S1 (nomenclatura snake_case), S2 (un script un propósito), S3 (encabezado en cada script), S4 (ON DELETE/ON UPDATE documentado en cada FK), S7 (subtotal como columna generada, sin redundancia), S8 (validación de SQL generado por IA con parser antes del commit), A1-A5 (separación de capas, manejo de errores, validación de entrada, consultas parametrizadas, código legible en la app web), D4 (trazabilidad y documentación explícita de la inconsistencia Entrega 1 vs. diagrama) |
| **Responsable** | Fernando Rafael Duarte Hernández |

## Entrada 9

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

## Entrada 10

| Campo | Detalle |
|---|---|
| **Fecha** | 31/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Auditoría final de la Entrega 2 contra una lista detallada de requisitos del equipo: estructura de carpetas completa, ausencia de credenciales, consistencia de precio entre `PRODUCTO` y `PRESENTACION_VENTA`, exports PNG/PDF de ambos diagramas, cierre de pendientes en bitácora/certificación, y evidencia real de ejecución (no solo validación sintáctica) para dejar el proyecto listo para subir a GitHub. |
| **Prompt utilizado** | El equipo entregó una lista extensa de requisitos de estructura y consistencia (resumen): raíz con README/INSTALL/.gitignore/.env.example sin `.env` real ni `node_modules`; carpetas `docs/entrega-1`, `entrega-2`, `diagramas`, `certificaciones`, `bitacora-ia`, `casos-prueba`; `sql/views`, `triggers`, `procedures`, `security` presentes aunque vacíos; verificar que `usuarioModel.js` use `nombres_apellidos`; unificar la lógica de precio entre `PRODUCTO` y `PRESENTACION_VENTA`; `MAYORISTA` como `tipo_cliente` y no como presentación; eliminar elementos huérfanos del `.drawio`; y que todos los documentos digan lo mismo. |
| **Resultado obtenido** | Auditoría completa contra la lista: (1) `web/.env` con credenciales reales estaba incluido en el paquete recibido — se eliminó; se crearon `.gitignore` y `.env.example` en la raíz (no existían). (2) Faltaban `docs/entrega-1`, `docs/casos-prueba` y las 4 subcarpetas de `sql/`; se crearon, las de `sql/` con un `README.md` explicando su contenido futuro (Entrega 3). (3) Se confirmó que `usuarioModel.js` **ya** usaba `e.nombres_apellidos AS nombres` correctamente (no tenía el bug descrito); se limpió un detalle cosmético en `authRoutes.js` (concatenación con `apellidos` vacío). (4) Se encontró y corrigió la duplicación de precio: se quitó `precio_venta` de `PRESENTACION_VENTA` en el `.drawio`, el DDL, el diccionario y el seed; las presentaciones pasaron a ser `unidad`/`caja` sin precio propio. (5) Se verificó el `.drawio` programáticamente: no tiene elementos huérfanos y la relación `registra` ya conecta directamente `EMPLEADO`–`INGRESO_MERCADERIA` (ambos puntos ya estaban correctos desde la Entrada 9). (6) Se instaló MariaDB en el entorno de trabajo y se ejecutaron los 5 scripts DDL + el seed **desde cero contra una base real**, sin errores; se corrieron 10 pruebas de restricciones de integridad (10/10 exitosas) y 7 pruebas end-to-end de la app web real (login, CRUD real de Producto y Cliente contra MySQL, manejo de NIT duplicado, guard de autenticación, logout), con capturas de pantalla reales tomadas con `wkhtmltoimage`. Todo quedó documentado en `docs/casos-prueba/CASOS_PRUEBA.md` y `docs/casos-prueba/evidencias/`. (7) Se regeneraron el PNG y el PDF del diagrama ER Chen (desde el `.drawio`) y del modelo relacional (desde el DDL real, por ser más confiable que editar el `.mwb` binario) para que ambos formatos coincidan exactamente con la implementación; se dejó documentado el único ajuste manual pendiente en el `.mwb` (eliminar la columna de precio duplicada en MySQL Workbench). (8) Se cerraron los placeholders "completar por el equipo" de las Entradas 8 y 9 con los resultados reales obtenidos en esta sesión. |
| **Validación del grupo** | Pendiente que el equipo: confirme los nombres/carnés en la certificación firmada; revise las capturas de `docs/casos-prueba/evidencias/` y, si lo desea, las reemplace por capturas propias tomadas desde su navegador; y aplique el ajuste manual pendiente en el `.mwb` (Sección 1.3 de `ENTREGA2_DISENO_LOGICO.md`). |
| **Estándares aplicados (post-IA)** | R6 (credenciales reales detectadas y eliminadas antes de subir a GitHub), S7 (eliminación de la redundancia de precio entre dos tablas), S8 (validación real contra MySQL, no solo sintáctica, antes de certificar la entrega), D3/D4 (diagramas exportados en los 3 formatos exigidos y sincronizados con la implementación; trazabilidad completa de cada corrección) |
| **Responsable** | Cristian Otoniel Pérez Ríos |
<<<<<<< HEAD

## Entrada 11

| Campo | Detalle |
|---|---|
| **Fecha** | 31/08/2026 |
| **Herramienta** | Claude (Anthropic) |
| **Objetivo** | Corregir la retroalimentación real del catedrático (Ivan Antonio De León Fuentes) sobre el "Intento 1" de la Entrega 1: tag desactualizado, carpetas mal nombradas, faltantes `sql/`, `web/`, `docs/entrega-2..4/` y `docs/casos-prueba/`, diagrama con `TIPO_CLIENTE`/`PRESENTACION_VENTA` ausentes del modelo escrito, README con rutas rotas, y participación desigual en los commits. |
| **Prompt utilizado** | El equipo compartió dos capturas de pantalla con el comentario textual del catedrático sobre la Fase 1 del proyecto, pidiendo aplicar los cambios señalados. |
| **Resultado obtenido** | Se descargó y auditó el estado real del repositorio (rama `main`) contra cada punto del comentario: (1) Se confirmó que `docs/entrega-2/` no existía en el repo aunque el README ya la enlazaba (causa directa de "README enlaza rutas que no existen"); se restauró con `ENTREGA2_DISENO_LOGICO.md` y `AVANCE_WEB.md`. (2) Se encontraron y eliminaron dos archivos obsoletos que el catedrático no mencionó explícitamente pero que perpetuaban el problema: `setup_entrega1.sh` (script que originalmente generó las carpetas mal nombradas `docs/bitacora/`/`docs/certificacion/`) y `docs/diagramas/pavanamoon_ER_chen.drawio` (diagrama viejo de 13 entidades sin `TIPO_CLIENTE`/`PRESENTACION_VENTA`, con `COMPRA`/`DETALLE_COMPRA`); se actualizó `GUIA_IMPORTAR_DRAWIO.md` para referenciar solo el diagrama vigente. (3) Se confirmó que el equipo ya había corregido el `.mwb` de MySQL Workbench por su cuenta (el PNG re-exportado ya no muestra `precio_venta` en `presentacion_venta`) — no fue necesario tocarlo. (4) Se resincronizó por completo la Sección 7 de `ENTREGA1_PROPUESTA.md` (entidades 13→15, agregando `TIPO_CLIENTE` y `PRESENTACION_VENTA`; cardinalidad `transporta` corregida de (1,1) a (0,N); atributos de `CLIENTE`/`EMPLEADO` alineados al DDL real; diagrama Mermaid y matriz de trazabilidad actualizados) para que el texto, el diagrama y el DDL digan exactamente lo mismo, dejando una nota fechada y transparente sobre la corrección posterior a la calificación (no se reescribió la historia silenciosamente). (5) Los puntos de tag desactualizado y participación desigual de commits **no se pueden corregir desde un ZIP** (requieren acceso real a `git`/GitHub); se le explicó al equipo el procedimiento exacto a seguir (mover o recrear el tag `entrega-1`, y generar commits reales y distribuidos, especialmente para el integrante con un solo commit tipo "Add files via upload"). |
| **Validación del grupo** | Pendiente que el equipo: mueva o recree el tag `entrega-1` apuntando a un commit reciente; genere commits reales y sustantivos para el integrante señalado por el catedrático; y confirme que la Sección 7 actualizada de `ENTREGA1_PROPUESTA.md` sigue reflejando decisiones con las que todos están de acuerdo (especialmente el uso de `TIPO_CLIENTE` y `PRESENTACION_VENTA`). |
| **Estándares aplicados (post-IA)** | R1 (estructura de carpetas obligatoria, ahora completa), R4 (participación visible — diagnóstico entregado, corrección pendiente en Git real), D4 (trazabilidad: texto, diagrama y DDL sincronizados), S8 (transparencia: la corrección posterior a la calificación queda fechada y documentada, no oculta) |
| **Responsable** | José Alejandro Cabrera Gramajo |
=======
>>>>>>> 7399d866bb8fa8177cff65f7e16ca968569ddf08

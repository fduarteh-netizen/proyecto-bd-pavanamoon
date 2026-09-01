# Certificación de Calidad — Entrega 2
## Proyecto Pavanamoon — Sistema de Gestión de Inventario y Distribución de Calzado

Nosotros, los integrantes del equipo abajo firmantes, certificamos que la Entrega 2
cumple con lo siguiente:

- [x] Cumplimos la estructura de carpetas obligatoria (Sección 7 de la guía):
      `docs/entrega-1`, `docs/entrega-2`, `docs/diagramas`, `docs/certificaciones`,
      `docs/bitacora-ia`, `docs/casos-prueba`, `sql/ddl`, `sql/dml`, `sql/views`,
      `sql/triggers`, `sql/procedures`, `sql/security`, `web/`.
- [x] Cumplimos los estándares SQL (Sección 6.2): nomenclatura `snake_case`, un
      script por propósito, encabezado con autor/descripción/dependencias en cada
      archivo, integridad referencial (`ON DELETE`/`ON UPDATE`) documentada.
- [x] Cumplimos los estándares del repositorio Git (Sección 6.1): README
      actualizado, `.gitignore` y `.env.example` en la raíz, sin `.env` real ni
      `node_modules` incluidos.
- [x] La bitácora de IA está actualizada (`docs/bitacora-ia/BITACORA_IA.md`,
      Entradas 1 a 10, sin campos "completar por el equipo" pendientes).
- [x] Los scripts DDL fueron ejecutados contra una instancia MySQL/MariaDB real
      desde cero, sin errores (no solo validados sintácticamente), y se corrieron
      10 pruebas de restricciones de integridad (10/10 exitosas). Evidencia
      completa en `docs/casos-prueba/CASOS_PRUEBA.md` y
      `docs/casos-prueba/evidencias/`.
- [x] La aplicación web (login + 2 CRUD: Producto y Cliente) fue probada de
      extremo a extremo contra la base de datos real: creación real de
      registros, listado, manejo de NIT duplicado sin caída del servidor, guard
      de autenticación y logout (7/7 pruebas exitosas). Capturas de pantalla
      reales incluidas.
- [x] No hay credenciales expuestas en el repositorio. Se detectó y eliminó un
      `web/.env` con credenciales reales que venía incluido en una versión previa
      del paquete; solo se conservan `.env.example` (raíz) y `web/.env.example`.

## Hallazgos y decisiones de esta entrega
(ver detalle completo en `docs/entrega-2/ENTREGA2_DISENO_LOGICO.md`, Sección 1)

- Se detectó y documentó una inconsistencia entre el texto de la Entrega 1 y el
  diagrama ER; se usó el diagrama corregido (`Pavanamoon_er_chen_corregido.drawio`)
  como fuente de verdad.
- Se corrigieron 7 imprecisiones/inconsistencias del modelo (ver tabla completa en
  ENTREGA2_DISENO_LOGICO.md §1.2), incluyendo la eliminación de la duplicación de
  precio entre `PRODUCTO` y `PRESENTACION_VENTA`: el precio ahora vive una sola vez
  en `PRODUCTO.precio_venta`.
- Se agregaron 2 atributos indispensables no presentes en el diagrama
  (`cliente.nombre_cliente`, `pedido.estado`), documentados con su justificación.
- Pendiente menor no bloqueante: el archivo editable `Modelo_Entidad_R_Pavanamoon.mwb`
  (MySQL Workbench) todavía conserva la columna de precio duplicada que ya se quitó
  en el `.drawio`, el DDL y el diccionario; el PNG/PDF del modelo relacional ya se
  regeneraron directamente desde el DDL real y están sincronizados. Ajuste manual
  pendiente de ~30 segundos en Workbench, documentado en
  `ENTREGA2_DISENO_LOGICO.md` §1.3.

## Evidencia de ejecución real (no solo revisión de código)

| Bloque | Casos | Resultado |
|---|---|---|
| DDL/DML desde cero contra MySQL real | 2 | 2/2 ✅ |
| Restricciones de integridad (UNIQUE, CHECK, FK, columnas generadas) | 10 | 10/10 ✅ |
| Aplicación web real (login, CRUD, validaciones, auth guard) | 7 | 7/7 ✅ |

Detalle completo, comandos reproducibles y capturas de pantalla en
[`docs/casos-prueba/CASOS_PRUEBA.md`](../casos-prueba/CASOS_PRUEBA.md).

## Firmas

| Nombre completo | Carné | Firma / Confirmación |
|---|---|---|
| Fernando Rafael Duarte Hernández | 2690-24-7341 | |
| Luis Adolfo Martínez Hernández | 2690-23-6092 | |
| Cristian Otoniel Pérez Ríos | 2690-22-18389 | |
| José Alejandro Cabrera Gramajo | 2690-23-11913 | |

**Fecha de firma:** _____________________

> Nota: los checkboxes de este documento reflejan el trabajo y las pruebas reales
> ejecutadas por el agente de IA en esta sesión (ver evidencia enlazada arriba).
> Cada integrante debe firmar únicamente después de revisar personalmente el
> repositorio y estar de acuerdo con lo aquí certificado — la firma es una
> declaración de responsabilidad individual, no un trámite automático.

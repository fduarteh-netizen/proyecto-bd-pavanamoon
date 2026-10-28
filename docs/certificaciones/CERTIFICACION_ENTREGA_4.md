# Certificación de Calidad — Entrega 4
## Proyecto Pavanamoon — Sistema de Gestión de Inventario y Distribución de Calzado

> Cada casilla se marcó solo después de comprobarla. Las casillas sin marcar
> quedan pendientes y se indican así a propósito.

Nosotros, los integrantes del equipo abajo firmantes, certificamos que la
Entrega 4 cumple con lo siguiente:

- [x] Cumplimos la estructura de carpetas obligatoria (Sección 7);
      `docs/entrega-4/` contiene la documentación de la entrega.
- [x] Cumplimos los estándares SQL (Sección 6.2): un objeto por archivo (S2),
      encabezado (S3), regla de negocio explicada (S6), sin datos calculables
      duplicados (S7) y todo probado antes de entregar (S8). Los cambios de
      esquema están en un script nuevo (`sql/ddl/07_ajustes_entrega4.sql`).
- [x] La base se instala desde cero con `INSTALL.md` sin errores: 19 tablas,
      6 vistas, 1 función, 4 procedimientos y 3 triggers.
- [x] La base de producción (Railway) es igual al repositorio:
      `railway_verificar.sql` dio `IGUAL AL REPOSITORIO`.
- [x] La aplicación pública funciona con control por rol:
      https://grand-acceptance-production-0ac1.up.railway.app
- [x] Los casos de prueba están documentados y ejecutados
      (`docs/casos-prueba/CASOS_PRUEBA_ENTREGA4.md`), con la matriz de
      trazabilidad y evidencias en `docs/casos-prueba/evidencias/`. Las
      ejecuciones locales y las de Railway están identificadas por separado.
- [ ] Al menos un integrante repitió las baterías locales en su máquina
      (sección 5 de `CASOS_PRUEBA_ENTREGA4.md`).
- [ ] La prueba manual en Railway con datos ficticios (RW-01 a RW-08) está
      registrada con su resultado real.
- [x] El manual técnico, el manual de usuario y el diagrama actualizado están
      en el repositorio, y el diagrama refleja `movimiento_stock.pedido_id`.
      El manual técnico justifica el CRUD de ingresos y pedidos
      (`INFORME_FINAL.md`, sección 6.1).
- [x] Los flujos del manual de usuario se verificaron en la aplicación
      (instalación local, 25/10/2026). [ ] Pendiente: repetirlos en la app
      publicada (pruebas RW).
- [x] El informe final (`docs/entrega-4/INFORME_FINAL.md`) está en el
      repositorio. [ ] Pendiente: firmas de la declaración de integridad.
- [ ] La aplicación cumple los estándares web de la Sección 6.3 de la guía.
- [ ] La bitácora de IA está actualizada (Entradas 17 a 20) y los campos
      _(completar)_ están llenos.
- [x] No hay credenciales expuestas: el repositorio no contiene `.env` real ni
      contraseñas de producción, y la contraseña del administrador de Railway
      se cambió después de compartirse en una conversación.
- [x] El README y la documentación están actualizados; el PR #3 se integró en
      `main` y existe la etiqueta `entrega-4`.

## Resumen de la entrega

| Producto | Cantidad | Estado |
|---|---|---|
| Tablas / vistas / funciones / procedimientos / triggers | 19 / 6 / 1 / 4 / 3 | ✅ |
| Módulos web | 11 (7 de la E3 + Reportes, Empleados, Usuarios, Catálogos) | ✅ |
| Casos de prueba SQL y web (CP4-01 a CP4-22) | 22 | ✅ local |
| Pruebas de seguridad (SEG) | 11 | ✅ local |
| Pruebas de concurrencia (INT) | 7 | ✅ local |
| Pruebas unitarias | 10 | ✅ local |
| Prueba manual en Railway (RW) | 8 | ⏳ pendiente |
| Despliegue público | Railway | ✅ |
| Informe final + declaración de integridad | 2 | ✅ informe · ⏳ firmas |

## Firmas

| Nombre completo | Carné | Firma / Confirmación |
|---|---|---|
| Fernando Rafael Duarte Hernández | 2690-24-7341 | Confirmado – 27/10/2026 |
| Luis Adolfo Martínez Hernández | 2690-23-6092 | Confirmado – 27/10/2026 |
| Cristian Otoniel Pérez Ríos | 2690-22-18389 | Confirmado – 27/10/2026 |
| José Alejandro Cabrera Gramajo | 2690-23-11913 | Confirmado – 27/10/2026 |

**Fecha de firma:** 27/10/2026

> Cada integrante firma después de revisar personalmente el repositorio. La
> firma es una declaración de responsabilidad individual.
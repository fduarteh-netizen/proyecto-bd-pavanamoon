# Pavanamoon — Sistema de Gestión de Inventario y Distribución de Calzado Deportivo (Fútbol)

Proyecto de base de datos relacional para la Universidad Mariano Gálvez de Guatemala. Sistema para centralizar la gestión de inventario de calzado de fútbol (marca propia), recepción de mercadería por furgón, clientes (detalle y mayoreo), pedidos, movimientos de stock (kardex) y control de acceso por roles de la empresa Pavanamoon.

## Integrantes

| Nombre completo | Carné |
|---|---|
| Fernando Rafael Duarte Hernández | 2690-24-7341 |
| Luis Adolfo Martínez Hernández | 2690-23-6092 |
| Cristian Otoniel Pérez Ríos | 2690-22-18389 |
| José Alejandro Cabrera Gramajo | 2690-23-11913 |

## SGBD

**MySQL 8.x**

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
│   └── ddl/ dml/ views/ triggers/ procedures/ security/
└── web/                # Aplicación web (Node.js + Express + EJS, desde Entrega 2)
```

## Estado del proyecto

| Entrega | Estado | Tag |
|---|---|---|
| Entrega 1 — Análisis y diseño conceptual | ✅ Completada | `entrega-1` |
| Entrega 2 — Diseño lógico e implementación base | ✅ Completada | `entrega-2` |
| Entrega 3 — Implementación avanzada, seguridad y pruebas | ✅ Completada (vistas, triggers, procedimientos, 3 roles, 8/8 pruebas, web ≈70 %) | `entrega-3` |
| Entrega 4 — Integración y defensa oral | 🔄 En cierre: web completa, seguridad y concurrencia (PR #2), desplegada en Railway, con manuales, diagramas e informe final; faltan las pruebas manuales en Railway y las firmas | `entrega-4` _(se crea al cerrar)_ |

> **Nota de corrección (Entrega 2):** se detectó que el texto de
> `docs/entrega-1/ENTREGA1_PROPUESTA.md` no reflejaba el diagrama ER final aprobado en
> la Entrada 7 de la bitácora de IA (que reemplazó `PROVEEDOR`/`COMPRA` por
> `FURGON`/`INGRESO_MERCADERIA`). La Entrega 2 usa el diagrama corregido como fuente
> de verdad; también se corrigió una duplicación del precio de venta que existía
> entre `PRODUCTO` y `PRESENTACION_VENTA` (el precio vive ahora una sola vez en
> `PRODUCTO`). El detalle completo de ambas correcciones está en
> `docs/entrega-2/ENTREGA2_DISENO_LOGICO.md`, Sección 1.

## Modelo de negocio (resumen)

Pavanamoon es marca propia de calzado deportivo especializado en fútbol, con modelos clasificados por categoría de edad (Niño/Juvenil/Adulto) y tipo de suela (Hule/Flex/TPU). La mercadería llega en **furgones**; el sistema registra el furgón, el ingreso a bodega y el detalle de variantes recibidas (talla + color), sin gestionar un catálogo de proveedores externos ni logística/aduanas — ese fue un alcance evaluado y descartado deliberadamente por el equipo (ver Sección 7.2 de la propuesta).

## Instalación

Ver [`INSTALL.md`](./INSTALL.md): scripts DDL ejecutables (`sql/ddl/`), datos semilla y pasos para levantar la aplicación web localmente.

Tras la Entrega 4, la base completa tiene **19 tablas, 6 vistas, 1 función, 4 procedimientos y 3 triggers**. La versión desplegada en Railway usa el esquema `railway` y se verificó igual al repositorio el 25/10/2026 (ver `docs/entrega-4/ENTREGA4_IMPLEMENTACION.md`, sección 4).

## Documentación

- Propuesta y diseño conceptual (Entrega 1): [`docs/entrega-1/ENTREGA1_PROPUESTA.md`](./docs/entrega-1/ENTREGA1_PROPUESTA.md)
- Diseño lógico, 3FN y diccionario de datos (Entrega 2): [`docs/entrega-2/ENTREGA2_DISENO_LOGICO.md`](./docs/entrega-2/ENTREGA2_DISENO_LOGICO.md)
- Avance de la aplicación web (Entrega 2, 30 %): [`docs/entrega-2/AVANCE_WEB.md`](./docs/entrega-2/AVANCE_WEB.md)
- Diagrama ER (Chen) y modelo relacional (MySQL Workbench), cada uno editable + PNG/PDF — **fuente de verdad del modelo de datos**: [`docs/diagramas/`](./docs/diagramas/)
- Bitácora de uso de IA: [`docs/bitacora-ia/BITACORA_IA.md`](./docs/bitacora-ia/BITACORA_IA.md)
- Certificaciones de calidad por entrega: [`docs/certificaciones/`](./docs/certificaciones/)
- Casos de prueba y evidencia real de ejecución (SQL + app web): [`docs/casos-prueba/CASOS_PRUEBA.md`](./docs/casos-prueba/CASOS_PRUEBA.md) (Entrega 2) y [`docs/casos-prueba/CASOS_PRUEBA_ENTREGA3.md`](./docs/casos-prueba/CASOS_PRUEBA_ENTREGA3.md) (Entrega 3, con matriz de trazabilidad)
- Implementación avanzada y seguridad (Entrega 3): [`docs/entrega-3/ENTREGA3_IMPLEMENTACION.md`](./docs/entrega-3/ENTREGA3_IMPLEMENTACION.md)
- Avance de la aplicación web (Entrega 3, ≈70 %): [`docs/entrega-3/AVANCE_WEB.md`](./docs/entrega-3/AVANCE_WEB.md)
- Integración, despliegue y seguridad (Entrega 4): [`docs/entrega-4/ENTREGA4_IMPLEMENTACION.md`](./docs/entrega-4/ENTREGA4_IMPLEMENTACION.md)
- Casos de prueba de la Entrega 4, con matriz de trazabilidad y verificación en Railway: [`docs/casos-prueba/CASOS_PRUEBA_ENTREGA4.md`](./docs/casos-prueba/CASOS_PRUEBA_ENTREGA4.md)
- Sincronización de la base de Railway con el repositorio (scripts, guía y pruebas): [`docs/entrega-4/despliegue-railway/`](./docs/entrega-4/despliegue-railway/)
- **Informe final** (consolida las 4 entregas): [`docs/entrega-4/ENTREGA4_INFORME_FINAL.md`](./docs/entrega-4/ENTREGA4_INFORME_FINAL.md)
- Declaración de integridad académica: [`docs/entrega-4/ENTREGA4_DECLARACION_INTEGRIDAD.md`](./docs/entrega-4/ENTREGA4_DECLARACION_INTEGRIDAD.md)
- Guía de preparación de la defensa oral: [`docs/entrega-4/ENTREGA4_GUIA_DEFENSA.md`](./docs/entrega-4/ENTREGA4_GUIA_DEFENSA.md)
- **Manual técnico:** [`docs/entrega-4/ENTREGA4_MANUAL_TECNICO.md`](./docs/entrega-4/ENTREGA4_MANUAL_TECNICO.md)
- **Manual de usuario** (con capturas de cada flujo): [`docs/entrega-4/ENTREGA4_MANUAL_USUARIO.md`](./docs/entrega-4/ENTREGA4_MANUAL_USUARIO.md)
- Diagramas actualizados a la Entrega 4 (relación "origina" PEDIDO–MOVIMIENTO_STOCK y `tipo_cliente.porcentaje_descuento`): [`docs/diagramas/`](./docs/diagramas/)

## Enlaces

- Repositorio: https://github.com/fduarteh-netizen/proyecto-bd-pavanamoon
- Aplicación desplegada (Railway, despliegue automático desde `main`): https://grand-acceptance-production-0ac1.up.railway.app
  — acceso con usuario y contraseña; las credenciales de producción no se publican en el repositorio.

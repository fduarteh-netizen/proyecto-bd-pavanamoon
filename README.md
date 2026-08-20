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
└── web/                # Aplicación web (desde Entrega 2)
```

## Estado del proyecto

| Entrega | Estado | Tag |
|---|---|---|
| Entrega 1 — Análisis y diseño conceptual | ✅ Completada | `entrega-1` |
| Entrega 2 — Diseño lógico e implementación base | ⏳ Pendiente | `entrega-2` |
| Entrega 3 — Implementación avanzada y seguridad | ⏳ Pendiente | `entrega-3` |
| Entrega 4 — Integración y defensa oral | ⏳ Pendiente | `entrega-4` |

## Modelo de negocio (resumen)

Pavanamoon es marca propia de calzado deportivo especializado en fútbol, con modelos clasificados por categoría de edad (Niño/Juvenil/Adulto) y tipo de suela (Hule/Flex/TPU). La mercadería llega en **furgones**; el sistema registra el furgón, el ingreso a bodega y el detalle de variantes recibidas (talla + color), sin gestionar un catálogo de proveedores externos ni logística/aduanas — ese fue un alcance evaluado y descartado deliberadamente por el equipo (ver Sección 7.2 de la propuesta).

## Instalación

Ver [`INSTALL.md`](./INSTALL.md). Los scripts DDL ejecutables se agregan a partir de la Entrega 2 (`sql/ddl/`); hasta entonces este archivo documenta únicamente los requisitos previos (MySQL 8.x, motor InnoDB, variables de entorno en `.env.example`).

## Documentación

- Propuesta y diseño conceptual: [`docs/entrega-1/Entrega1_propuesta.md`](./docs/entrega-1/Entrega1_propuesta.md)
- Diagrama ER (Chen, editable + PNG/PDF): [`docs/diagramas/`](./docs/diagramas/)
- Bitácora de uso de IA: [`docs/bitacora-ia/Bitacora_ia.md`](./docs/bitacora-ia/Bitacora_ia.md)
- Certificaciones de calidad por entrega: [`docs/certificaciones/`](./docs/certificaciones/)

## Enlaces

- Repositorio: https://github.com/fduarteh-netizen/proyecto-bd-pavanamoon
- Aplicación desplegada: _(se agregará desde Entrega 2)_

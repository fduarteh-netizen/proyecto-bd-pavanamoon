# Guía — Importar el diagrama ER (Chen) a draw.io y exportar PNG/PDF

Archivo vigente: **`Pavanamoon_er_chen_corregido.drawio`** (15 entidades, incluye
`TIPO_CLIENTE` y `PRESENTACION_VENTA`; 16 relaciones —14 de tipo 1:N y 2 de tipo
N:M con atributos propios—, en notación Chen: rectángulo = entidad, rombo =
relación, óvalo = atributo).

> El archivo `pavanamoon_ER_chen.drawio` (13 entidades, sin `TIPO_CLIENTE` ni
> `PRESENTACION_VENTA`, con `COMPRA`/`DETALLE_COMPRA` en vez de
> `INGRESO_MERCADERIA`/`DETALLE_INGRESO`) quedó **obsoleto y fue eliminado** del
> repositorio a partir de la Entrega 2 — no debe recrearse ni exportarse.

## Paso a paso

1. Abre **https://app.diagrams.net** (draw.io) en el navegador. No necesitas cuenta si eliges "Decide más tarde" / trabajar sin guardar en la nube.
2. En la pantalla de inicio, elige **"Abrir archivo existente"** (Open Existing Diagram) → selecciona el archivo `Pavanamoon_er_chen_corregido.drawio`.
   - Alternativa: en el lienzo en blanco ve a **File → Import from → Device** y selecciona el archivo.
3. El diagrama se cargará automáticamente con todas las formas ya conectadas y posicionadas por módulo (Seguridad, Catálogo, Furgones/Ingresos, Ventas, Movimientos).
4. **Ajustes recomendados antes de exportar:**
   - Revisa que ninguna etiqueta se superponga; arrastra los óvalos de atributos si es necesario (todas las conexiones se mantienen).
   - Puedes seleccionar todo (`Ctrl+A`) y usar **Arrange → Layout → Organic** o mover manualmente si prefieres reordenar.
   - La leyenda (esquina superior izquierda) explica la notación: PK subrayada, atributos derivados con línea punteada, atributos multivaluados con borde grueso, relaciones N:M en rombo naranja con atributos propios.
5. **Exportar como PNG** (para el repositorio):
   - Ve a **File → Export as → PNG**.
   - Marca la opción **"Selection"** desmarcada (para exportar todo el diagrama) y **"Transparent Background"** desmarcada (fondo blanco para mejor lectura).
   - Resolución recomendada: 200% o 300% de escala para buena nitidez.
   - Guarda como `Pavanamoon_er_chen_corregido.png`.
6. **Exportar como PDF**:
   - Ve a **File → Export as → PDF**.
   - Elige **"Fit page(s) to drawing"** para que no se corte el diagrama.
   - Guarda como `Pavanamoon_er_chen_corregido.pdf`.
7. **Guardar el archivo editable** (obligatorio por el estándar D3 — "ER y relacional en editable + PNG/PDF"):
   - Ve a **File → Save as** y confirma que se guarde en formato `.drawio` (XML editable), sobrescribiendo `Pavanamoon_er_chen_corregido.drawio`.
8. Confirma que la carpeta del repositorio quede así (sin duplicados ni archivos viejos):
   ```
   docs/diagramas/Pavanamoon_er_chen_corregido.drawio   (editable)
   docs/diagramas/Pavanamoon_er_chen_corregido.png      (imagen)
   docs/diagramas/Pavanamoon_er_chen_corregido.pdf      (PDF)
   ```
9. Haz commit de los 3 archivos:
   ```bash
   git add docs/diagramas/
   git commit -m "docs(diagrama): actualiza diagrama ER Chen (editable, PNG, PDF)"
   git push
   ```

## Nota metodológica (para tu defensa oral)

Las relaciones **N:M** (`contiene` entre INGRESO_MERCADERIA–VARIANTE_PRODUCTO, e `incluye` entre PEDIDO–VARIANTE_PRODUCTO) se modelaron con **atributos propios sobre el rombo** (cantidad, costo_unitario/precio_unitario, subtotal derivado), que es la forma correcta en notación Chen pura. Estas relaciones N:M se tradujeron a las tablas `DETALLE_INGRESO` y `DETALLE_PEDIDO` durante el paso de **modelo relacional** en la Entrega 2 (regla estándar de transformación ER→Relacional: toda relación N:M se convierte en una tabla con las FK de ambas entidades participantes más sus atributos propios como PK compuesta o PK propia). `TIPO_CLIENTE` y `PRESENTACION_VENTA` se agregaron como catálogos independientes para poder explicar en la defensa por qué el segmento de cliente y la forma de venta no viven como atributos fijos dentro de `CLIENTE`/`DETALLE_PEDIDO`.

---

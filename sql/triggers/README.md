# sql/triggers

Esta carpeta existe para respetar la estructura obligatoria del proyecto
(Sección 7 de la guía) y se llenará en la **Entrega 3** con al menos 2
triggers, cada uno con su regla de negocio explicada (estándar S6), por
ejemplo:

- `trg_detalle_ingreso_after_insert`: al insertar una línea en
  `detalle_ingreso`, incrementa `variante_producto.stock_actual`.
- `trg_detalle_pedido_after_insert`: al insertar una línea en
  `detalle_pedido`, descuenta `variante_producto.stock_actual` y recalcula
  `pedido.total_pedido`.

Convención de nombres: `sql/triggers/NN_nombre_trigger.sql`, un trigger por
archivo (estándar S2), con encabezado (estándar S3).

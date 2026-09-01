# sql/procedures

Esta carpeta existe para respetar la estructura obligatoria del proyecto
(Sección 7 de la guía) y se llenará en la **Entrega 3** con al menos 2
procedimientos almacenados o funciones, cada uno con su regla de negocio
explicada (estándar S6), por ejemplo:

- `sp_registrar_pedido`: procedimiento transaccional que inserta un pedido y
  sus líneas, valida stock disponible y actualiza `total_pedido`.
- `fn_calcular_precio_linea`: función que calcula el precio de una línea de
  `detalle_pedido` a partir de `producto.precio_venta`, la cantidad de pares
  de la `presentacion_venta` elegida y el descuento del `tipo_cliente`.

Convención de nombres: `sql/procedures/NN_nombre_procedimiento.sql`, un
procedimiento/función por archivo (estándar S2), con encabezado (estándar S3).

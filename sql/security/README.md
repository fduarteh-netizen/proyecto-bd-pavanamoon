# sql/security

Esta carpeta existe para respetar la estructura obligatoria del proyecto
(Sección 7 de la guía) y se llenará en la **Entrega 3** con la definición de
los roles de MySQL y sus privilegios diferenciados (mínimo 3, Sección 5,
req. 6), por ejemplo:

```sql
CREATE USER 'pavanamoon_admin'@'%'      IDENTIFIED BY '...';
CREATE USER 'pavanamoon_bodeguero'@'%'  IDENTIFIED BY '...';
CREATE USER 'pavanamoon_vendedor'@'%'   IDENTIFIED BY '...';

GRANT ALL PRIVILEGES ON pavanamoon.* TO 'pavanamoon_admin'@'%';
GRANT SELECT, INSERT, UPDATE ON pavanamoon.variante_producto, pavanamoon.ingreso_mercaderia, pavanamoon.detalle_ingreso, pavanamoon.movimiento_stock TO 'pavanamoon_bodeguero'@'%';
GRANT SELECT, INSERT, UPDATE ON pavanamoon.cliente, pavanamoon.cliente_telefono, pavanamoon.pedido, pavanamoon.detalle_pedido TO 'pavanamoon_vendedor'@'%';
```

Estos usuarios de MySQL son distintos de la tabla `usuario` de la aplicación
(que controla el login de la app web); en la Entrega 3 se documentará cómo se
relacionan ambos niveles de seguridad.

Convención de nombres: `sql/security/NN_descripcion.sql` (estándar S2), con
encabezado (estándar S3).

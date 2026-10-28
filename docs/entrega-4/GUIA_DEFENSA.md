# Guía de preparación — Defensa oral (grupal e individual)
## Proyecto Pavanamoon

La rúbrica evalúa una defensa **grupal** (BD + app web, 0.50 pts) y pide
también una **individual**: cada integrante debe poder responder sobre
cualquier parte del proyecto, no solo sobre la suya.

## 1. Demostración sugerida (8–10 minutos, en Railway, con datos ficticios)

| # | Qué mostrar | Qué decir |
|---|---|---|
| 1 | Iniciar sesión como **vendedor** e intentar abrir `/furgones` | El control por rol se hace en la web (`permisos.js`) y en la BD (`GRANT`) |
| 2 | Iniciar sesión como **administrador**: inventario con alerta de stock bajo | `vw_stock_variantes` calcula la alerta; no se almacena (S7) |
| 3 | Registrar un ingreso de mercadería y luego abrir el kardex | `trg_detalle_ingreso_ai` suma el stock y registra la `entrada` |
| 4 | Pedido para un cliente **mayorista**: 1 caja | `fn_calcular_precio_linea` aplica el descuento; nadie digita el precio |
| 5 | Inventario y kardex de esa variante | `trg_detalle_pedido_ai` descontó 12 pares y registró la `salida` con el pedido |
| 6 | Intentar vender más de lo que hay | `trg_detalle_pedido_bi` lo rechaza con un mensaje de negocio |
| 7 | Cancelar un pedido pendiente | `sp_cancelar_pedido`: el stock vuelve y el kardex registra `cancelacion` |
| 8 | Historial por cliente y reportes | `vw_pedidos_resumen`, `vw_ventas_diarias`, `vw_ventas_por_modelo` |

Ensáyenla antes, con los datos ficticios ya cargados. Decidan quién maneja
la computadora y quién explica cada paso.

## 2. Reparto sugerido de temas (todos deben conocer todos)

| Tema | Responsable principal |
|---|---|
| Problema, RF/RD, modelo ER y 3FN | _(completar)_ |
| Triggers, procedimientos y concurrencia (`FOR UPDATE`) | _(completar)_ |
| Seguridad: roles de BD y seguridad web | _(completar)_ |
| Aplicación web, despliegue en Railway y pruebas | _(completar)_ |

## 3. Preguntas probables y respuesta corta

**¿Por qué el stock se actualiza con triggers y no en la aplicación?**
Para que la regla se cumpla desde cualquier lugar (web, Workbench o un
script). Si estuviera en la app, una inserción directa en la base dejaría el
stock desincronizado.

**¿Cómo evitan vender dos veces el mismo par si dos vendedores compran a la vez?**
El trigger y el procedimiento leen la variante con `SELECT … FOR UPDATE`: el
segundo espera a que el primero confirme, y entonces ya ve el stock
actualizado. Lo prueban INT-03 (seis pedidos simultáneos, sin sobreventa) e
INT-04 (sin deadlock).

**¿Por qué no se pueden editar ni borrar pedidos e ingresos?**
Porque ya movieron el stock y generaron kardex. Borrarlos destruiría la
auditoría (RF15, RF16). Se corrigen con operaciones inversas registradas:
cancelación o devolución. `fk_movimiento_pedido` con `ON DELETE RESTRICT` lo
impide en la propia base (CP4-06). Ver `INFORME_FINAL.md`, sección 6.1.

**¿Cómo se calcula el descuento mayorista?**
`fn_calcular_precio_linea` = precio por par × pares de la presentación ×
(1 − `tipo_cliente.porcentaje_descuento`/100). El precio vive solo en
`producto`.

**¿Por qué el teléfono está en otra tabla?**
Por 1FN: un cliente o empleado puede tener varios teléfonos (atributo
multivaluado).

**¿Dónde se ve que está en 3FN?**
En la Entrega 2, sección 3: no hay dependencias parciales ni transitivas. Por
ejemplo, el descuento depende del tipo de cliente, no del cliente, por eso
vive en `tipo_cliente`.

**¿Qué diferencia hay entre cancelar y devolver?**
Se cancela un pedido **pendiente** (el cliente desiste antes de la entrega):
vuelve todo el stock. Se devuelve sobre un pedido **completado**, de forma
parcial, y nunca más de lo comprado menos lo ya devuelto.

**¿Qué roles hay en la base de datos?**
`rol_administrador`, `rol_bodeguero` y `rol_vendedor`, con privilegios
mínimos. Por ejemplo, el vendedor no tiene `INSERT` directo sobre `pedido`:
solo `EXECUTE` sobre los procedimientos (CP3-06, CP3-07).

**¿Cómo protegen las contraseñas y la sesión?**
Las contraseñas se guardan con bcrypt. La sesión se regenera al iniciar
sesión y la cookie es `HttpOnly` y `SameSite` (`Secure` en producción). Hay
protección CSRF, bloqueo tras intentos fallidos y consultas parametrizadas
contra la inyección SQL (SEG-01 a SEG-11, CP4-22).

**¿Qué pasó con la base de Railway?**
Se instaló desde un dump local antiguo, con objetos que no estaban en el
repositorio, y eso rompía el filtro de pedidos por cliente. Se detectó
comparando contra el repositorio y se corrigió con un script probado en una
base aislada, sin tocar datos. Lección: producción se instala desde los
scripts versionados.

**¿Por qué la hora sale diferente en la app publicada?**
El servidor de Railway usa UTC. La corrección está identificada y
documentada como limitación conocida.

**¿Cómo usaron la IA?**
Como asistente. Todo está en la bitácora, con lo que se pidió, lo que se
obtuvo y cómo lo validamos, incluidos los errores que encontramos en sus
respuestas.

## 4. Antes de entrar

- [ ] La app pública abre y los tres usuarios de demostración funcionan
      (las contraseñas, fuera del repositorio).
- [ ] Hay datos ficticios suficientes: clientes mayorista e individual y
      variantes con stock.
- [ ] El repositorio está abierto en la rama `main` final, con la etiqueta
      `entrega-4`.
- [ ] Hay un plan B si falla internet: la instalación local con `INSTALL.md`.

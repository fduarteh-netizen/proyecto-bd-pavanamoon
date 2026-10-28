# Sincronizar la base de Railway con el repositorio — Pavanamoon

> **Estado:** aplicado en Railway por el equipo el 25/10/2026; resultado `IGUAL AL REPOSITORIO`. Se conserva como evidencia y para repetirlo si la base se reinstala desde un dump.

Corrige la base `railway` de producción, que se instaló desde una exportación
antigua y no coincide con `sql/` (`main` 28f1176). Defecto visible: el filtro
**Historial por cliente (RF14)** responde HTTP 500, y las columnas Vendedor y
Pares de `/pedidos` salen vacías.

| Archivo | Para qué | ¿Modifica algo? |
|---|---|---|
| `railway_verificar.sql` | Comprobar el estado antes y después | No: solo `SELECT` |
| `railway_sincronizar_con_repo.sql` | La corrección | Sí: solo vistas, rutinas y 1 trigger |
| `railway_revertir_sincronizacion.sql` | Volver al estado anterior (plan A) | Sí: solo vistas, rutinas y 1 trigger |
| `pruebas_aisladas_sincronizacion.txt` | Evidencia de las pruebas | — |

## 1. Qué cambia

**No toca ninguna tabla, columna, restricción ni fila.**

| Acción | Objeto | Motivo |
|---|---|---|
| Elimina | `vw_kardex_movimientos`, `vw_stock_bajo_minimo`, `vw_ventas_por_categoria` | No existen en el repositorio; la app no las usa |
| Elimina | `sp_agregar_variante_ingreso`, `sp_agregar_variante_pedido`, `sp_completar_ingreso`, `sp_registrar_ingreso` | Igual que la fila anterior |
| Elimina | `sp_cambiar_estado_pedido` | Además, cancela un pedido **sin** devolver el stock |
| Elimina | `fn_calcular_total_pedido` | No existe en el repositorio |
| Elimina | `trg_registrar_entrada_ingreso` | Tiene el mismo cuerpo que el del repositorio, pero otro nombre |
| Crea | `trg_detalle_ingreso_ai` | Copia de `sql/triggers/01_trg_detalle_ingreso_ai.sql` |
| Reemplaza | `vw_pedidos_resumen` | Copia de `sql/views/02_...`: agrega `cliente_id`, `vendedor` y `pares_totales` |
| Reemplaza | `sp_crear_pedido` | Copia de `sql/procedures/02_...`: valida el cliente y el usuario activo |

No cambian, porque ya son idénticos al repositorio: `fn_calcular_precio_linea`,
`sp_agregar_linea_pedido`, `sp_registrar_devolucion`, `sp_cancelar_pedido`, las
otras 5 vistas y los 2 triggers de `detalle_pedido`.

| | Antes | Después |
|---|---|---|
| Tablas / vistas / funciones / procedimientos / triggers | 19 / 9 / 2 / 9 / 3 | **19 / 6 / 1 / 4 / 3** |

## 2. Verificar el estado actual (solo lectura)

1. Activa temporalmente el acceso público de MySQL en Railway y abre la conexión
   **Pavanamoon Railway** en Workbench.
2. Usa **File → Open SQL Script…** para abrir `railway_verificar.sql`, y luego el
   rayo ⚡ (ejecutar todo).
3. Revisa estos resultados:
   - **Punto 1:** `base_actual = railway` y un servidor que **no** sea tu computadora.
   - **Punto 2:** `19 | 9 | 2 | 9 | 3`.
   - **Punto 3b:** 0 filas (no hay objetos no previstos).
   - **Punto 3c:** 0 filas (no hay permisos por rutina que se perderían).
   - **Punto 5:** veredicto **`ESTADO ANTERIOR (dump local): falta sincronizar`**.
   - **Punto 6:** anota los conteos de filas.
   - **Punto 8:** falla con `Error Code: 1054 Unknown column 'cliente_id'`. **Es lo
     esperado**: es el defecto que se corrige.

**Si el veredicto es otro, o el 3b o el 3c devuelven filas: no continúes.** Este
script solo está probado para el estado "ESTADO ANTERIOR".

## 3. Respaldo y su comprobación

1. Ve a **Server → Data Export** (conexión Railway) y marca el esquema `railway`
   con todos sus objetos.
2. Elige **Dump Structure and Data** y marca las tres casillas de **Objects to
   Export** (Stored Procedures and Functions, Events, Triggers).
3. Elige **Export to Self-Contained File**, con un nombre como
   `C:\Users\luisa\Documents\respaldo_railway_2026-10-25.sql`.
4. Marca **Create Dump in a Single Transaction** e **Include Create Schema**.
   Pulsa **Start Export** y espera "Export Completed".
5. Comprueba el archivo en PowerShell. Usa **comillas simples**, porque PowerShell
   trata el acento grave (`) como carácter especial dentro de comillas dobles:

```powershell
$f = 'C:\Users\luisa\Documents\respaldo_railway_2026-10-25.sql'
(Get-Item $f).Length                                                              # mayor que 0
(Select-String -Path $f -SimpleMatch 'CREATE TABLE `').Count                      # 19
(Select-String -Path $f -SimpleMatch 'Final view structure for view').Count       # 9
(Select-String -Path $f -Pattern 'CREATE DEFINER=.* PROCEDURE').Count             # 9
(Select-String -Path $f -Pattern 'CREATE DEFINER=.* FUNCTION').Count              # 2
(Select-String -Path $f -SimpleMatch '50003 TRIGGER').Count                       # 3
(Select-String -Path $f -SimpleMatch 'INSERT INTO `usuario`').Count               # 1 o más
(Select-String -Path $f -SimpleMatch 'GTID_PURGED').Count                         # 0
Get-Content $f -Tail 1                                                            # -- Dump completed on ...
```

Si un número no coincide, **no continúes**. Si `GTID_PURGED` es mayor que 0,
vuelve a exportar con **Advanced Options → set-gtid-purged = OFF**, para que el
archivo se pueda restaurar.

**Comprobación opcional (5 minutos), solo en tu MySQL local y nunca en Railway:**
importa el respaldo en la conexión *Local instance MySQL80* (Data Import) y
ejecuta el punto 2 de `railway_verificar.sql`. Debe dar `19 | 9 | 2 | 9 | 3`.
Después, en local, puedes borrarlo con `DROP DATABASE railway;`.

## 4. Ejecutar la sincronización

Antes de empezar, que **nadie use la aplicación**. Durante un instante no existe
el trigger de ingresos y, en otro, no existe `sp_crear_pedido`.

1. Ve a **Server → Data Import** (conexión Railway).
2. Elige **Import from Self-Contained File** y selecciona
   `railway_sincronizar_con_repo.sql`.
3. En **Default Target Schema** elige `railway` (el archivo ya contiene `USE railway;`).
4. Pulsa **Start Import** y espera "Import of … has finished" **sin líneas `ERROR`**.

Se usa Data Import, y no el editor, porque Data Import ejecuta el cliente `mysql`,
que es el mismo con el que se probó el script.

## 5. Verificar el resultado

Ejecuta de nuevo `railway_verificar.sql` (editor ⚡). Esto es lo que debe salir:

- **Punto 2:** `19 | 6 | 1 | 4 | 3`.
- **Punto 3:** los 14 objetos del repositorio en estado `presente`, y los 10
  antiguos en estado `(ya no existe)`.
- **Punto 4:** `12` columnas y `3` de 3, con `es_version_repositorio = 1` en las 4 filas.
- **Punto 5:** **`IGUAL AL REPOSITORIO`**.
- **Punto 6:** los mismos conteos que anotaste antes.
- **Punto 7:** 0 filas (el stock coincide con el kardex).
- **Punto 8:** sin error.

En la web, `/pedidos` → **Historial por cliente** → elegir un cliente → **Filtrar**
ya no debe dar error, y las columnas Vendedor y Pares deben tener valores.

Al terminar, **desactiva otra vez el acceso público de MySQL** en Railway.

## 6. Si aparece un error

| Situación | Qué hacer |
|---|---|
| Error en el paso 2 o 3 (antes de cambiar nada) | Detente y envía la captura. No hay nada que recuperar |
| `ERROR 1049 Unknown database 'railway'` | Estás en la conexión local. No pasó nada: cambia a la conexión Railway |
| `ERROR 1044/1142 … denied` | La conexión no usa el usuario de Railway (`root`). No pasó nada |
| Se corta la conexión o aparece un error **durante** el paso 4 | No ejecutes nada más. Ejecuta `railway_verificar.sql`: si dice `MIXTO`, repite el paso 4 completo (el script se puede ejecutar varias veces) y vuelve a verificar |
| El paso 4 termina bien, pero la aplicación falla | **Plan A:** Data Import de `railway_revertir_sincronizacion.sql`. Vuelve exactamente al estado anterior (veredicto `ESTADO ANTERIOR`), sin tocar datos |
| Todo lo anterior falla | **Plan B:** Data Import del respaldo del paso 3 en la conexión Railway. Recrea las tablas con los datos **del momento del respaldo**. Es el último recurso |

Ante cualquier error, guarda la captura con el **primer** mensaje `ERROR` antes
de intentar otra cosa.

## 7. Pruebas realizadas en una base aislada

No se ejecutó nada en Railway. Las pruebas se hicieron en MySQL 8.0.46 con binlog
activo, sobre un esquema `railway` instalado con **el mismo paquete** que se
importó en Railway, con datos de demostración. El detalle está en
`pruebas_aisladas_sincronizacion.txt`.

| Prueba | Resultado |
|---|---|
| Verificación previa | `ESTADO ANTERIOR` |
| Respaldo (mysqldump, mismas opciones que Data Export) | Los conteos del paso 3 coinciden; restaurado en **otro servidor**, quedó idéntico (huella SHA-256 y CHECKSUM TABLE) |
| Sincronización | `IGUAL AL REPOSITORIO`; 0 diferencias con los objetos instalados desde `sql/` |
| Tablas y datos | Idénticos antes y después (estructura y CHECKSUM TABLE de las 19 tablas) |
| Segunda ejecución | El mismo resultado |
| Plan A (reversión), dos veces | Estado idéntico al inicial |
| Interrupción a mitad (solo las eliminaciones) | Veredicto `MIXTO`; al repetir el script completo, queda idéntico a una ejecución normal |
| Plan B (restaurar el respaldo sobre `railway`) | Estado idéntico al inicial |
| Control negativo | La comparación sí detecta `vw_pedidos_resumen` y `sp_crear_pedido` cuando difieren |
| Aplicación de `main` sobre la base corregida | `/pedidos?cliente=1`: de **HTTP 500 a 200**; aparecen Vendedor y Pares; los demás módulos responden 200 |
| Funcional | Ingreso: +12 y kardex `entrada`; cliente inexistente: rechazado; pedido mayorista y su cancelación: el stock vuelve; devolución: kardex `devolucion_cliente` |

**Límites:** no se probó con MySQL Workbench en Windows ni con la versión exacta
de MySQL de Railway. Por eso existen la verificación previa y el respaldo
comprobado.

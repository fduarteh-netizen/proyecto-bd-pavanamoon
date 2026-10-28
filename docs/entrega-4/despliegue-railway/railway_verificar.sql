-- =============================================================================
-- Archivo:      railway_verificar.sql
-- Autor:        Equipo Pavanamoon (preparado con asistencia de IA, ver bitácora)
-- Descripción:  Verificación de SOLO LECTURA de la base `railway` de producción.
--               Se ejecuta DOS veces, en la conexión "Pavanamoon Railway":
--                 1) ANTES de railway_sincronizar_con_repo.sql (estado inicial)
--                 2) DESPUÉS de ejecutarlo (estado final)
--               Solo usa SELECT: no crea, no modifica y no borra nada.
--               Guarde el resultado de cada ejecución (captura o exportación)
--               para comparar los conteos de filas del punto 6.
-- Dependencias: ninguna
-- =============================================================================

USE railway;

-- 1) ¿Estoy conectado al servidor correcto? ----------------------------------
--    Esperado: base_actual = railway. Si version o servidor corresponden a su
--    computadora (Local instance MySQL80), DETÉNGASE: está en la conexión local.
SELECT DATABASE() AS base_actual, VERSION() AS version_mysql,
       @@hostname AS servidor, CURRENT_USER() AS usuario_conectado;

-- 2) Conteo de objetos ----------------------------------------------------------
--    ANTES (estado del dump):   19 tablas, 9 vistas, 2 funciones, 9 procedimientos, 3 triggers
--    DESPUÉS (repositorio):     19 tablas, 6 vistas, 1 función,   4 procedimientos, 3 triggers
SELECT
  (SELECT COUNT(*) FROM information_schema.tables   WHERE table_schema = 'railway' AND table_type = 'BASE TABLE') AS tablas,
  (SELECT COUNT(*) FROM information_schema.views    WHERE table_schema = 'railway')                                AS vistas,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_type = 'FUNCTION')  AS funciones,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_type = 'PROCEDURE') AS procedimientos,
  (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'railway')                              AS triggers;

-- 3) Cada objeto programado, clasificado ----------------------------------------
--    "presente"     = su nombre existe en sql/ del repositorio (debe quedar;
--                     el punto 4 confirma si además es la VERSIÓN del repositorio)
--    "antiguo"      = NO existe en sql/ (el script lo elimina)
--    "FALTA"        = debería existir y no está
SELECT o.tipo, o.nombre,
       CASE WHEN o.esperado = 'repositorio' AND x.nombre IS NULL THEN 'FALTA'
            WHEN o.esperado = 'repositorio'                      THEN 'presente'
            WHEN x.nombre IS NULL                                THEN '(ya no existe)'
            ELSE 'antiguo: el script lo elimina' END AS estado
FROM (
  SELECT 'VIEW' tipo, 'vw_stock_variantes' nombre, 'repositorio' esperado UNION ALL
  SELECT 'VIEW', 'vw_pedidos_resumen',      'repositorio' UNION ALL
  SELECT 'VIEW', 'vw_kardex',               'repositorio' UNION ALL
  SELECT 'VIEW', 'vw_ingresos_detalle',     'repositorio' UNION ALL
  SELECT 'VIEW', 'vw_ventas_diarias',       'repositorio' UNION ALL
  SELECT 'VIEW', 'vw_ventas_por_modelo',    'repositorio' UNION ALL
  SELECT 'FUNCTION',  'fn_calcular_precio_linea', 'repositorio' UNION ALL
  SELECT 'PROCEDURE', 'sp_crear_pedido',          'repositorio' UNION ALL
  SELECT 'PROCEDURE', 'sp_agregar_linea_pedido',  'repositorio' UNION ALL
  SELECT 'PROCEDURE', 'sp_registrar_devolucion',  'repositorio' UNION ALL
  SELECT 'PROCEDURE', 'sp_cancelar_pedido',       'repositorio' UNION ALL
  SELECT 'TRIGGER', 'trg_detalle_ingreso_ai', 'repositorio' UNION ALL
  SELECT 'TRIGGER', 'trg_detalle_pedido_bi',  'repositorio' UNION ALL
  SELECT 'TRIGGER', 'trg_detalle_pedido_ai',  'repositorio' UNION ALL
  SELECT 'VIEW', 'vw_kardex_movimientos',   'antiguo' UNION ALL
  SELECT 'VIEW', 'vw_stock_bajo_minimo',    'antiguo' UNION ALL
  SELECT 'VIEW', 'vw_ventas_por_categoria', 'antiguo' UNION ALL
  SELECT 'FUNCTION',  'fn_calcular_total_pedido',    'antiguo' UNION ALL
  SELECT 'PROCEDURE', 'sp_agregar_variante_ingreso', 'antiguo' UNION ALL
  SELECT 'PROCEDURE', 'sp_agregar_variante_pedido',  'antiguo' UNION ALL
  SELECT 'PROCEDURE', 'sp_cambiar_estado_pedido',    'antiguo' UNION ALL
  SELECT 'PROCEDURE', 'sp_completar_ingreso',        'antiguo' UNION ALL
  SELECT 'PROCEDURE', 'sp_registrar_ingreso',        'antiguo' UNION ALL
  SELECT 'TRIGGER', 'trg_registrar_entrada_ingreso', 'antiguo'
) o
LEFT JOIN (
  SELECT 'VIEW' tipo, table_name nombre FROM information_schema.views WHERE table_schema = 'railway'
  UNION ALL SELECT routine_type, routine_name FROM information_schema.routines WHERE routine_schema = 'railway'
  UNION ALL SELECT 'TRIGGER', trigger_name FROM information_schema.triggers WHERE trigger_schema = 'railway'
) x ON x.tipo = o.tipo AND x.nombre = o.nombre
ORDER BY FIELD(o.esperado, 'repositorio', 'antiguo'), o.tipo, o.nombre;

-- 3b) Objetos programados que no están en ninguna de las dos listas.
--     Esperado: 0 filas. Si aparece algo, NO ejecute el script y consulte.
SELECT x.tipo, x.nombre AS objeto_no_previsto
FROM (
  SELECT 'VIEW' tipo, table_name nombre FROM information_schema.views WHERE table_schema = 'railway'
  UNION ALL SELECT routine_type, routine_name FROM information_schema.routines WHERE routine_schema = 'railway'
  UNION ALL SELECT 'TRIGGER', trigger_name FROM information_schema.triggers WHERE trigger_schema = 'railway'
) x
WHERE x.nombre NOT IN ('vw_stock_variantes','vw_pedidos_resumen','vw_kardex','vw_ingresos_detalle',
                       'vw_ventas_diarias','vw_ventas_por_modelo','fn_calcular_precio_linea','sp_crear_pedido',
                       'sp_agregar_linea_pedido','sp_registrar_devolucion','sp_cancelar_pedido',
                       'trg_detalle_ingreso_ai','trg_detalle_pedido_bi','trg_detalle_pedido_ai',
                       'vw_kardex_movimientos','vw_stock_bajo_minimo','vw_ventas_por_categoria',
                       'fn_calcular_total_pedido','sp_agregar_variante_ingreso','sp_agregar_variante_pedido',
                       'sp_cambiar_estado_pedido','sp_completar_ingreso','sp_registrar_ingreso',
                       'trg_registrar_entrada_ingreso');

-- 3c) Permisos (GRANT EXECUTE) sobre rutinas de `railway`.
--     DROP PROCEDURE/FUNCTION borra también los GRANT de esa rutina (ver la
--     nota de INSTALL.md). Esperado: 0 filas (en Railway la app usa la cuenta
--     de Railway, sin GRANT por rutina). Si aparecen filas, anótelas ANTES
--     de sincronizar para volver a otorgarlas después.
SELECT user, host, routine_name, routine_type, proc_priv
  FROM mysql.procs_priv
 WHERE db = 'railway';

-- 4) Versión de los objetos que usa la aplicación -------------------------------
--    vw_pedidos_resumen del repositorio tiene 12 columnas, entre ellas
--    cliente_id, vendedor y pares_totales (las usa /pedidos y el filtro RF14).
--    La versión antigua tiene 8 columnas y le faltan esas tres.
SELECT COUNT(*) AS columnas_vw_pedidos_resumen,
       SUM(column_name IN ('cliente_id','vendedor','pares_totales')) AS columnas_que_usa_la_app_de_3
  FROM information_schema.columns
 WHERE table_schema = 'railway' AND table_name = 'vw_pedidos_resumen';

SELECT routine_name,
       CASE routine_name
         WHEN 'sp_crear_pedido'         THEN routine_definition LIKE '%usuario activo%'
         WHEN 'sp_agregar_linea_pedido' THEN routine_definition LIKE '%FOR UPDATE%'
         WHEN 'sp_registrar_devolucion' THEN routine_definition LIKE '%FOR UPDATE%'
         WHEN 'sp_cancelar_pedido'      THEN routine_definition LIKE '%cancelacion%'
       END AS es_version_repositorio
  FROM information_schema.routines
 WHERE routine_schema = 'railway'
   AND routine_name IN ('sp_crear_pedido','sp_agregar_linea_pedido','sp_registrar_devolucion','sp_cancelar_pedido')
 ORDER BY routine_name;

SELECT trigger_name, action_statement LIKE '%FOR UPDATE%' AS es_version_repositorio_lote5
  FROM information_schema.triggers
 WHERE trigger_schema = 'railway' AND trigger_name = 'trg_detalle_pedido_bi';

-- 5) Veredicto ---------------------------------------------------------------------
SELECT CASE
         WHEN repo = 14 AND antiguos = 0 AND cols = 3 AND sp_ok = 1 THEN 'IGUAL AL REPOSITORIO'
         WHEN repo = 13 AND antiguos = 10 AND cols = 0 AND sp_ok = 0 THEN 'ESTADO ANTERIOR (dump local): falta sincronizar'
         ELSE 'MIXTO: no continuar, revisar los puntos 3 y 4'
       END AS veredicto, repo AS objetos_repositorio_de_14, antiguos AS objetos_antiguos_de_10
FROM (
  SELECT
    (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'railway' AND table_name IN
        ('vw_stock_variantes','vw_pedidos_resumen','vw_kardex','vw_ingresos_detalle','vw_ventas_diarias','vw_ventas_por_modelo'))
    + (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_name IN
        ('fn_calcular_precio_linea','sp_crear_pedido','sp_agregar_linea_pedido','sp_registrar_devolucion','sp_cancelar_pedido'))
    + (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'railway' AND trigger_name IN
        ('trg_detalle_ingreso_ai','trg_detalle_pedido_bi','trg_detalle_pedido_ai')) AS repo,
    (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'railway' AND table_name IN
        ('vw_kardex_movimientos','vw_stock_bajo_minimo','vw_ventas_por_categoria'))
    + (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_name IN
        ('fn_calcular_total_pedido','sp_agregar_variante_ingreso','sp_agregar_variante_pedido',
         'sp_cambiar_estado_pedido','sp_completar_ingreso','sp_registrar_ingreso'))
    + (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'railway' AND trigger_name =
        'trg_registrar_entrada_ingreso') AS antiguos,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'railway' AND table_name = 'vw_pedidos_resumen'
        AND column_name IN ('cliente_id','vendedor','pares_totales')) AS cols,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_name = 'sp_crear_pedido'
        AND routine_definition LIKE '%usuario activo%') AS sp_ok
) t;

-- 6) Filas por tabla (los DATOS no deben cambiar) -------------------------------
--    Anote estos números ANTES y compárelos DESPUÉS: deben ser idénticos.
SELECT 'categoria' tabla, COUNT(*) filas FROM categoria UNION ALL
SELECT 'cliente', COUNT(*) FROM cliente UNION ALL
SELECT 'cliente_telefono', COUNT(*) FROM cliente_telefono UNION ALL
SELECT 'color', COUNT(*) FROM color UNION ALL
SELECT 'detalle_ingreso', COUNT(*) FROM detalle_ingreso UNION ALL
SELECT 'detalle_pedido', COUNT(*) FROM detalle_pedido UNION ALL
SELECT 'empleado', COUNT(*) FROM empleado UNION ALL
SELECT 'empleado_telefono', COUNT(*) FROM empleado_telefono UNION ALL
SELECT 'furgon', COUNT(*) FROM furgon UNION ALL
SELECT 'ingreso_mercaderia', COUNT(*) FROM ingreso_mercaderia UNION ALL
SELECT 'movimiento_stock', COUNT(*) FROM movimiento_stock UNION ALL
SELECT 'pedido', COUNT(*) FROM pedido UNION ALL
SELECT 'presentacion_venta', COUNT(*) FROM presentacion_venta UNION ALL
SELECT 'producto', COUNT(*) FROM producto UNION ALL
SELECT 'rol', COUNT(*) FROM rol UNION ALL
SELECT 'talla', COUNT(*) FROM talla UNION ALL
SELECT 'tipo_cliente', COUNT(*) FROM tipo_cliente UNION ALL
SELECT 'usuario', COUNT(*) FROM usuario UNION ALL
SELECT 'variante_producto', COUNT(*) FROM variante_producto;

-- 7) Consistencia stock = suma del kardex (misma regla que CP4-07) --------------
--    Esperado: 0 filas, antes y después.
SELECT v.variante_id, v.sku, v.stock_actual, COALESCE(SUM(k.efecto_stock), 0) AS segun_kardex
  FROM variante_producto v
  LEFT JOIN vw_kardex k ON k.variante_id = v.variante_id
 GROUP BY v.variante_id, v.sku, v.stock_actual
HAVING v.stock_actual <> COALESCE(SUM(k.efecto_stock), 0);

-- 8) La consulta del filtro "Historial por cliente" (RF14) ----------------------
--    ANTES: falla con "Error Code: 1054. Unknown column 'cliente_id' in
--           'field list'" (es lo
--           esperado; Workbench muestra el error y continúa si se ejecuta
--           todo el archivo, porque es la última sentencia).
--    DESPUÉS: devuelve filas (o 0 filas si no hay pedidos) sin error.
SELECT pedido_id, cliente_id, nombre_cliente, vendedor, pares_totales, total_pedido, estado
  FROM vw_pedidos_resumen
 WHERE cliente_id = (SELECT MIN(cliente_id) FROM cliente)
 ORDER BY pedido_id DESC
 LIMIT 5;

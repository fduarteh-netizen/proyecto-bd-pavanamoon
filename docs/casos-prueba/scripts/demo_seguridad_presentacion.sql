-- =============================================================================
-- Archivo:      demo_seguridad_presentacion.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Guion SQL para PRESENTAR al catedrático los niveles de
--               seguridad/acceso de la BD (Entrega 3, criterio "Seguridad:
--               3 roles en BD" y "roles BD OK" de la revisión funcional).
--               Solo CONSULTA el diccionario de MySQL: no crea ni modifica
--               nada. Ejecutar como root en MySQL Workbench, bloque por bloque
--               (Ctrl+Enter sobre cada consulta), o completo con:
--                   mysql -t -u root -p < docs/casos-prueba/scripts/demo_seguridad_presentacion.sql
-- Dependencias: sql/security/01_roles_privilegios.sql ya ejecutado
-- Estándar:     S2, S3
-- =============================================================================

USE pavanamoon;

-- -----------------------------------------------------------------------------
-- PASO 1. ¿Existen los roles y los usuarios?
--   En MySQL 8 un rol es una cuenta bloqueada (account_locked = Y): no puede
--   iniciar sesión, solo agrupa privilegios. Los usuarios pvm_* sí inician sesión.
-- -----------------------------------------------------------------------------
SELECT user                                      AS cuenta,
       host,
       IF(account_locked = 'Y', 'ROL', 'USUARIO') AS tipo
FROM mysql.user
WHERE user IN ('rol_administrador', 'rol_bodeguero', 'rol_vendedor',
               'pvm_admin', 'pvm_bodega', 'pvm_ventas')
ORDER BY tipo, cuenta;

-- -----------------------------------------------------------------------------
-- PASO 2. ¿Qué rol tiene cada usuario? (y si se activa solo al iniciar sesión)
-- -----------------------------------------------------------------------------
SELECT e.TO_USER                     AS usuario_mysql,
       e.FROM_USER                   AS rol_asignado,
       IF(d.USER IS NULL, 'NO', 'SÍ') AS rol_activo_por_defecto
FROM mysql.role_edges e
LEFT JOIN mysql.default_roles d
       ON d.USER = e.TO_USER AND d.DEFAULT_ROLE_USER = e.FROM_USER
WHERE e.TO_USER LIKE 'pvm%'
ORDER BY usuario_mysql;

-- -----------------------------------------------------------------------------
-- PASO 3. Matriz de privilegios por tabla/vista y por rol (mínimo privilegio)
--   El administrador tiene ALL PRIVILEGES a nivel de esquema (ver PASO 5),
--   por eso aquí se muestra como "ALL (esquema)".
--   "—" significa que el rol NO puede ni leer ese objeto.
-- -----------------------------------------------------------------------------
SELECT t.TABLE_NAME AS objeto,
       IF(t.TABLE_TYPE = 'VIEW', 'vista', 'tabla') AS tipo,
       'ALL (esquema)' AS rol_administrador,
       COALESCE(MAX(CASE WHEN p.User = 'rol_bodeguero' THEN REPLACE(p.Table_priv, ',', ', ') END), '—') AS rol_bodeguero,
       COALESCE(MAX(CASE WHEN p.User = 'rol_vendedor'  THEN REPLACE(p.Table_priv, ',', ', ') END), '—') AS rol_vendedor
FROM information_schema.TABLES t
LEFT JOIN mysql.tables_priv p
       ON p.Db = t.TABLE_SCHEMA AND p.Table_name = t.TABLE_NAME
WHERE t.TABLE_SCHEMA = 'pavanamoon'
GROUP BY t.TABLE_NAME, t.TABLE_TYPE
ORDER BY tipo, objeto;

-- -----------------------------------------------------------------------------
-- PASO 4. Rutinas que cada rol puede ejecutar (EXECUTE)
--   El vendedor crea pedidos SOLO por procedimiento: no tiene INSERT directo
--   sobre pedido/detalle_pedido, así no puede escribir precios a mano.
-- -----------------------------------------------------------------------------
SELECT User AS rol, Routine_type AS tipo, Routine_name AS rutina, Proc_priv AS privilegio
FROM mysql.procs_priv
WHERE Db = 'pavanamoon'
ORDER BY rol, rutina;

-- -----------------------------------------------------------------------------
-- PASO 5. Detalle oficial con SHOW GRANTS (lo que MySQL realmente aplica)
-- -----------------------------------------------------------------------------
SHOW GRANTS FOR 'rol_administrador';
SHOW GRANTS FOR 'rol_bodeguero';
SHOW GRANTS FOR 'rol_vendedor';
-- Un usuario con su rol expandido:
SHOW GRANTS FOR 'pvm_ventas'@'%' USING 'rol_vendedor';

-- -----------------------------------------------------------------------------
-- PASO 6. Nadie salvo el administrador puede ver la tabla usuario (hash bcrypt)
--   Debe devolver 0 (ni bodeguero ni vendedor tienen privilegio sobre ella).
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS roles_no_admin_con_acceso_a_usuario
FROM mysql.tables_priv
WHERE Db = 'pavanamoon' AND Table_name = 'usuario';

-- -----------------------------------------------------------------------------
-- PASO 7 (en vivo, fuera de este script). Conectarse como cada usuario y
-- demostrar un permitido y un denegado. Ver docs/entrega-3/PRESENTACION_SEGURIDAD.md
-- o ejecutar: bash docs/casos-prueba/scripts/entrega3_casos_seguridad.sh
-- -----------------------------------------------------------------------------

-- =============================================================================
-- Archivo:      01_roles_privilegios.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Seguridad a nivel de base de datos (Sección 5, req. 6):
--               3 roles de MySQL 8 con privilegios diferenciados según el
--               principio de mínimo privilegio, alineados con los roles de la
--               aplicación (tabla rol: administrador, bodeguero, vendedor).
--
--   rol_administrador : control total del esquema pavanamoon.
--   rol_bodeguero     : inventario y recepción de mercadería. Lee catálogos y
--                       productos; inserta/actualiza variantes, furgones e
--                       ingresos. NO ve clientes, pedidos ni la tabla usuario.
--   rol_vendedor      : clientes y pedidos. Lee productos y stock (vista);
--                       crea pedidos SOLO a través de los procedimientos
--                       (EXECUTE), así no puede escribir precios a mano ni
--                       saltarse las validaciones. NO puede borrar nada ni
--                       tocar inventario, furgones o ingresos.
--
--   Ningún rol distinto de administrador puede leer la tabla usuario
--   (contiene los hash de contraseña).
--
--   Relación con la app web: la app se conecta con un único usuario técnico
--   (pavanamoon_app, ver INSTALL.md) y aplica el control por rol en su propio
--   middleware (RF21, web/src/middleware/auth.js). Los usuarios de MySQL de
--   este script son para acceso directo a la BD (Workbench, reportes,
--   soporte) y demuestran la segunda capa de seguridad.
--
-- Contraseñas: las de abajo son PLACEHOLDERS de desarrollo local (R6).
--              Cambiarlas con ALTER USER antes de cualquier despliegue.
-- Dependencias: sql/ddl/*, sql/views/*, sql/procedures/*
-- Estándar:     S2, S3, R6
-- =============================================================================

USE pavanamoon;

-- ---------------------------------------------------------------------------
-- 1) Roles
-- ---------------------------------------------------------------------------
DROP ROLE IF EXISTS 'rol_administrador', 'rol_bodeguero', 'rol_vendedor';
CREATE ROLE 'rol_administrador', 'rol_bodeguero', 'rol_vendedor';

-- ---------------------------------------------------------------------------
-- 2) Privilegios: ADMINISTRADOR
-- ---------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON pavanamoon.* TO 'rol_administrador';

-- ---------------------------------------------------------------------------
-- 3) Privilegios: BODEGUERO (inventario / recepción)
-- ---------------------------------------------------------------------------
GRANT SELECT ON pavanamoon.categoria          TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.talla              TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.color              TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.producto           TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.empleado           TO 'rol_bodeguero';
GRANT SELECT, INSERT, UPDATE ON pavanamoon.variante_producto  TO 'rol_bodeguero';
GRANT SELECT, INSERT, UPDATE ON pavanamoon.furgon             TO 'rol_bodeguero';
GRANT SELECT, INSERT, UPDATE ON pavanamoon.ingreso_mercaderia TO 'rol_bodeguero';
GRANT SELECT, INSERT         ON pavanamoon.detalle_ingreso    TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.movimiento_stock    TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.vw_stock_variantes  TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.vw_kardex           TO 'rol_bodeguero';
GRANT SELECT ON pavanamoon.vw_ingresos_detalle TO 'rol_bodeguero';

-- ---------------------------------------------------------------------------
-- 4) Privilegios: VENDEDOR (clientes / pedidos)
-- ---------------------------------------------------------------------------
GRANT SELECT ON pavanamoon.categoria          TO 'rol_vendedor';
GRANT SELECT ON pavanamoon.tipo_cliente       TO 'rol_vendedor';
GRANT SELECT ON pavanamoon.presentacion_venta TO 'rol_vendedor';
GRANT SELECT ON pavanamoon.producto           TO 'rol_vendedor';
GRANT SELECT ON pavanamoon.vw_stock_variantes TO 'rol_vendedor';
GRANT SELECT, INSERT, UPDATE ON pavanamoon.cliente          TO 'rol_vendedor';
GRANT SELECT, INSERT, UPDATE ON pavanamoon.cliente_telefono TO 'rol_vendedor';
GRANT SELECT ON pavanamoon.pedido             TO 'rol_vendedor';
GRANT SELECT ON pavanamoon.detalle_pedido     TO 'rol_vendedor';
GRANT SELECT ON pavanamoon.vw_pedidos_resumen TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE pavanamoon.sp_crear_pedido         TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE pavanamoon.sp_agregar_linea_pedido TO 'rol_vendedor';
GRANT EXECUTE ON PROCEDURE pavanamoon.sp_registrar_devolucion TO 'rol_vendedor';
GRANT EXECUTE ON FUNCTION  pavanamoon.fn_calcular_precio_linea TO 'rol_vendedor';

-- ---------------------------------------------------------------------------
-- 5) Usuarios de MySQL (uno por rol) -- contraseñas PLACEHOLDER (R6)
-- ---------------------------------------------------------------------------
DROP USER IF EXISTS 'pvm_admin'@'%', 'pvm_bodega'@'%', 'pvm_ventas'@'%';

CREATE USER 'pvm_admin'@'%'  IDENTIFIED BY 'Cambiar#Admin2026';
CREATE USER 'pvm_bodega'@'%' IDENTIFIED BY 'Cambiar#Bodega2026';
CREATE USER 'pvm_ventas'@'%' IDENTIFIED BY 'Cambiar#Ventas2026';

GRANT 'rol_administrador' TO 'pvm_admin'@'%';
GRANT 'rol_bodeguero'     TO 'pvm_bodega'@'%';
GRANT 'rol_vendedor'      TO 'pvm_ventas'@'%';

-- El rol queda activo automáticamente al iniciar sesión.
SET DEFAULT ROLE ALL TO 'pvm_admin'@'%', 'pvm_bodega'@'%', 'pvm_ventas'@'%';

FLUSH PRIVILEGES;

-- =============================================================================
-- Archivo:      02_privilegios_entrega4.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Privilegios sobre los objetos agregados en la Entrega 4.
--               Se ejecuta DESPUÉS de 01_roles_privilegios.sql (que crea los
--               roles). Se separa en su propio archivo para que el cambio de
--               seguridad quede trazable por entrega.
--   rol_vendedor : puede cancelar pedidos, pero solo a través del
--                  procedimiento (que reintegra stock y deja kardex); sigue
--                  sin permiso de UPDATE directo sobre pedido.
--   Reportes (vw_ventas_diarias, vw_ventas_por_modelo): solo administrador,
--                  igual que el módulo Reportes de la app (permisos.js).
--                  rol_administrador ya tiene ALL PRIVILEGES sobre
--                  pavanamoon.*, por lo que las incluye sin GRANT adicional.
--                  Bodeguero y vendedor NO reciben acceso: contienen montos
--                  de venta consolidados.
-- Dependencias: security/01_roles_privilegios.sql,
--               procedures/05_sp_cancelar_pedido.sql
-- Estándar:     S2, S3
-- =============================================================================

USE pavanamoon;

GRANT EXECUTE ON PROCEDURE pavanamoon.sp_cancelar_pedido TO 'rol_vendedor';

FLUSH PRIVILEGES;

-- =============================================================================
-- Archivo:      02_sp_crear_pedido.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Procedimiento sp_crear_pedido(cliente, empleado, OUT pedido_id)
-- Regla de negocio (RF11, RD04):
--   Todo pedido nace en estado 'pendiente', con total 0, asociado a un
--   cliente y a un vendedor con usuario ACTIVO. Centralizar la creación en
--   la BD impide pedidos "huérfanos" o hechos por empleados dados de baja.
--   No abre transacción propia: la app lo invoca dentro de su transacción
--   junto con sp_agregar_linea_pedido (todo o nada).
-- Dependencias: pedido, cliente, usuario
-- Estándar:     S2, S3, S6
-- =============================================================================

USE pavanamoon;

DROP PROCEDURE IF EXISTS sp_crear_pedido;

DELIMITER $$

CREATE PROCEDURE sp_crear_pedido(
    IN  p_cliente_id  INT,
    IN  p_empleado_id INT,
    OUT p_pedido_id   INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cliente WHERE cliente_id = p_cliente_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente indicado no existe.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM usuario
                    WHERE empleado_id = p_empleado_id AND estado = 'activo') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El vendedor no tiene un usuario activo.';
    END IF;

    INSERT INTO pedido (cliente_id, empleado_id, total_pedido, estado)
    VALUES (p_cliente_id, p_empleado_id, 0, 'pendiente');

    SET p_pedido_id = LAST_INSERT_ID();
END$$

DELIMITER ;

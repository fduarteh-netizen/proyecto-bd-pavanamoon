-- =============================================================================
-- Archivo:      03_tablas_personas.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  EMPLEADO, USUARIO, CLIENTE. Incluye EMPLEADO_TELEFONO y
--               CLIENTE_TELEFONO, que resuelven en el modelo relacional los
--               atributos multivaluados "telefono" marcados con borde grueso
--               en el diagrama ER vigente -> ver justificación de 1FN en
--               docs/entrega-2/ENTREGA2_DISENO_LOGICO.md.
-- Dependencias: 01_crear_base_datos.sql, 02_tablas_catalogo.sql (rol, tipo_cliente)
-- Estándar:     S1, S4, RD08 (username único), RD09 (un usuario -> un rol)
-- =============================================================================

USE pavanamoon;

-- EMPLEADO: personal de la empresa. El diagrama ER vigente usa un único
-- atributo "nombres_apellidos" (no separado en nombres/apellidos).
CREATE TABLE empleado (
    empleado_id       INT AUTO_INCREMENT PRIMARY KEY,
    nombres_apellidos VARCHAR(150) NOT NULL,
    dpi               CHAR(13)     NOT NULL,
    CONSTRAINT uq_empleado_dpi UNIQUE (dpi)
) ENGINE=InnoDB;

-- EMPLEADO_TELEFONO: resuelve el atributo multivaluado "telefono" de EMPLEADO (1FN).
CREATE TABLE empleado_telefono (
    empleado_id  INT         NOT NULL,
    telefono     VARCHAR(20) NOT NULL,
    PRIMARY KEY (empleado_id, telefono),
    CONSTRAINT fk_empleado_telefono_empleado
        FOREIGN KEY (empleado_id) REFERENCES empleado(empleado_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- USUARIO: credenciales de acceso al sistema (RF20, RF21).
-- Relación "posee" EMPLEADO(0,1) - USUARIO(1,1): todo usuario pertenece a
-- exactamente un empleado, y un empleado tiene como máximo un usuario
-- (empleado_id UNIQUE implementa el lado (1,1) hacia USUARIO).
CREATE TABLE usuario (
    usuario_id      INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(40)  NOT NULL,
    password_hash   VARCHAR(255) NOT NULL COMMENT 'Hash bcrypt, nunca texto plano',
    estado          ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    fecha_creacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rol_id          INT NOT NULL,
    empleado_id     INT NOT NULL,
    CONSTRAINT uq_usuario_username UNIQUE (username),
    CONSTRAINT uq_usuario_empleado UNIQUE (empleado_id),
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (rol_id) REFERENCES rol(rol_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_empleado
        FOREIGN KEY (empleado_id) REFERENCES empleado(empleado_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CLIENTE: clientes individuales (B2C) y mayoristas (B2B), clasificados por
-- el catálogo TIPO_CLIENTE (relación "clasifica", TIPO_CLIENTE(1,N)-CLIENTE(1,1)).
-- NOTA (corrección documentada, ver ENTREGA2_DISENO_LOGICO.md §1.2): el
-- diagrama ER vigente no incluye un atributo de nombre para el cliente; se
-- agregó "nombre_cliente" porque es indispensable para operar el negocio
-- (identificar al cliente en pantalla, en pedidos y reportes).
CREATE TABLE cliente (
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY,
    tipo_cliente_id INT NOT NULL,
    nombre_cliente  VARCHAR(150) NOT NULL COMMENT 'Agregado: no estaba en el ER, ver nota de correccion',
    nit             VARCHAR(15)  NOT NULL,
    CONSTRAINT uq_cliente_nit UNIQUE (nit),
    CONSTRAINT fk_cliente_tipo_cliente
        FOREIGN KEY (tipo_cliente_id) REFERENCES tipo_cliente(tipo_cliente_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CLIENTE_TELEFONO: resuelve el atributo multivaluado "telefono" de CLIENTE (1FN).
CREATE TABLE cliente_telefono (
    cliente_id  INT         NOT NULL,
    telefono    VARCHAR(20) NOT NULL,
    PRIMARY KEY (cliente_id, telefono),
    CONSTRAINT fk_cliente_telefono_cliente
        FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

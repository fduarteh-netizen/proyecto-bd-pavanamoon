-- =============================================================================
-- Archivo:      02_tablas_catalogo.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Tablas catálogo sin dependencias entre sí: ROL, CATEGORIA
--               (por edad: nino/juvenil/adulto), TALLA, COLOR, TIPO_CLIENTE
--               (individual/mayorista) y PRESENTACION_VENTA (forma de venta:
--               UNIDAD, CAJA, etc. -- sin precio propio, ver 04/05).
--               Fuente de verdad: docs/diagramas/Pavanamoon_er_chen_corregido.drawio
--               (modelo vigente, ver nota de corrección en
--               docs/entrega-2/ENTREGA2_DISENO_LOGICO.md, Sección 1).
-- Dependencias: 01_crear_base_datos.sql
-- Estándar:     S1 (snake_case), S4, RD01 (todo producto asociado a categoría)
-- =============================================================================

USE pavanamoon;

-- ROL: catálogo de roles de seguridad (RF19). Mínimo 3 roles (Sección 5, req. 6).
CREATE TABLE rol (
    rol_id        INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol    VARCHAR(50)  NOT NULL,
    descripcion   VARCHAR(255) NULL,
    CONSTRAINT uq_rol_nombre UNIQUE (nombre_rol)
) ENGINE=InnoDB;

-- CATEGORIA: clasificación de producto por edad (README del proyecto).
CREATE TABLE categoria (
    categoria_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria  VARCHAR(50) NOT NULL,
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre_categoria),
    CONSTRAINT ck_categoria_nombre CHECK (nombre_categoria IN ('nino', 'juvenil', 'adulto'))
) ENGINE=InnoDB;

-- TALLA: catálogo de tallas disponibles para variantes de producto.
CREATE TABLE talla (
    talla_id     INT AUTO_INCREMENT PRIMARY KEY,
    valor_talla  VARCHAR(10) NOT NULL,
    CONSTRAINT uq_talla_valor UNIQUE (valor_talla)
) ENGINE=InnoDB;

-- COLOR: catálogo de colores disponibles para variantes de producto.
CREATE TABLE color (
    color_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre_color  VARCHAR(40) NOT NULL,
    CONSTRAINT uq_color_nombre UNIQUE (nombre_color)
) ENGINE=InnoDB;

-- TIPO_CLIENTE: segmento comercial (individual / mayorista). En el diagrama
-- ER vigente reemplaza al ENUM "tipo_cliente" usado en el borrador de texto
-- de la Entrega 1 -- ahora es un catálogo propio (permite agregar nuevos
-- segmentos sin alterar el esquema, y centraliza el % de descuento).
CREATE TABLE tipo_cliente (
    tipo_cliente_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(50)  NOT NULL,
    descripcion      VARCHAR(255) NULL,
    CONSTRAINT uq_tipo_cliente_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- PRESENTACION_VENTA: forma en que se agrupan los pares para la venta
-- (UNIDAD, CAJA, etc.). NO tiene columna de precio: el precio de venta vive
-- una sola vez en PRODUCTO.precio_venta (precio por par) para evitar
-- contradicciones entre dos fuentes de precio (ver
-- ENTREGA2_DISENO_LOGICO.md, Sección 1.2, punto 7). El precio final de una
-- línea de pedido (detalle_pedido.precio_unitario) se calcula en la
-- aplicación a partir de producto.precio_venta * variante y la cantidad de
-- pares de la presentación elegida, y puede reflejar el descuento del
-- tipo_cliente (individual/mayorista) del cliente que compra -- MAYORISTA
-- es un tipo_cliente, nunca una presentación de venta.
CREATE TABLE presentacion_venta (
    presentacion_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(50) NOT NULL,
    cantidad_pares   INT         NOT NULL,
    estado           ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    CONSTRAINT uq_presentacion_nombre UNIQUE (nombre),
    CONSTRAINT ck_presentacion_cantidad CHECK (cantidad_pares > 0)
) ENGINE=InnoDB;

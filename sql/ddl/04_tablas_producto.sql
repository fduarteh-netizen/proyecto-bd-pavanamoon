-- =============================================================================
-- Archivo:      04_tablas_producto.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Catálogo de productos (marca propia Pavanamoon: no existe
--               columna "marca", todo el calzado es de la misma marca) y sus
--               variantes por talla/color, cada una con su propio stock.
--               Incluye FURGON, que representa el medio de transporte de
--               cada recepción de mercadería (reemplaza al concepto de
--               PROVEEDOR del borrador de texto original de la Entrega 1;
--               ver nota de corrección en ENTREGA2_DISENO_LOGICO.md §1.1).
-- Dependencias: 02_tablas_catalogo.sql (categoria, talla, color)
-- Estándar:     S1, S4, RD02 (unicidad producto+talla+color),
--               RD03 (stock nunca negativo)
-- =============================================================================

USE pavanamoon;

-- PRODUCTO: modelo de calzado de fútbol de la marca propia Pavanamoon.
CREATE TABLE producto (
    producto_id    INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id   INT NOT NULL,
    modelo         VARCHAR(100)  NOT NULL,
    tipo_suela     ENUM('hule', 'flex', 'tpu') NOT NULL,
    precio_venta   DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (categoria_id) REFERENCES categoria(categoria_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_producto_precio CHECK (precio_venta > 0)
) ENGINE=InnoDB;

-- VARIANTE_PRODUCTO: combinación única producto + talla + color, con su
-- propio stock. No almacena tipo_suela/categoria (evita dependencia
-- transitiva; ver 3FN en ENTREGA2_DISENO_LOGICO.md, Sección 3).
CREATE TABLE variante_producto (
    variante_id    INT AUTO_INCREMENT PRIMARY KEY,
    producto_id    INT NOT NULL,
    talla_id       INT NOT NULL,
    color_id       INT NOT NULL,
    sku            VARCHAR(40) NOT NULL COMMENT 'Derivado de producto+talla+color, generado en la app',
    stock_actual   INT NOT NULL DEFAULT 0,
    stock_minimo   INT NOT NULL DEFAULT 5,
    CONSTRAINT uq_variante_sku UNIQUE (sku),
    CONSTRAINT uq_variante_combinacion UNIQUE (producto_id, talla_id, color_id),
    CONSTRAINT fk_variante_producto
        FOREIGN KEY (producto_id) REFERENCES producto(producto_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_variante_talla
        FOREIGN KEY (talla_id) REFERENCES talla(talla_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_variante_color
        FOREIGN KEY (color_id) REFERENCES color(color_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_variante_stock_actual CHECK (stock_actual >= 0),
    CONSTRAINT ck_variante_stock_minimo CHECK (stock_minimo >= 0)
) ENGINE=InnoDB;

-- FURGON: cada recepción de mercadería llega en un furgón identificado.
CREATE TABLE furgon (
    furgon_id      INT AUTO_INCREMENT PRIMARY KEY,
    numero_furgon  VARCHAR(30) NOT NULL,
    fecha_llegada  DATE NOT NULL,
    procedencia    VARCHAR(100) NULL,
    transportista  VARCHAR(100) NULL,
    estado         ENUM('en_transito', 'recibido', 'cancelado') NOT NULL DEFAULT 'en_transito',
    CONSTRAINT uq_furgon_numero UNIQUE (numero_furgon)
) ENGINE=InnoDB;

-- =============================================================================
-- Archivo:      05_tablas_transacciones.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Tablas transaccionales del modelo vigente (según
--               Pavanamoon_er_chen_corregido.drawio):
--                 - INGRESO_MERCADERIA / DETALLE_INGRESO: registra la
--                   recepción de mercadería; un FURGON puede corresponder a
--                   varios ingresos (relación "transporta" FURGON(0,N)-
--                   INGRESO_MERCADERIA(1,1), ya NO es 1:1).
--                 - PEDIDO / DETALLE_PEDIDO: resuelve la relación N:M
--                   Pedido-Variante con llave primaria compuesta
--                   (pedido_id, variante_id). Cada línea además se vende en
--                   una PRESENTACION_VENTA concreta (relación "se_utiliza_en").
--                 - MOVIMIENTO_STOCK: kardex auditable (RF15-RF18).
--               subtotal se calcula con columnas generadas (STORED) para
--               evitar redundancia de datos calculables (estándar S7).
-- Dependencias: 03_tablas_personas.sql (empleado, cliente),
--               04_tablas_producto.sql (variante_producto, furgon),
--               02_tablas_catalogo.sql (presentacion_venta)
-- Estándar:     S1, S4, S7, RD06, RD10, RD11
-- =============================================================================

USE pavanamoon;

-- INGRESO_MERCADERIA: recepción de mercadería a bodega, registrada por un
-- empleado (relación "registra"). Relación "transporta": FURGON(0,N)-
-- INGRESO_MERCADERIA(1,1) -> un furgón puede corresponder a varios ingresos
-- (ej. descargas parciales), y cada ingreso pertenece a exactamente un
-- furgón -> furgon_id es FK simple (NO UNIQUE).
CREATE TABLE ingreso_mercaderia (
    ingreso_id       INT AUTO_INCREMENT PRIMARY KEY,
    furgon_id        INT NOT NULL,
    empleado_id      INT NOT NULL,
    fecha_ingreso    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bodega_destino   VARCHAR(60) NULL,
    estado           ENUM('pendiente', 'completado', 'cancelado') NOT NULL DEFAULT 'completado',
    CONSTRAINT fk_ingreso_furgon
        FOREIGN KEY (furgon_id) REFERENCES furgon(furgon_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ingreso_empleado
        FOREIGN KEY (empleado_id) REFERENCES empleado(empleado_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- DETALLE_INGRESO: entidad asociativa que resuelve INGRESO_MERCADERIA (N,M)
-- VARIANTE_PRODUCTO. Llave primaria compuesta, tal como se definió en el
-- diagrama ER vigente.
CREATE TABLE detalle_ingreso (
    ingreso_id      INT NOT NULL,
    variante_id     INT NOT NULL,
    cantidad        INT NOT NULL,
    costo_unitario  DECIMAL(10,2) NOT NULL,
    subtotal        DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * costo_unitario) STORED,
    PRIMARY KEY (ingreso_id, variante_id),
    CONSTRAINT fk_detalle_ingreso_ingreso
        FOREIGN KEY (ingreso_id) REFERENCES ingreso_mercaderia(ingreso_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_ingreso_variante
        FOREIGN KEY (variante_id) REFERENCES variante_producto(variante_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_detalle_ingreso_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_ingreso_costo CHECK (costo_unitario > 0)
) ENGINE=InnoDB;

-- PEDIDO: venta a un cliente, atendida por un empleado (RF11).
-- NOTA (adición justificada, ver ENTREGA2_DISENO_LOGICO.md §1.2): se agregó
-- la columna "estado" (no dibujada en el ER) porque es indispensable para
-- distinguir pedidos pendientes/completados/cancelados en la operación diaria.
CREATE TABLE pedido (
    pedido_id      INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id     INT NOT NULL,
    empleado_id    INT NOT NULL,
    fecha_pedido   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_pedido   DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT 'Derivado; se recalcula por procedimiento en Entrega 3',
    estado         ENUM('pendiente', 'completado', 'cancelado') NOT NULL DEFAULT 'pendiente' COMMENT 'Agregado: no estaba en el ER, ver nota de correccion',
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_empleado
        FOREIGN KEY (empleado_id) REFERENCES empleado(empleado_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_pedido_total CHECK (total_pedido >= 0)
) ENGINE=InnoDB;

-- DETALLE_PEDIDO: entidad asociativa que resuelve PEDIDO (N,M)
-- VARIANTE_PRODUCTO, con llave primaria compuesta (pedido_id, variante_id)
-- tal como la define el diagrama ER corregido: una misma variante aparece
-- como máximo una vez por pedido. Además referencia la PRESENTACION_VENTA
-- en la que se vendió esa línea (relación "se_utiliza_en"), lo que permite
-- vender la misma variante por unidad o al mayoreo sin duplicar catálogo.
CREATE TABLE detalle_pedido (
    pedido_id          INT NOT NULL,
    variante_id        INT NOT NULL,
    presentacion_id    INT NOT NULL,
    cantidad           INT NOT NULL,
    precio_unitario    DECIMAL(10,2) NOT NULL,
    subtotal           DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    PRIMARY KEY (pedido_id, variante_id),
    CONSTRAINT fk_detalle_pedido_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido(pedido_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_pedido_variante
        FOREIGN KEY (variante_id) REFERENCES variante_producto(variante_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_pedido_presentacion
        FOREIGN KEY (presentacion_id) REFERENCES presentacion_venta(presentacion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_detalle_pedido_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_pedido_precio CHECK (precio_unitario > 0)
) ENGINE=InnoDB;

-- MOVIMIENTO_STOCK: kardex auditable de toda entrada/salida/devolución (RF15-RF18).
CREATE TABLE movimiento_stock (
    movimiento_id      INT AUTO_INCREMENT PRIMARY KEY,
    variante_id        INT NOT NULL,
    empleado_id        INT NOT NULL,
    tipo_movimiento    ENUM('entrada', 'salida', 'devolucion_cliente', 'ajuste') NOT NULL,
    cantidad           INT NOT NULL,
    fecha_movimiento   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movimiento_variante
        FOREIGN KEY (variante_id) REFERENCES variante_producto(variante_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_movimiento_empleado
        FOREIGN KEY (empleado_id) REFERENCES empleado(empleado_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_movimiento_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB;

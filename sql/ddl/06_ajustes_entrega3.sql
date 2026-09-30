-- =============================================================================
-- Archivo:      06_ajustes_entrega3.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Ajuste de esquema requerido por la Entrega 3. Agrega
--               tipo_cliente.porcentaje_descuento, necesario para implementar
--               RF13 (descuento diferenciado a mayoristas). El comentario de
--               02_tablas_catalogo.sql ya indicaba que TIPO_CLIENTE centraliza
--               el % de descuento, pero la columna no se había creado. Se
--               agrega con ALTER (en vez de editar 02_) para dejar trazable
--               el cambio por entrega.
-- Dependencias: 02_tablas_catalogo.sql
-- Estándar:     S1, S2, S3, S7 (el descuento vive una sola vez, en el catálogo)
-- =============================================================================

USE pavanamoon;

ALTER TABLE tipo_cliente
    ADD COLUMN porcentaje_descuento DECIMAL(5,2) NOT NULL DEFAULT 0
        COMMENT 'Descuento aplicado al precio de venta (RF13). 0 = sin descuento',
    ADD CONSTRAINT ck_tipo_cliente_descuento
        CHECK (porcentaje_descuento >= 0 AND porcentaje_descuento <= 50);

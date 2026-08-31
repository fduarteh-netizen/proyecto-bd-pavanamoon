-- =============================================================================
-- Archivo:      01_crear_base_datos.sql
-- Autor:        Equipo Pavanamoon (Duarte, Martínez, Pérez, Cabrera)
-- Descripción:  Crea la base de datos del proyecto y fija el motor de
--               almacenamiento por defecto (InnoDB, requerido para poder
--               declarar llaves foráneas con integridad referencial).
-- Dependencias: Ninguna (primer script a ejecutar).
-- Estándar:     S2 (un script, un propósito), S3 (encabezado obligatorio)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS pavanamoon
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE pavanamoon;

SET default_storage_engine = InnoDB;

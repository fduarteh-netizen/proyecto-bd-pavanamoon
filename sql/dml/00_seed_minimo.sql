-- =============================================================================
-- Archivo:      00_seed_minimo.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Datos mínimos necesarios para probar la app web de la
--               Entrega 2 (login + CRUD de Producto y Cliente): 3 roles de
--               seguridad, un empleado administrador con su usuario, y
--               catálogos base (categoría por edad, talla, color, tipo de
--               cliente, presentación de venta) para los formularios.
--               La carga masiva de >=50 registros por tabla se realiza en
--               la Entrega 3 junto con vistas/triggers.
-- Dependencias: 01_crear_base_datos.sql .. 05_tablas_transacciones.sql
-- Estándar:     R6 (contraseña de prueba documentada a propósito para
--               ambiente local; jamás usar en un despliegue real)
-- =============================================================================

USE pavanamoon;

-- Roles de seguridad (RF19, mínimo 3 roles requerido por la guía Sección 5).
INSERT INTO rol (nombre_rol, descripcion) VALUES
    ('administrador', 'Acceso total al sistema: usuarios, catálogos, reportes'),
    ('bodeguero',      'Gestiona inventario, ingresos de mercadería y movimientos de stock'),
    ('vendedor',       'Gestiona clientes y pedidos');

-- Categorías por edad (README del proyecto).
INSERT INTO categoria (nombre_categoria) VALUES ('nino'), ('juvenil'), ('adulto');

-- Tallas base.
INSERT INTO talla (valor_talla) VALUES ('34'), ('36'), ('38'), ('40'), ('42'), ('44');

-- Colores base.
INSERT INTO color (nombre_color) VALUES ('negro'), ('blanco'), ('rojo'), ('azul');

-- Segmentos de cliente.
INSERT INTO tipo_cliente (nombre, descripcion) VALUES
    ('individual', 'Cliente que compra al detalle (B2C)'),
    ('mayorista',  'Comercio o revendedor que compra en volumen (B2B)');

-- Presentaciones de venta: forma en que se agrupan los pares (SIN precio
-- propio -- el precio vive una sola vez en producto.precio_venta; ver nota
-- de consistencia de precio en ENTREGA2_DISENO_LOGICO.md §1.2, punto 7).
-- MAYORISTA es un tipo_cliente (tabla tipo_cliente), no una presentación.
INSERT INTO presentacion_venta (nombre, cantidad_pares) VALUES
    ('unidad', 1),
    ('caja',   12);

-- Empleado administrador y su cuenta de usuario para poder iniciar sesión
-- en la app web de la Entrega 2.
INSERT INTO empleado (nombres_apellidos, dpi) VALUES
    ('Admin Pavanamoon', '1000000000000');

-- Usuario: username = admin / password = Admin#2026 (SOLO para ambiente de
-- pruebas/desarrollo local; cambiar antes de cualquier despliegue real,
-- estándar R6 -- nunca credenciales reales en el repositorio).
INSERT INTO usuario (username, password_hash, estado, rol_id, empleado_id) VALUES
    ('admin',
     '$2b$10$I/GBqsgM0x8l836dem.xIuFUsiT8m4IC61Rpe.8JqhR4vLNQ.H37G',
     'activo',
     (SELECT rol_id FROM rol WHERE nombre_rol = 'administrador'),
     (SELECT empleado_id FROM empleado WHERE dpi = '1000000000000'));

// =============================================================================
// Archivo:      src/models/catalogoModel.js
// Descripción:  Consultas de solo lectura a tablas catálogo, usadas para
//               poblar los <select> de los formularios (ampliado en Entrega 3).
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

/** Lista las categorías (tabla categoria) para los selectores de los formularios. */
async function listarCategorias() {
  const [rows] = await pool.query(
    'SELECT categoria_id, nombre_categoria FROM categoria ORDER BY nombre_categoria'
  );
  return rows;
}

/** Lista los tipos de cliente con su porcentaje de descuento (tabla tipo_cliente). */
async function listarTiposCliente() {
  const [rows] = await pool.query(
    'SELECT tipo_cliente_id, nombre FROM tipo_cliente ORDER BY nombre'
  );
  return rows;
}

/** Lista las tallas (tabla talla) para los selectores. */
async function listarTallas() {
  const [rows] = await pool.query('SELECT talla_id, valor_talla FROM talla ORDER BY CAST(valor_talla AS UNSIGNED)');
  return rows;
}

/** Lista los colores (tabla color) para los selectores. */
async function listarColores() {
  const [rows] = await pool.query('SELECT color_id, nombre_color FROM color ORDER BY nombre_color');
  return rows;
}

/** Lista las presentaciones de venta (unidad, caja…) con sus pares (tabla presentacion_venta). */
async function listarPresentaciones() {
  const [rows] = await pool.query(
    "SELECT presentacion_id, nombre, cantidad_pares FROM presentacion_venta WHERE estado = 'activo' ORDER BY cantidad_pares"
  );
  return rows;
}

/** Lista id y modelo de los productos para los selectores (tabla producto). */
async function listarProductosSimple() {
  const [rows] = await pool.query('SELECT producto_id, modelo FROM producto ORDER BY modelo');
  return rows;
}

/** Lista los clientes con su tipo para el selector de pedidos y el filtro por cliente (cliente + tipo_cliente). */
async function listarClientesSimple() {
  const [rows] = await pool.query(
    `SELECT c.cliente_id, c.nombre_cliente, tc.nombre AS tipo_cliente
       FROM cliente c JOIN tipo_cliente tc ON tc.tipo_cliente_id = c.tipo_cliente_id
      ORDER BY c.nombre_cliente`
  );
  return rows;
}

module.exports = {
  listarCategorias,
  listarTiposCliente,
  listarTallas,
  listarColores,
  listarPresentaciones,
  listarProductosSimple,
  listarClientesSimple,
};

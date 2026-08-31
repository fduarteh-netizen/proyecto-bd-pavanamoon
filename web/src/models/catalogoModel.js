// =============================================================================
// Archivo:      src/models/catalogoModel.js
// Descripción:  Consultas de solo lectura a tablas catálogo, usadas para
//               poblar los <select> de los formularios.
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

async function listarCategorias() {
  const [rows] = await pool.query(
    'SELECT categoria_id, nombre_categoria FROM categoria ORDER BY nombre_categoria'
  );
  return rows;
}

async function listarTiposCliente() {
  const [rows] = await pool.query(
    'SELECT tipo_cliente_id, nombre FROM tipo_cliente ORDER BY nombre'
  );
  return rows;
}

module.exports = { listarCategorias, listarTiposCliente };

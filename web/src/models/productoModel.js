// =============================================================================
// Archivo:      src/models/productoModel.js
// Descripción:  Acceso a datos para el módulo CRUD de PRODUCTO. Consultas
//               parametrizadas (estándar A4); el JOIN con categoria evita
//               duplicar nombre_categoria en producto (consecuencia directa
//               de la normalización 3FN, ver ENTREGA2_DISENO_LOGICO.md §3.3).
//               Pavanamoon es marca propia: no existe columna "marca".
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

async function listarTodos() {
  const [rows] = await pool.query(
    `SELECT p.producto_id, p.modelo, p.tipo_suela, p.precio_venta,
            c.categoria_id, c.nombre_categoria
       FROM producto p
       JOIN categoria c ON c.categoria_id = p.categoria_id
      ORDER BY p.producto_id DESC`
  );
  return rows;
}

async function buscarPorId(id) {
  const [rows] = await pool.query(
    `SELECT p.*, c.nombre_categoria
       FROM producto p
       JOIN categoria c ON c.categoria_id = p.categoria_id
      WHERE p.producto_id = ?`,
    [id]
  );
  return rows[0] || null;
}

async function crear({ categoria_id, modelo, tipo_suela, precio_venta }) {
  const [result] = await pool.query(
    `INSERT INTO producto (categoria_id, modelo, tipo_suela, precio_venta)
     VALUES (?, ?, ?, ?)`,
    [categoria_id, modelo, tipo_suela, precio_venta]
  );
  return result.insertId;
}

async function actualizar(id, { categoria_id, modelo, tipo_suela, precio_venta }) {
  await pool.query(
    `UPDATE producto
        SET categoria_id = ?, modelo = ?, tipo_suela = ?, precio_venta = ?
      WHERE producto_id = ?`,
    [categoria_id, modelo, tipo_suela, precio_venta, id]
  );
}

async function eliminar(id) {
  await pool.query('DELETE FROM producto WHERE producto_id = ?', [id]);
}

module.exports = { listarTodos, buscarPorId, crear, actualizar, eliminar };

// =============================================================================
// Archivo:      src/models/clienteModel.js
// Descripción:  Acceso a datos para el módulo CRUD de CLIENTE. tipo_cliente
//               ahora es un catálogo (tipo_cliente_id FK), no un ENUM
//               embebido. El teléfono se maneja en cliente_telefono (tabla
//               derivada de la normalización 1FN); esta primera versión del
//               CRUD administra un único teléfono por cliente para mantener
//               el formulario simple en el 30% de avance.
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

async function listarTodos() {
  const [rows] = await pool.query(
    `SELECT c.cliente_id, c.nombre_cliente, c.nit,
            tc.tipo_cliente_id, tc.nombre AS tipo_cliente,
            (SELECT ct.telefono FROM cliente_telefono ct
              WHERE ct.cliente_id = c.cliente_id LIMIT 1) AS telefono
       FROM cliente c
       JOIN tipo_cliente tc ON tc.tipo_cliente_id = c.tipo_cliente_id
      ORDER BY c.cliente_id DESC`
  );
  return rows;
}

async function buscarPorId(id) {
  const [rows] = await pool.query('SELECT * FROM cliente WHERE cliente_id = ?', [id]);
  if (!rows[0]) return null;
  const [tel] = await pool.query(
    'SELECT telefono FROM cliente_telefono WHERE cliente_id = ? LIMIT 1',
    [id]
  );
  return { ...rows[0], telefono: tel[0] ? tel[0].telefono : '' };
}

async function crear({ tipo_cliente_id, nombre_cliente, nit, telefono }) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [result] = await conn.query(
      `INSERT INTO cliente (tipo_cliente_id, nombre_cliente, nit) VALUES (?, ?, ?)`,
      [tipo_cliente_id, nombre_cliente, nit]
    );
    if (telefono) {
      await conn.query(
        'INSERT INTO cliente_telefono (cliente_id, telefono) VALUES (?, ?)',
        [result.insertId, telefono]
      );
    }
    await conn.commit();
    return result.insertId;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function actualizar(id, { tipo_cliente_id, nombre_cliente, nit, telefono }) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.query(
      `UPDATE cliente SET tipo_cliente_id = ?, nombre_cliente = ?, nit = ? WHERE cliente_id = ?`,
      [tipo_cliente_id, nombre_cliente, nit, id]
    );
    await conn.query('DELETE FROM cliente_telefono WHERE cliente_id = ?', [id]);
    if (telefono) {
      await conn.query(
        'INSERT INTO cliente_telefono (cliente_id, telefono) VALUES (?, ?)',
        [id, telefono]
      );
    }
    await conn.commit();
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function eliminar(id) {
  await pool.query('DELETE FROM cliente WHERE cliente_id = ?', [id]);
}

module.exports = { listarTodos, buscarPorId, crear, actualizar, eliminar };

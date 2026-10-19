// =============================================================================
// Archivo: src/models/clienteModel.js
// CRUD de clientes con teléfonos multivaluados (cliente_telefono, 1FN).
// Alta/edición atómicas mediante transacciones.
// =============================================================================
const pool = require('../config/db');
const { extraerTelefonos } = require('../utils/validate');

function telefonosDe(datos) {
  if (Array.isArray(datos.telefonos)) return datos.telefonos;
  return extraerTelefonos(datos.telefonos ?? datos.telefono);
}

async function listarTodos() {
  const [rows] = await pool.query(
    `SELECT c.cliente_id, c.nombre_cliente, c.nit,
            tc.tipo_cliente_id, tc.nombre AS tipo_cliente,
            (SELECT ct.telefono FROM cliente_telefono ct
              WHERE ct.cliente_id = c.cliente_id ORDER BY ct.telefono LIMIT 1) AS telefono,
            (SELECT GROUP_CONCAT(ct.telefono ORDER BY ct.telefono SEPARATOR ' | ')
               FROM cliente_telefono ct WHERE ct.cliente_id = c.cliente_id) AS telefonos
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
    'SELECT telefono FROM cliente_telefono WHERE cliente_id = ? ORDER BY telefono', [id]
  );
  return {
    ...rows[0],
    telefonos: tel.map((r) => r.telefono).join('\n'),
    telefono: tel.length ? tel[0].telefono : '', // compatibilidad de lectura con código anterior
  };
}

async function crear(datos) {
  const { tipo_cliente_id, nombre_cliente, nit } = datos;
  const telefonos = telefonosDe(datos);
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [result] = await conn.query(
      'INSERT INTO cliente (tipo_cliente_id, nombre_cliente, nit) VALUES (?, ?, ?)',
      [tipo_cliente_id, nombre_cliente, nit]
    );
    for (const telefono of telefonos) {
      await conn.query('INSERT INTO cliente_telefono (cliente_id, telefono) VALUES (?, ?)', [result.insertId, telefono]);
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

async function actualizar(id, datos) {
  const { tipo_cliente_id, nombre_cliente, nit } = datos;
  const telefonos = telefonosDe(datos);
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    // La fila padre se bloquea para serializar ediciones de teléfonos del mismo cliente.
    const [actual] = await conn.query('SELECT cliente_id FROM cliente WHERE cliente_id = ? FOR UPDATE', [id]);
    if (!actual.length) {
      await conn.rollback();
      return false;
    }
    await conn.query(
      'UPDATE cliente SET tipo_cliente_id = ?, nombre_cliente = ?, nit = ? WHERE cliente_id = ?',
      [tipo_cliente_id, nombre_cliente, nit, id]
    );
    await conn.query('DELETE FROM cliente_telefono WHERE cliente_id = ?', [id]);
    for (const telefono of telefonos) {
      await conn.query('INSERT INTO cliente_telefono (cliente_id, telefono) VALUES (?, ?)', [id, telefono]);
    }
    await conn.commit();
    return true;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function contarPedidos(id) {
  const [rows] = await pool.query('SELECT COUNT(*) AS total FROM pedido WHERE cliente_id = ?', [id]);
  return Number(rows[0].total);
}

async function eliminar(id) {
  const [result] = await pool.query('DELETE FROM cliente WHERE cliente_id = ?', [id]);
  return result.affectedRows > 0;
}

module.exports = { listarTodos, buscarPorId, crear, actualizar, contarPedidos, eliminar };

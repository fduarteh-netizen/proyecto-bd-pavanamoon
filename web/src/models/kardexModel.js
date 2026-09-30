// =============================================================================
// Archivo:      src/models/kardexModel.js
// Descripción:  Consulta del kardex (RF16, RF18) sobre la vista vw_kardex,
//               con filtros opcionales por SKU y rango de fechas. Todos los
//               filtros van como parámetros (A4), nunca concatenados.
// Dependencias: src/config/db.js, vista vw_kardex
// =============================================================================

const pool = require('../config/db');

async function listar({ sku = '', desde = '', hasta = '' } = {}) {
  const condiciones = [];
  const params = [];
  if (sku) {
    condiciones.push('sku LIKE ?');
    params.push(`%${sku}%`);
  }
  if (desde) {
    condiciones.push('fecha_movimiento >= ?');
    params.push(`${desde} 00:00:00`);
  }
  if (hasta) {
    condiciones.push('fecha_movimiento <= ?');
    params.push(`${hasta} 23:59:59`);
  }
  const where = condiciones.length ? `WHERE ${condiciones.join(' AND ')}` : '';
  const [rows] = await pool.query(
    `SELECT * FROM vw_kardex ${where} ORDER BY fecha_movimiento DESC, movimiento_id DESC LIMIT 300`,
    params
  );
  return rows;
}

module.exports = { listar };

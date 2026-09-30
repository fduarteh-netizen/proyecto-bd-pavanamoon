// =============================================================================
// Archivo:      src/models/ingresoModel.js
// Descripción:  Acceso a datos del módulo Ingresos de mercadería (RF07-RF09).
//               El encabezado y sus líneas se insertan en UNA transacción:
//               si una línea falla, no queda un ingreso a medias. La app NO
//               toca el stock: el trigger trg_detalle_ingreso_ai suma los
//               pares y registra la entrada en el kardex.
// Dependencias: src/config/db.js, vista vw_ingresos_detalle,
//               trigger trg_detalle_ingreso_ai
// =============================================================================

const pool = require('../config/db');

async function listar() {
  const [rows] = await pool.query(
    'SELECT * FROM vw_ingresos_detalle ORDER BY fecha_ingreso DESC, ingreso_id DESC LIMIT 200'
  );
  return rows;
}

async function buscarDetalle(id) {
  const [cab] = await pool.query('SELECT * FROM vw_ingresos_detalle WHERE ingreso_id = ?', [id]);
  if (!cab[0]) return null;
  const [lineas] = await pool.query(
    `SELECT di.variante_id, v.sku, v.modelo, v.talla, v.color, di.cantidad, di.costo_unitario, di.subtotal
       FROM detalle_ingreso di
       JOIN vw_stock_variantes v ON v.variante_id = di.variante_id
      WHERE di.ingreso_id = ?`,
    [id]
  );
  return { ...cab[0], lineas };
}

/** Crea el ingreso con sus líneas en una sola transacción. */
async function crear({ furgon_id, bodega_destino, empleado_id, lineas }) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [result] = await conn.query(
      `INSERT INTO ingreso_mercaderia (furgon_id, empleado_id, bodega_destino, estado)
       VALUES (?, ?, ?, 'completado')`,
      [furgon_id, empleado_id, bodega_destino]
    );
    for (const linea of lineas) {
      await conn.query(
        'INSERT INTO detalle_ingreso (ingreso_id, variante_id, cantidad, costo_unitario) VALUES (?, ?, ?, ?)',
        [result.insertId, linea.variante_id, linea.cantidad, linea.costo_unitario]
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

module.exports = { listar, buscarDetalle, crear };

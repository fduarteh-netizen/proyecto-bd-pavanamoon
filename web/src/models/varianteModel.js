// =============================================================================
// Archivo:      src/models/varianteModel.js
// Descripción:  Acceso a datos del módulo Inventario (RF02, RF03, RF04).
//               La lectura se hace sobre la vista vw_stock_variantes (no se
//               repite el JOIN de 5 tablas en la app). El stock de una
//               variante nueva inicia en 0: solo cambia por ingresos,
//               pedidos o devoluciones (triggers/procedimientos), nunca a mano.
// Dependencias: src/config/db.js, vista vw_stock_variantes
// =============================================================================

const pool = require('../config/db');

/** Lista variantes; si soloAlertas es true, solo las que están bajo el mínimo. */
async function listar({ soloAlertas = false, busqueda = '' } = {}) {
  const condiciones = [];
  const params = [];
  if (soloAlertas) condiciones.push('alerta_stock_bajo = 1');
  if (busqueda) {
    condiciones.push('(sku LIKE ? OR modelo LIKE ?)');
    params.push(`%${busqueda}%`, `%${busqueda}%`);
  }
  const where = condiciones.length ? `WHERE ${condiciones.join(' AND ')}` : '';
  const [rows] = await pool.query(
    `SELECT * FROM vw_stock_variantes ${where} ORDER BY alerta_stock_bajo DESC, modelo, talla`,
    params
  );
  return rows;
}

/** Variantes con stock > 0, para el formulario de pedidos. */
async function listarDisponibles() {
  const [rows] = await pool.query(
    'SELECT variante_id, sku, modelo, talla, color, precio_venta, stock_actual FROM vw_stock_variantes WHERE stock_actual > 0 ORDER BY modelo, talla'
  );
  return rows;
}

/** Todas las variantes, para el formulario de ingresos de mercadería. */
async function listarTodasSimple() {
  const [rows] = await pool.query(
    'SELECT variante_id, sku, modelo, talla, color, stock_actual FROM vw_stock_variantes ORDER BY modelo, talla'
  );
  return rows;
}

/** Crea una variante con stock 0. El SKU se deriva de producto+talla+color. */
async function crear({ producto_id, talla_id, color_id, stock_minimo }) {
  const sku = `PVM-${String(producto_id).padStart(3, '0')}-T${String(talla_id).padStart(2, '0')}-C${String(color_id).padStart(2, '0')}`;
  const [result] = await pool.query(
    `INSERT INTO variante_producto (producto_id, talla_id, color_id, sku, stock_actual, stock_minimo)
     VALUES (?, ?, ?, ?, 0, ?)`,
    [producto_id, talla_id, color_id, sku, stock_minimo]
  );
  return result.insertId;
}

module.exports = { listar, listarDisponibles, listarTodasSimple, crear };

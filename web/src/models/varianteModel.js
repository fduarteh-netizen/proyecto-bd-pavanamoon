// =============================================================================
// Archivo: src/models/varianteModel.js
// Inventario: lectura, alta, edición y baja de variantes.
// El stock se modifica SOLO mediante ingresos, pedidos y devoluciones.
// =============================================================================
const pool = require('../config/db');

/** Arma el SKU a partir de producto, talla y color (no accede a la BD). */
function skuDe({ producto_id, talla_id, color_id }) {
  return `PVM-${String(producto_id).padStart(3, '0')}-T${String(talla_id).padStart(2, '0')}-C${String(color_id).padStart(2, '0')}`;
}

/** Crea un error de negocio con código VARIANTE_BLOQUEADA para mostrarlo al usuario (no accede a la BD). */
function errorNegocio(mensaje) {
  const err = new Error(mensaje);
  err.code = 'VARIANTE_BLOQUEADA';
  return err;
}

/** Lista las variantes con su stock y alerta desde vw_stock_variantes; filtros opcionales parametrizados. */
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

/** Lista las variantes con stock disponible para el formulario de pedidos. */
async function listarDisponibles() {
  const [rows] = await pool.query(
    'SELECT variante_id, sku, modelo, talla, color, precio_venta, stock_actual FROM vw_stock_variantes WHERE stock_actual > 0 ORDER BY modelo, talla'
  );
  return rows;
}

/** Lista todas las variantes (id y descripción) para el formulario de ingresos. */
async function listarTodasSimple() {
  const [rows] = await pool.query(
    'SELECT variante_id, sku, modelo, talla, color, stock_actual FROM vw_stock_variantes ORDER BY modelo, talla'
  );
  return rows;
}

/** Crea una variante con SKU derivado y stock inicial 0 (solo sube con un ingreso); devuelve el id nuevo. */
async function crear({ producto_id, talla_id, color_id, stock_minimo }) {
  const sku = skuDe({ producto_id, talla_id, color_id });
  const [result] = await pool.query(
    `INSERT INTO variante_producto (producto_id, talla_id, color_id, sku, stock_actual, stock_minimo)
     VALUES (?, ?, ?, ?, 0, ?)`,
    [producto_id, talla_id, color_id, sku, stock_minimo]
  );
  return result.insertId;
}

// No se puede cambiar producto/talla/color después de vender, ingresar o mover
// unidades: distorsionaría el historial del Kardex y el detalle de pedidos.
async function tieneHistorial(conn, id) {
  const [rows] = await conn.query(
    `SELECT
       EXISTS(SELECT 1 FROM detalle_pedido WHERE variante_id = ? LIMIT 1) AS pedidos,
       EXISTS(SELECT 1 FROM detalle_ingreso WHERE variante_id = ? LIMIT 1) AS ingresos,
       EXISTS(SELECT 1 FROM movimiento_stock WHERE variante_id = ? LIMIT 1) AS movimientos`,
    [id, id, id]
  );
  return Boolean(rows[0].pedidos || rows[0].ingresos || rows[0].movimientos);
}

/** Busca una variante por id e indica si su identidad está bloqueada por tener stock o movimientos. */
async function buscarPorId(id) {
  const [rows] = await pool.query(
    `SELECT variante_id, producto_id, talla_id, color_id, sku, stock_actual, stock_minimo
       FROM variante_producto WHERE variante_id = ?`, [id]
  );
  if (!rows.length) return null;
  const historial = await tieneHistorial(pool, id);
  return { ...rows[0], identidadBloqueada: historial || Number(rows[0].stock_actual) !== 0 };
}

/** Actualiza una variante en una transacción con FOR UPDATE; si tiene stock solo permite cambiar el stock mínimo. */
async function actualizar(id, { producto_id, talla_id, color_id, stock_minimo }) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [rows] = await conn.query(
      `SELECT producto_id, talla_id, color_id, stock_actual
         FROM variante_producto WHERE variante_id = ? FOR UPDATE`, [id]
    );
    if (!rows.length) {
      await conn.rollback();
      return false;
    }
    const actual = rows[0];
    const cambiaIdentidad = Number(actual.producto_id) !== Number(producto_id)
      || Number(actual.talla_id) !== Number(talla_id)
      || Number(actual.color_id) !== Number(color_id);
    if (cambiaIdentidad && (Number(actual.stock_actual) !== 0 || await tieneHistorial(conn, id))) {
      throw errorNegocio('No puedes cambiar producto, talla o color: la variante tiene stock o historial. Solo puedes modificar el stock mínimo.');
    }
    if (cambiaIdentidad) {
      await conn.query(
        `UPDATE variante_producto
            SET producto_id = ?, talla_id = ?, color_id = ?, sku = ?, stock_minimo = ?
          WHERE variante_id = ?`,
        [producto_id, talla_id, color_id, skuDe({ producto_id, talla_id, color_id }), stock_minimo, id]
      );
    } else {
      await conn.query('UPDATE variante_producto SET stock_minimo = ? WHERE variante_id = ?', [stock_minimo, id]);
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

/** Elimina una variante en una transacción; no se permite si tiene movimientos en el kardex. */
async function eliminar(id) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [rows] = await conn.query(
      'SELECT stock_actual FROM variante_producto WHERE variante_id = ? FOR UPDATE', [id]
    );
    if (!rows.length) {
      await conn.rollback();
      return false;
    }
    if (Number(rows[0].stock_actual) !== 0 || await tieneHistorial(conn, id)) {
      throw errorNegocio('No se puede eliminar esta variante porque tiene stock o movimientos, pedidos o ingresos relacionados. El historial debe conservarse.');
    }
    await conn.query('DELETE FROM variante_producto WHERE variante_id = ?', [id]);
    await conn.commit();
    return true;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

module.exports = { listar, listarDisponibles, listarTodasSimple, crear, buscarPorId, actualizar, eliminar };

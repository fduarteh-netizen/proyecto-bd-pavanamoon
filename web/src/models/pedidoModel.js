// =============================================================================
// Archivo:      src/models/pedidoModel.js
// Descripción:  Acceso a datos del módulo Pedidos (RF11-RF14, RF17). La app
//               NO calcula precios ni toca el stock: invoca los
//               procedimientos sp_crear_pedido y sp_agregar_linea_pedido
//               (precio con descuento por fn_calcular_precio_linea) dentro de
//               UNA transacción; los triggers validan stock, lo descuentan,
//               registran el kardex y recalculan el total. Si cualquier línea
//               falla (ej. stock insuficiente) se hace ROLLBACK de todo.
// Dependencias: src/config/db.js, vista vw_pedidos_resumen,
//               sp_crear_pedido, sp_agregar_linea_pedido, sp_registrar_devolucion
// =============================================================================

const pool = require('../config/db');

async function listar({ clienteId = null } = {}) {
  const where = clienteId ? 'WHERE cliente_id = ?' : '';
  const [rows] = await pool.query(
    `SELECT * FROM vw_pedidos_resumen ${where} ORDER BY fecha_pedido DESC, pedido_id DESC LIMIT 200`,
    clienteId ? [clienteId] : []
  );
  return rows;
}

async function buscarDetalle(id) {
  const [cab] = await pool.query('SELECT * FROM vw_pedidos_resumen WHERE pedido_id = ?', [id]);
  if (!cab[0]) return null;
  const [lineas] = await pool.query(
    `SELECT dp.variante_id, v.sku, v.modelo, v.talla, v.color, pv.nombre AS presentacion,
            pv.cantidad_pares, dp.cantidad, dp.precio_unitario, dp.subtotal
       FROM detalle_pedido dp
       JOIN vw_stock_variantes v  ON v.variante_id      = dp.variante_id
       JOIN presentacion_venta pv ON pv.presentacion_id = dp.presentacion_id
      WHERE dp.pedido_id = ?`,
    [id]
  );
  return { ...cab[0], lineas };
}

/** Crea el pedido y sus líneas vía procedimientos almacenados, todo o nada. */
async function crear({ cliente_id, empleado_id, lineas }) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.query('CALL sp_crear_pedido(?, ?, @nuevo_pedido_id)', [cliente_id, empleado_id]);
    const [[{ pedidoId }]] = await conn.query('SELECT @nuevo_pedido_id AS pedidoId');
    for (const linea of lineas) {
      await conn.query('CALL sp_agregar_linea_pedido(?, ?, ?, ?)', [
        pedidoId,
        linea.variante_id,
        linea.presentacion_id,
        linea.cantidad,
      ]);
    }
    await conn.commit();
    return pedidoId;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

/** Marca un pedido pendiente como completado (ya no admite más líneas). */
async function completar(id) {
  const [result] = await pool.query(
    "UPDATE pedido SET estado = 'completado' WHERE pedido_id = ? AND estado = 'pendiente'",
    [id]
  );
  return result.affectedRows === 1;
}

/** Devolución de cliente (RF17) mediante el procedimiento transaccional. */
async function registrarDevolucion({ pedido_id, variante_id, pares, empleado_id }) {
  await pool.query('CALL sp_registrar_devolucion(?, ?, ?, ?)', [pedido_id, variante_id, pares, empleado_id]);
}

module.exports = { listar, buscarDetalle, crear, completar, registrarDevolucion };

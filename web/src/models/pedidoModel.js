// =============================================================================
// Archivo:      src/models/pedidoModel.js
// =============================================================================

const pool = require('../config/db');

async function listar() {
  const [rows] = await pool.query(`
    SELECT *
    FROM vw_pedidos_resumen
    ORDER BY fecha_pedido DESC, pedido_id DESC
    LIMIT 200
  `);

  return rows;
}

async function buscarDetalle(id) {
  const [cab] = await pool.query(
    'SELECT * FROM vw_pedidos_resumen WHERE pedido_id = ?',
    [id]
  );

  if (!cab[0]) return null;

  const [lineas] = await pool.query(
    `SELECT dp.variante_id,
            v.sku,
            v.modelo,
            v.talla,
            v.color,
            pv.nombre AS presentacion,
            pv.cantidad_pares,
            dp.cantidad,
            dp.precio_unitario,
            dp.subtotal
       FROM detalle_pedido dp
       JOIN vw_stock_variantes v
         ON v.variante_id = dp.variante_id
       JOIN presentacion_venta pv
         ON pv.presentacion_id = dp.presentacion_id
      WHERE dp.pedido_id = ?`,
    [id]
  );

  return { ...cab[0], lineas };
}

async function crear({ cliente_id, empleado_id, lineas }) {
  const conn = await pool.getConnection();

  try {
    await conn.beginTransaction();

    await conn.query(
      'CALL sp_crear_pedido(?, ?, @nuevo_pedido_id)',
      [cliente_id, empleado_id]
    );

    const [[{ pedidoId }]] = await conn.query(
      'SELECT @nuevo_pedido_id AS pedidoId'
    );

    for (const linea of lineas) {
      await conn.query(
        'CALL sp_agregar_variante_pedido(?, ?, ?, ?)',
        [
          pedidoId,
          linea.variante_id,
          linea.presentacion_id,
          linea.cantidad
        ]
      );
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

async function completar(id) {
  const [result] = await pool.query(
    "UPDATE pedido SET estado = 'completado' WHERE pedido_id = ? AND estado = 'pendiente'",
    [id]
  );

  return result.affectedRows === 1;
}

async function registrarDevolucion({
  pedido_id,
  variante_id,
  pares,
  empleado_id
}) {
  await pool.query(
    'CALL sp_registrar_devolucion(?, ?, ?, ?)',
    [pedido_id, variante_id, pares, empleado_id]
  );
}

module.exports = {
  listar,
  buscarDetalle,
  crear,
  completar,
  registrarDevolucion
};
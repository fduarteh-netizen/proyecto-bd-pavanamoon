// =============================================================================
// Archivo:      src/models/pedidoModel.js
// Descripción:  Acceso a datos del módulo Pedidos (RF11-RF14, RF17). La app
//               NO calcula precios ni toca el stock: invoca los
//               procedimientos sp_crear_pedido y sp_agregar_linea_pedido
//               (precio con descuento por fn_calcular_precio_linea) dentro de
//               UNA transacción; los triggers validan stock, lo descuentan,
//               registran el kardex y recalculan el total. Si cualquier línea
//               falla (ej. stock insuficiente) se hace ROLLBACK de todo.
//               listar() acepta clienteId para el historial por cliente (RF14).
//               Entrega 4: cancelar() invoca sp_cancelar_pedido (reintegra
//               stock y deja kardex) y buscarDetalle() trae, por línea, los
//               pares ya devueltos (calculados desde el kardex) para que la
//               pantalla solo ofrezca devolver lo pendiente.
// Dependencias: src/config/db.js, vista vw_pedidos_resumen,
//               sp_crear_pedido, sp_agregar_linea_pedido, sp_registrar_devolucion,
//               sp_cancelar_pedido
// =============================================================================

const pool = require('../config/db');

/** Lista los pedidos desde vw_pedidos_resumen; si se indica clienteId, solo los de ese cliente (RF14). */
async function listar({ clienteId = null } = {}) {
  const where = clienteId ? 'WHERE cliente_id = ?' : '';
  const [rows] = await pool.query(
    `SELECT *
     FROM vw_pedidos_resumen
     ${where}
     ORDER BY fecha_pedido DESC, pedido_id DESC
     LIMIT 200`,
    clienteId ? [clienteId] : []
  );

  return rows;
}

/** Devuelve un pedido con sus líneas y lo vendido/devuelto por variante (para la devolución); null si no existe. */
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
            dp.subtotal,
            (SELECT COALESCE(SUM(ms.cantidad), 0)
               FROM movimiento_stock ms
              WHERE ms.pedido_id = dp.pedido_id
                AND ms.variante_id = dp.variante_id
                AND ms.tipo_movimiento = 'devolucion_cliente') AS pares_devueltos
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

/** Crea un pedido completo en una transacción: sp_crear_pedido + sp_agregar_linea_pedido por línea; los triggers validan y descuentan el stock. */
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

    // Concurrencia (Entrega 4): las líneas se insertan siempre en orden de
    // variante_id. Cada línea bloquea su variante (sp_agregar_linea_pedido,
    // FOR UPDATE); si dos pedidos con las mismas variantes las bloquearan en
    // orden distinto (A,B contra B,A) podrían esperarse mutuamente. Con un
    // orden único, uno simplemente espera al otro.
    const lineasOrdenadas = [...lineas].sort((a, b) => Number(a.variante_id) - Number(b.variante_id));

    for (const linea of lineasOrdenadas) {
      await conn.query(
        'CALL sp_agregar_linea_pedido(?, ?, ?, ?)',
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

/** Marca un pedido como completado solo si está pendiente; devuelve true si cambió. */
async function completar(id) {
  const [result] = await pool.query(
    "UPDATE pedido SET estado = 'completado' WHERE pedido_id = ? AND estado = 'pendiente'",
    [id]
  );

  return result.affectedRows === 1;
}

/** Registra una devolución con sp_registrar_devolucion (valida lo vendido menos lo ya devuelto y repone el stock). */
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

/**
 * Cancela un pedido pendiente mediante sp_cancelar_pedido: el procedimiento
 * valida el estado, regresa los pares al stock, registra cada reintegro en
 * el kardex ('cancelacion') y cambia el estado, todo en una transacción.
 * empleado_id viene de la sesión (quién canceló), nunca del formulario.
 */
async function cancelar(id, empleado_id) {
  await pool.query('CALL sp_cancelar_pedido(?, ?)', [id, empleado_id]);
}

module.exports = {
  listar,
  buscarDetalle,
  crear,
  completar,
  cancelar,
  registrarDevolucion
};
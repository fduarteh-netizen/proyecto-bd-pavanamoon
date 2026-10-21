// =============================================================================
// Archivo:      src/models/reporteModel.js
// Descripción:  Acceso a datos del módulo Reportes (Entrega 4). Solo lectura
//               sobre las vistas vw_ventas_diarias y vw_ventas_por_modelo:
//               la app no recalcula montos, solo filtra y agrupa (S7).
//               Filtros de fecha y límite siempre como parámetros (A4).
// Dependencias: src/config/db.js, vistas vw_ventas_diarias, vw_ventas_por_modelo
// =============================================================================

const pool = require('../config/db');

/** Arma el WHERE de rango de fechas sobre vw_ventas_diarias. */
function filtroFechas({ desde, hasta }) {
  const condiciones = [];
  const params = [];
  if (desde) { condiciones.push('fecha >= ?'); params.push(desde); }
  if (hasta) { condiciones.push('fecha <= ?'); params.push(hasta); }
  return { where: condiciones.length ? `WHERE ${condiciones.join(' AND ')}` : '', params };
}

/** Totales del periodo: pedidos, pares, monto y ticket promedio. */
async function resumenVentas(rango) {
  const { where, params } = filtroFechas(rango);
  const [[fila]] = await pool.query(
    `SELECT COALESCE(SUM(pedidos), 0)        AS pedidos,
            COALESCE(SUM(pares_vendidos), 0) AS pares,
            COALESCE(SUM(monto_vendido), 0)  AS monto,
            MIN(fecha) AS primera_venta, MAX(fecha) AS ultima_venta
       FROM vw_ventas_diarias ${where}`,
    params
  );
  fila.ticket = fila.pedidos > 0 ? Number(fila.monto) / Number(fila.pedidos) : 0;
  return fila;
}

/** Ventas agrupadas por mes dentro del rango (ventas por periodo). */
async function ventasPorMes(rango) {
  const { where, params } = filtroFechas(rango);
  const [rows] = await pool.query(
    `SELECT DATE_FORMAT(fecha, '%Y-%m') AS periodo,
            SUM(pedidos)        AS pedidos,
            SUM(pares_vendidos) AS pares,
            SUM(monto_vendido)  AS monto
       FROM vw_ventas_diarias ${where}
      GROUP BY DATE_FORMAT(fecha, '%Y-%m')
      ORDER BY periodo`,
    params
  );
  return rows;
}

/** Detalle día a día dentro del rango. */
async function ventasPorDia(rango) {
  const { where, params } = filtroFechas(rango);
  const [rows] = await pool.query(
    `SELECT * FROM vw_ventas_diarias ${where} ORDER BY fecha DESC LIMIT 120`,
    params
  );
  return rows;
}

/**
 * Ranking de modelos por pares netos (vendidos - devueltos).
 * orden = 'mas' (más vendidos) o 'menos' (los que menos rotan).
 */
async function rankingModelos({ limite = 10, orden = 'mas' } = {}) {
  const direccion = orden === 'menos' ? 'ASC' : 'DESC'; // valor de lista blanca, no del usuario
  const [rows] = await pool.query(
    `SELECT * FROM vw_ventas_por_modelo
      ORDER BY pares_netos ${direccion}, monto_vendido ${direccion}, modelo
      LIMIT ?`,
    [limite]
  );
  return rows;
}

module.exports = { resumenVentas, ventasPorMes, ventasPorDia, rankingModelos };

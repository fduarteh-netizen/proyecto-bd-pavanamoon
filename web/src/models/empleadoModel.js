// =============================================================================
// Archivo:      src/models/empleadoModel.js
// Descripción:  Acceso a datos del módulo Empleados (Entrega 4, RF19).
//               EMPLEADO.telefono es multivaluado: se guarda en
//               empleado_telefono (1FN), una fila por número. Alta y edición
//               son transaccionales (empleado + teléfonos, todo o nada).
//               Un empleado con usuario, pedidos, ingresos o movimientos no
//               se puede borrar (FK ON DELETE RESTRICT): se informa al
//               usuario con contarReferencias() antes de intentar borrar.
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

/** Lista empleados con sus teléfonos, su usuario (si tiene) y su actividad. */
async function listar({ buscar = '' } = {}) {
  const where = buscar ? 'WHERE e.nombres_apellidos LIKE ? OR e.dpi LIKE ?' : '';
  const params = buscar ? [`%${buscar}%`, `%${buscar}%`] : [];
  const [rows] = await pool.query(
    `SELECT e.empleado_id, e.nombres_apellidos, e.dpi,
            (SELECT GROUP_CONCAT(t.telefono ORDER BY t.telefono SEPARATOR ', ')
               FROM empleado_telefono t WHERE t.empleado_id = e.empleado_id) AS telefonos,
            u.username, u.estado AS estado_usuario, r.nombre_rol,
            (SELECT COUNT(*) FROM pedido p WHERE p.empleado_id = e.empleado_id) AS pedidos,
            (SELECT COUNT(*) FROM ingreso_mercaderia i WHERE i.empleado_id = e.empleado_id) AS ingresos
       FROM empleado e
       LEFT JOIN usuario u ON u.empleado_id = e.empleado_id
       LEFT JOIN rol     r ON r.rol_id      = u.rol_id
       ${where}
      ORDER BY e.nombres_apellidos`,
    params
  );
  return rows;
}

/** Empleado con sus teléfonos como texto (uno por línea) para el formulario. */
async function buscarPorId(id) {
  const [rows] = await pool.query('SELECT * FROM empleado WHERE empleado_id = ?', [id]);
  if (!rows[0]) return null;
  const [tels] = await pool.query(
    'SELECT telefono FROM empleado_telefono WHERE empleado_id = ? ORDER BY telefono',
    [id]
  );
  return { ...rows[0], telefonos: tels.map((t) => t.telefono).join('\n') };
}

/** Empleados que todavía no tienen usuario (para el alta de usuarios). */
async function listarSinUsuario() {
  const [rows] = await pool.query(
    `SELECT e.empleado_id, e.nombres_apellidos, e.dpi
       FROM empleado e
      WHERE NOT EXISTS (SELECT 1 FROM usuario u WHERE u.empleado_id = e.empleado_id)
      ORDER BY e.nombres_apellidos`
  );
  return rows;
}

/** Reemplaza los teléfonos del empleado dentro de la transacción recibida. */
async function guardarTelefonos(conn, empleadoId, telefonos) {
  await conn.query('DELETE FROM empleado_telefono WHERE empleado_id = ?', [empleadoId]);
  for (const telefono of telefonos) {
    await conn.query(
      'INSERT INTO empleado_telefono (empleado_id, telefono) VALUES (?, ?)',
      [empleadoId, telefono]
    );
  }
}

/** Ejecuta fn(conn) dentro de una transacción; ROLLBACK si algo falla. */
async function enTransaccion(fn) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const resultado = await fn(conn);
    await conn.commit();
    return resultado;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function crear({ nombres_apellidos, dpi, telefonos }) {
  return enTransaccion(async (conn) => {
    const [result] = await conn.query(
      'INSERT INTO empleado (nombres_apellidos, dpi) VALUES (?, ?)',
      [nombres_apellidos.trim(), dpi.trim()]
    );
    await guardarTelefonos(conn, result.insertId, telefonos);
    return result.insertId;
  });
}

async function actualizar(id, { nombres_apellidos, dpi, telefonos }) {
  await enTransaccion(async (conn) => {
    await conn.query(
      'UPDATE empleado SET nombres_apellidos = ?, dpi = ? WHERE empleado_id = ?',
      [nombres_apellidos.trim(), dpi.trim(), id]
    );
    await guardarTelefonos(conn, id, telefonos);
  });
}

/**
 * Cuenta lo que impide borrar al empleado (FK RESTRICT). Permite explicar
 * el motivo exacto en vez de mostrar un error genérico de la BD.
 */
async function contarReferencias(id) {
  const [[fila]] = await pool.query(
    `SELECT (SELECT COUNT(*) FROM usuario            WHERE empleado_id = ?) AS usuario,
            (SELECT COUNT(*) FROM pedido             WHERE empleado_id = ?) AS pedidos,
            (SELECT COUNT(*) FROM ingreso_mercaderia WHERE empleado_id = ?) AS ingresos,
            (SELECT COUNT(*) FROM movimiento_stock   WHERE empleado_id = ?) AS movimientos`,
    [id, id, id, id]
  );
  return fila;
}

/** Borra el empleado; sus teléfonos se borran solos (FK ON DELETE CASCADE). */
async function eliminar(id) {
  await pool.query('DELETE FROM empleado WHERE empleado_id = ?', [id]);
}

module.exports = {
  listar, buscarPorId, listarSinUsuario, crear, actualizar, contarReferencias, eliminar,
};

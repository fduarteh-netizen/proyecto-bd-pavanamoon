// =============================================================================
// Archivo:      src/models/usuarioModel.js
// Descripción:  Acceso a datos de usuarios: autenticación (RF20) y, desde la
//               Entrega 4, administración de usuarios (RF19). Todas las
//               consultas usan parámetros preparados (?) para prevenir
//               inyección SQL (A4). Es la única capa que conoce SQL; las rutas
//               nunca escriben SQL directamente (A1).
//               Contraseñas: solo se guarda el hash bcrypt (costo 10); el
//               hash nunca sale de este modelo hacia las vistas.
// Dependencias: src/config/db.js, bcryptjs
// =============================================================================

const bcrypt = require('bcryptjs');
const pool = require('../config/db');

const COSTO_BCRYPT = 10;

/**
 * Busca un usuario por username, junto con su rol y su nombre de
 * empleado, para poder validar credenciales y poblar la sesión.
 */
async function buscarPorUsername(username) {
  const [rows] = await pool.query(
    `SELECT u.usuario_id, u.username, u.password_hash, u.estado,
            r.rol_id, r.nombre_rol,
            e.empleado_id, e.nombres_apellidos AS nombres
       FROM usuario u
       JOIN rol r      ON r.rol_id = u.rol_id
       JOIN empleado e ON e.empleado_id = u.empleado_id
      WHERE u.username = ?
      LIMIT 1`,
    [username]
  );
  return rows[0] || null;
}

/**
 * Estado y rol vigentes de un usuario en sesión. Se consulta en cada
 * petición (búsqueda por PK) para que desactivar a un usuario o cambiarle
 * el rol tenga efecto inmediato, aunque ya tenga la sesión abierta.
 */
async function estadoActual(usuarioId) {
  const [rows] = await pool.query(
    `SELECT u.estado, r.nombre_rol
       FROM usuario u JOIN rol r ON r.rol_id = u.rol_id
      WHERE u.usuario_id = ?`,
    [usuarioId]
  );
  return rows[0] || null;
}

/** Listado para administración (sin password_hash). */
async function listar() {
  const [rows] = await pool.query(
    `SELECT u.usuario_id, u.username, u.estado, u.fecha_creacion,
            r.rol_id, r.nombre_rol, e.empleado_id, e.nombres_apellidos
       FROM usuario u
       JOIN rol r      ON r.rol_id = u.rol_id
       JOIN empleado e ON e.empleado_id = u.empleado_id
      ORDER BY r.rol_id, u.username`
  );
  return rows;
}

/** Usuario para el formulario de edición (sin password_hash). */
async function buscarPorId(id) {
  const [rows] = await pool.query(
    `SELECT u.usuario_id, u.username, u.estado, u.rol_id, u.empleado_id,
            e.nombres_apellidos
       FROM usuario u JOIN empleado e ON e.empleado_id = u.empleado_id
      WHERE u.usuario_id = ?`,
    [id]
  );
  return rows[0] || null;
}

/** Lista los roles (tabla rol) para el formulario de usuarios. */
async function listarRoles() {
  const [rows] = await pool.query('SELECT rol_id, nombre_rol, descripcion FROM rol ORDER BY rol_id');
  return rows;
}

/** Crea un usuario guardando la contraseña con hash bcrypt; devuelve el id nuevo. */
async function crear({ username, password, rol_id, empleado_id, estado }) {
  const hash = await bcrypt.hash(password, COSTO_BCRYPT);
  const [result] = await pool.query(
    'INSERT INTO usuario (username, password_hash, estado, rol_id, empleado_id) VALUES (?, ?, ?, ?, ?)',
    [username.trim(), hash, estado, rol_id, empleado_id]
  );
  return result.insertId;
}

/**
 * Actualiza rol y estado; la contraseña solo si se envió una nueva.
 * El username y el empleado no cambian después del alta (trazabilidad).
 */
async function actualizar(id, { rol_id, estado, password }) {
  if (password) {
    const hash = await bcrypt.hash(password, COSTO_BCRYPT);
    await pool.query(
      'UPDATE usuario SET rol_id = ?, estado = ?, password_hash = ? WHERE usuario_id = ?',
      [rol_id, estado, hash, id]
    );
  } else {
    await pool.query('UPDATE usuario SET rol_id = ?, estado = ? WHERE usuario_id = ?', [rol_id, estado, id]);
  }
}

/**
 * Administradores activos distintos de excluirId. Se usa para impedir que
 * el sistema se quede sin ningún administrador activo.
 */
async function contarOtrosAdminsActivos(excluirId) {
  const [[fila]] = await pool.query(
    `SELECT COUNT(*) AS n
       FROM usuario u JOIN rol r ON r.rol_id = u.rol_id
      WHERE r.nombre_rol = 'administrador' AND u.estado = 'activo' AND u.usuario_id <> ?`,
    [excluirId]
  );
  return fila.n;
}

/** Elimina un usuario (DELETE parametrizado). */
async function eliminar(id) {
  await pool.query('DELETE FROM usuario WHERE usuario_id = ?', [id]);
}

module.exports = {
  buscarPorUsername, estadoActual, listar, buscarPorId, listarRoles,
  crear, actualizar, contarOtrosAdminsActivos, eliminar,
};

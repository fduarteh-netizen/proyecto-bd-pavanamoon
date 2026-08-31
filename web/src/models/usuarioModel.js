// =============================================================================
// Archivo:      src/models/usuarioModel.js
// Descripción:  Acceso a datos para autenticación. Todas las consultas usan
//               parámetros preparados (?) para prevenir inyección SQL
//               (estándar A4). Es la única capa que conoce SQL; las rutas
//               nunca escriben SQL directamente (estándar A1).
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

/**
 * Busca un usuario activo por username, junto con su rol y su nombre de
 * empleado, para poder validar credenciales y poblar la sesión.
 */
async function buscarPorUsername(username) {
  const [rows] = await pool.query(
    `SELECT 
        u.usuario_id,
        u.username,
        u.password_hash,
        u.estado,
        r.rol_id,
        r.nombre_rol,
        e.empleado_id,
        e.nombres_apellidos AS nombres
     FROM usuario u
     JOIN rol r 
       ON r.rol_id = u.rol_id
     JOIN empleado e 
       ON e.empleado_id = u.empleado_id
     WHERE u.username = ?
     LIMIT 1`,
    [username]
  );

  return rows[0] || null;
}

module.exports = { buscarPorUsername };

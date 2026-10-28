// =============================================================================
// Archivo:      src/models/furgonModel.js
// Descripción:  Acceso a datos del módulo Furgones (RF06). CRUD completo con
//               consultas parametrizadas (A4). Un furgón con ingresos
//               asociados no se puede borrar (FK ON DELETE RESTRICT); el
//               errorHandler traduce ese error a un mensaje comprensible.
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

/** Lista los furgones con la cantidad de ingresos registrados de cada uno. */
async function listarTodos() {
  const [rows] = await pool.query(
    `SELECT f.*, (SELECT COUNT(*) FROM ingreso_mercaderia im WHERE im.furgon_id = f.furgon_id) AS ingresos
       FROM furgon f ORDER BY f.fecha_llegada DESC, f.furgon_id DESC`
  );
  return rows;
}

/** Lista los furgones disponibles para asociar a un ingreso de mercadería. */
async function listarRecibidos() {
  const [rows] = await pool.query(
    "SELECT furgon_id, numero_furgon, fecha_llegada FROM furgon WHERE estado <> 'cancelado' ORDER BY fecha_llegada DESC"
  );
  return rows;
}

/** Busca un furgón por id; devuelve null si no existe. */
async function buscarPorId(id) {
  const [rows] = await pool.query('SELECT * FROM furgon WHERE furgon_id = ?', [id]);
  return rows[0] || null;
}

/** Registra un furgón (INSERT parametrizado); devuelve el id nuevo. */
async function crear({ numero_furgon, fecha_llegada, procedencia, transportista, estado }) {
  const [result] = await pool.query(
    `INSERT INTO furgon (numero_furgon, fecha_llegada, procedencia, transportista, estado)
     VALUES (?, ?, ?, ?, ?)`,
    [numero_furgon, fecha_llegada, procedencia || null, transportista || null, estado]
  );
  return result.insertId;
}

/** Actualiza los datos de un furgón (UPDATE parametrizado). */
async function actualizar(id, { numero_furgon, fecha_llegada, procedencia, transportista, estado }) {
  await pool.query(
    `UPDATE furgon SET numero_furgon = ?, fecha_llegada = ?, procedencia = ?, transportista = ?, estado = ?
      WHERE furgon_id = ?`,
    [numero_furgon, fecha_llegada, procedencia || null, transportista || null, estado, id]
  );
}

/** Elimina un furgón (la FK lo impide si ya tiene ingresos). */
async function eliminar(id) {
  await pool.query('DELETE FROM furgon WHERE furgon_id = ?', [id]);
}

module.exports = { listarTodos, listarRecibidos, buscarPorId, crear, actualizar, eliminar };

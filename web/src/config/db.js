// =============================================================================
// Archivo:      src/config/db.js
// Descripción:  Configuración de la conexión a MySQL (pool de conexiones).
//               Separada del resto de la aplicación (estándar A1: separación
//               de capas). Toda la app consume este pool, nunca abre
//               conexiones sueltas.
// Dependencias: variables de entorno (.env), paquete mysql2/promise
// =============================================================================

require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'pavanamoon',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  decimalNumbers: true, // devuelve DECIMAL como number en vez de string
});

module.exports = pool;

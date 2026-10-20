// =============================================================================
// Archivo:      server.js
// Descripción:  Punto de entrada de la aplicación web Pavanamoon (Entrega 4,
//               100%). Configura Express, sesiones, EJS, y monta las rutas de
//               autenticación y de todos los módulos, cada uno protegido por rol.
//               Lote 5: la sesión, las cabeceras de seguridad y la
//               verificación de origen se configuran en
//               src/middleware/seguridad.js.
// Dependencias: express, express-session, ejs, method-override, dotenv,
//               src/config/db.js, src/routes/*, src/middleware/*
// =============================================================================

require('dotenv').config();
const path = require('path');
const express = require('express');
const session = require('express-session');
const methodOverride = require('method-override');

const { requireAuth, exposeCurrentUser } = require('./src/middleware/auth');
const { notFoundHandler, errorHandler } = require('./src/middleware/errorHandler');
const { opcionesSesion, cabecerasSeguridad, verificarOrigen } = require('./src/middleware/seguridad');

const authRoutes = require('./src/routes/authRoutes');
const productoRoutes = require('./src/routes/productoRoutes');
const clienteRoutes = require('./src/routes/clienteRoutes');
const inventarioRoutes = require('./src/routes/inventarioRoutes');
const furgonRoutes = require('./src/routes/furgonRoutes');
const ingresoRoutes = require('./src/routes/ingresoRoutes');
const pedidoRoutes = require('./src/routes/pedidoRoutes');
const kardexRoutes = require('./src/routes/kardexRoutes');
const reporteRoutes = require('./src/routes/reporteRoutes');
const empleadoRoutes = require('./src/routes/empleadoRoutes');
const usuarioRoutes = require('./src/routes/usuarioRoutes');
const catalogoRoutes = require('./src/routes/catalogoRoutes');

const app = express();

// Detrás de un proxy HTTPS (Railway, Render, etc.) poner TRUST_PROXY=1: así
// Express conoce la IP real del cliente (límite de intentos) y que la
// conexión es HTTPS (cookie secure).
if (process.env.TRUST_PROXY === '1') app.set('trust proxy', 1);
app.disable('x-powered-by'); // no anunciar que es Express

// --- Configuración de vistas -------------------------------------------------
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// --- Middlewares globales ----------------------------------------------------
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(methodOverride('_method')); // permite <input name="_method" value="PUT|DELETE"> en formularios HTML
app.use(express.static(path.join(__dirname, 'public')));
app.use(cabecerasSeguridad); // después de static: aplica a las páginas dinámicas

// Sesiones en memoria (MemoryStore): válido solo con UNA instancia de la app.
// Ver "DESPLIEGUE CON VARIAS INSTANCIAS" en src/middleware/seguridad.js.
app.use(session(opcionesSesion())); // falla al arrancar si el secreto es inseguro en producción
app.use(verificarOrigen);

app.use(exposeCurrentUser);

// --- Rutas ---------------------------------------------------------------
app.use('/', authRoutes);
app.use('/productos', productoRoutes);
app.use('/clientes', clienteRoutes);
app.use('/inventario', inventarioRoutes);
app.use('/furgones', furgonRoutes);
app.use('/ingresos', ingresoRoutes);
app.use('/pedidos', pedidoRoutes);
app.use('/kardex', kardexRoutes);
app.use('/reportes', reporteRoutes);
app.use('/empleados', empleadoRoutes);
app.use('/usuarios', usuarioRoutes);
app.use('/catalogos', catalogoRoutes);

app.get('/', requireAuth, (req, res) => {
  res.render('home');
});

// --- Manejo de errores (siempre al final) ---------------------------------
app.use(notFoundHandler);
app.use(errorHandler);

const PORT = process.env.WEB_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Pavanamoon web escuchando en http://localhost:${PORT}`);
});

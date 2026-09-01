// =============================================================================
// Archivo:      server.js
// Descripción:  Punto de entrada de la aplicación web Pavanamoon (Entrega 2).
//               Configura Express, sesiones, EJS, y monta las rutas de
//               autenticación y de los 2 módulos CRUD (Producto, Cliente).
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

const authRoutes = require('./src/routes/authRoutes');
const productoRoutes = require('./src/routes/productoRoutes');
const clienteRoutes = require('./src/routes/clienteRoutes');

const app = express();

// --- Configuración de vistas -------------------------------------------------
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// --- Middlewares globales ----------------------------------------------------
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(methodOverride('_method')); // permite <input name="_method" value="PUT|DELETE"> en formularios HTML
app.use(express.static(path.join(__dirname, 'public')));

app.use(
  session({
    secret: process.env.SESSION_SECRET || 'dev-secret-change-me',
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 1000 * 60 * 60 * 4 }, // 4 horas
  })
);

app.use(exposeCurrentUser);

// --- Rutas ---------------------------------------------------------------
app.use('/', authRoutes);
app.use('/productos', productoRoutes);
app.use('/clientes', clienteRoutes);

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

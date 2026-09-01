// =============================================================================
// Archivo:      src/routes/authRoutes.js
// Descripción:  Rutas de autenticación (RF20). Compara la contraseña con
//               bcrypt (nunca en texto plano) y guarda en sesión solo los
//               datos necesarios para la UI (nada sensible como el hash).
// Dependencias: src/models/usuarioModel.js, bcryptjs, express-session
// =============================================================================

const express = require('express');
const bcrypt = require('bcryptjs');
const usuarioModel = require('../models/usuarioModel');

const router = express.Router();

router.get('/login', (req, res) => {
  if (req.session.usuario) return res.redirect('/');
  res.render('login', { error: null });
});

router.post('/login', async (req, res, next) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).render('login', { error: 'Usuario y contraseña son obligatorios.' });
    }

    const usuario = await usuarioModel.buscarPorUsername(username.trim());

    if (!usuario || usuario.estado !== 'activo') {
      return res.status(401).render('login', { error: 'Credenciales inválidas.' });
    }

    const passwordValida = await bcrypt.compare(password, usuario.password_hash);
    if (!passwordValida) {
      return res.status(401).render('login', { error: 'Credenciales inválidas.' });
    }

    // Solo guardamos en sesión lo necesario para la UI; nunca el hash.
    req.session.usuario = {
      usuario_id: usuario.usuario_id,
      username: usuario.username,
      nombre_completo: usuario.nombres, // nombres_apellidos ya viene completo desde la BD
      rol: usuario.nombre_rol,
    };

    res.redirect('/');
  } catch (err) {
    next(err);
  }
});

router.post('/logout', (req, res, next) => {
  req.session.destroy((err) => {
    if (err) return next(err);
    res.redirect('/login');
  });
});

module.exports = router;

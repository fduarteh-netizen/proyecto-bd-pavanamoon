// =============================================================================
// Archivo:      src/routes/authRoutes.js
// Descripción:  Rutas de autenticación (RF20). Compara la contraseña con
//               bcrypt (nunca en texto plano) y guarda en sesión solo los
//               datos necesarios para la UI (nada sensible como el hash).
//               Lote 5 (seguridad):
//                 - límite de intentos fallidos (usuario+IP y por IP), 429;
//                 - la sesión se REGENERA al iniciar sesión: un id de sesión
//                   obtenido antes del login no sirve después (fijación);
//                 - si el usuario no existe se compara igual contra un hash
//                   ficticio, para que el tiempo de respuesta no revele qué
//                   usuarios existen;
//                 - al salir se destruye la sesión y se borra la cookie.
// Dependencias: src/models/usuarioModel.js, src/middleware/seguridad.js,
//               bcryptjs, express-session
// =============================================================================

const express = require('express');
const bcrypt = require('bcryptjs');
const usuarioModel = require('../models/usuarioModel');
const { limitadorLogin, NOMBRE_COOKIE } = require('../middleware/seguridad');

const router = express.Router();

// Hash de una contraseña aleatoria: solo sirve para gastar el mismo tiempo
// de bcrypt cuando el usuario no existe.
const HASH_FICTICIO = bcrypt.hashSync(require('crypto').randomBytes(16).toString('hex'), 10);
const CREDENCIALES_INVALIDAS = 'Credenciales inválidas.';

router.get('/login', (req, res) => {
  if (req.session.usuario) return res.redirect('/');
  const error = req.query.motivo === 'inactivo'
    ? 'Tu usuario fue desactivado por un administrador. Comunícate con él para recuperar el acceso.'
    : null;
  res.render('login', { error });
});

router.post('/login', async (req, res, next) => {
  try {
    const username = typeof req.body.username === 'string' ? req.body.username.trim() : '';
    const password = typeof req.body.password === 'string' ? req.body.password : '';

    if (!username || !password) {
      return res.status(400).render('login', { error: 'Usuario y contraseña son obligatorios.' });
    }

    const espera = limitadorLogin.segundosBloqueado(req.ip, username);
    if (espera > 0) {
      res.set('Retry-After', String(espera));
      return res.status(429).render('login', {
        error: `Demasiados intentos fallidos. Espera ${Math.ceil(espera / 60)} minuto(s) e inténtalo de nuevo.`,
      });
    }

    const usuario = await usuarioModel.buscarPorUsername(username);
    // Siempre se ejecuta bcrypt (con un hash ficticio si el usuario no existe).
    const passwordValida = await bcrypt.compare(password, usuario ? usuario.password_hash : HASH_FICTICIO);

    if (!usuario || !passwordValida || usuario.estado !== 'activo') {
      limitadorLogin.registrarFallo(req.ip, username);
      return res.status(401).render('login', { error: CREDENCIALES_INVALIDAS });
    }

    limitadorLogin.registrarExito(req.ip, username);

    // Nueva sesión (nuevo id) antes de guardar los datos del usuario.
    req.session.regenerate((err) => {
      if (err) return next(err);
      // Solo guardamos en sesión lo necesario para la UI; nunca el hash.
      req.session.usuario = {
        usuario_id: usuario.usuario_id,
        empleado_id: usuario.empleado_id, // responsable de pedidos/ingresos (Entrega 3)
        username: usuario.username,
        nombre_completo: usuario.nombres, // nombres_apellidos ya viene completo desde la BD
        rol: usuario.nombre_rol,
      };
      req.session.save((errGuardar) => {
        if (errGuardar) return next(errGuardar);
        res.redirect('/');
      });
    });
  } catch (err) {
    next(err);
  }
});

router.post('/logout', (req, res, next) => {
  req.session.destroy((err) => {
    if (err) return next(err);
    res.clearCookie(NOMBRE_COOKIE);
    res.redirect('/login');
  });
});

module.exports = router;

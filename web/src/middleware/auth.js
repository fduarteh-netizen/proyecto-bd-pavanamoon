// =============================================================================
// Archivo:      src/middleware/auth.js
// Descripción:  Middleware de autenticación (RF20) y helper para exponer el
//               usuario logueado a todas las vistas. El control de acceso
//               por rol (RF21) se completará en Entrega 3 cuando existan
//               más de dos módulos con permisos diferenciados; por ahora
//               solo se exige "estar autenticado" para entrar a /productos
//               y /clientes (estándar A2: no exponer rutas sin control).
// Dependencias: express-session (configurado en server.js)
// =============================================================================

function requireAuth(req, res, next) {
  if (req.session && req.session.usuario) {
    return next();
  }
  return res.redirect('/login');
}

// Hace disponible res.locals.usuarioActual en todas las plantillas EJS,
// para poder mostrar "Bienvenido, <nombre>" en el layout sin repetir código.
function exposeCurrentUser(req, res, next) {
  res.locals.usuarioActual = (req.session && req.session.usuario) || null;
  next();
}

module.exports = { requireAuth, exposeCurrentUser };

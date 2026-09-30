// =============================================================================
// Archivo:      src/middleware/auth.js
// Descripción:  Autenticación (RF20) y control de acceso por rol (RF21,
//               Entrega 3). requireRole(clave) consulta la matriz de
//               src/config/permisos.js y responde 403 si el rol del usuario
//               en sesión no tiene acceso al módulo. exposeCurrentUser deja
//               el usuario y sus módulos permitidos disponibles en las vistas
//               (menú y tarjetas filtrados por rol).
// Dependencias: express-session (server.js), src/config/permisos.js
// =============================================================================

const { rolesDe, modulosPermitidos } = require('../config/permisos');

function requireAuth(req, res, next) {
  if (req.session && req.session.usuario) {
    return next();
  }
  return res.redirect('/login');
}

// Uso: router.use(requireRole('pedidos'))
function requireRole(claveModulo) {
  return function verificarRol(req, res, next) {
    const usuario = req.session && req.session.usuario;
    if (!usuario) return res.redirect('/login');
    if (rolesDe(claveModulo).includes(usuario.rol)) return next();
    return res.status(403).render('error', {
      titulo: 'Acceso denegado',
      mensaje: `Tu rol (${usuario.rol}) no tiene permiso para acceder a este módulo.`,
    });
  };
}

function exposeCurrentUser(req, res, next) {
  const usuario = (req.session && req.session.usuario) || null;
  res.locals.usuarioActual = usuario;
  res.locals.modulosMenu = usuario ? modulosPermitidos(usuario.rol) : [];
  next();
}

module.exports = { requireAuth, requireRole, exposeCurrentUser };

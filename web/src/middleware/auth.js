// =============================================================================
// Archivo:      src/middleware/auth.js
// Descripción:  Autenticación (RF20) y control de acceso por rol (RF21,
//               Entrega 3). requireRole(clave) consulta la matriz de
//               src/config/permisos.js y responde 403 si el rol del usuario
//               en sesión no tiene acceso al módulo. exposeCurrentUser deja
//               el usuario y sus módulos permitidos disponibles en las vistas
//               (menú y tarjetas filtrados por rol).
//               Entrega 4: exposeCurrentUser vuelve a leer de la BD el estado
//               y el rol del usuario en cada petición. Si un administrador lo
//               desactiva, su sesión se cierra en la siguiente petición; si
//               le cambia el rol, los permisos nuevos aplican de inmediato.
// Dependencias: express-session (server.js), src/config/permisos.js,
//               src/models/usuarioModel.js
// =============================================================================

const { rolesDe, modulosPermitidos } = require('../config/permisos');
const usuarioModel = require('../models/usuarioModel');

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

async function exposeCurrentUser(req, res, next) {
  try {
    const usuario = (req.session && req.session.usuario) || null;
    if (usuario) {
      const vigente = await usuarioModel.estadoActual(usuario.usuario_id);
      if (!vigente || vigente.estado !== 'activo') {
        // Desactivado o eliminado mientras tenía la sesión abierta.
        return req.session.destroy(() => res.redirect('/login?motivo=inactivo'));
      }
      usuario.rol = vigente.nombre_rol; // el rol pudo cambiar desde el login
    }
    res.locals.usuarioActual = usuario;
    res.locals.modulosMenu = usuario ? modulosPermitidos(usuario.rol) : [];
    next();
  } catch (err) {
    next(err);
  }
}

module.exports = { requireAuth, requireRole, exposeCurrentUser };

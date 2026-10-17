// =============================================================================
// Archivo:      src/routes/usuarioRoutes.js
// Descripción:  Administración de usuarios (Entrega 4, RF19, solo
//               administrador). Reglas de negocio que se validan aquí:
//                 1) un administrador no puede desactivarse, quitarse el rol
//                    de administrador ni eliminarse a sí mismo (evita que se
//                    bloquee el acceso por error);
//                 2) el sistema nunca se queda sin al menos un
//                    administrador activo.
//               El username y el empleado no se editan después del alta.
// Dependencias: usuarioModel, empleadoModel, validate, auth
// =============================================================================

const express = require('express');
const usuarioModel = require('../models/usuarioModel');
const empleadoModel = require('../models/empleadoModel');
const { validarUsuario } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth, requireRole('usuarios'));

/** Catálogos que necesita el formulario. */
async function datosFormulario() {
  const [roles, empleadosLibres] = await Promise.all([
    usuarioModel.listarRoles(),
    empleadoModel.listarSinUsuario(),
  ]);
  return { roles, empleadosLibres };
}

async function renderForm(res, { usuario, errores = [], status = 200 }) {
  res.status(status).render('usuarios/form', { usuario, errores, ...(await datosFormulario()) });
}

async function renderLista(req, res, { mensaje = null, error = null, status = 200 } = {}) {
  res.status(status).render('usuarios/list', { usuarios: await usuarioModel.listar(), mensaje, error });
}

/**
 * Aplica las reglas 1 y 2 al cambio que se quiere hacer sobre `actual`.
 * `cambio` = { rolNuevo, estadoNuevo } o { eliminar: true }.
 * Devuelve un mensaje de error o null si el cambio es válido.
 */
async function verificarReglasAdmin(req, actual, roles, cambio) {
  const rolAdmin = roles.find((r) => r.nombre_rol === 'administrador');
  const esAdminActivo = actual.rol_id === rolAdmin.rol_id && actual.estado === 'activo';
  const dejaDeSerAdminActivo = cambio.eliminar
    || Number(cambio.rolNuevo) !== rolAdmin.rol_id
    || cambio.estadoNuevo !== 'activo';

  if (!esAdminActivo || !dejaDeSerAdminActivo) return null;

  if (actual.usuario_id === req.session.usuario.usuario_id) {
    return 'No puedes desactivarte, quitarte el rol de administrador ni eliminar tu propio usuario.';
  }
  if ((await usuarioModel.contarOtrosAdminsActivos(actual.usuario_id)) === 0) {
    return 'Debe quedar al menos un administrador activo en el sistema.';
  }
  return null;
}

router.get('/', async (req, res, next) => {
  try {
    await renderLista(req, res, { mensaje: req.query.ok || null });
  } catch (err) {
    next(err);
  }
});

router.get('/nuevo', async (req, res, next) => {
  try {
    await renderForm(res, { usuario: { estado: 'activo' } });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const errores = validarUsuario(req.body, { esNuevo: true });
    if (errores.length) return renderForm(res, { usuario: req.body, errores, status: 400 });
    await usuarioModel.crear(req.body);
    res.redirect('/usuarios?ok=Usuario+creado');
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      // uq_usuario_username o uq_usuario_empleado (1 usuario por empleado)
      return renderForm(res, {
        usuario: req.body, status: 400,
        errores: ['Ese nombre de usuario ya existe, o el empleado ya tiene un usuario.'],
      });
    }
    next(err);
  }
});

router.get('/:id/editar', async (req, res, next) => {
  try {
    const usuario = await usuarioModel.buscarPorId(req.params.id);
    if (!usuario) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Usuario no encontrado.' });
    await renderForm(res, { usuario });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const actual = await usuarioModel.buscarPorId(req.params.id);
    if (!actual) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Usuario no encontrado.' });

    const formulario = { ...actual, rol_id: Number(req.body.rol_id), estado: req.body.estado };
    const errores = validarUsuario(req.body, { esNuevo: false });
    if (!errores.length) {
      const roles = await usuarioModel.listarRoles();
      const regla = await verificarReglasAdmin(req, actual, roles, {
        rolNuevo: req.body.rol_id, estadoNuevo: req.body.estado,
      });
      if (regla) errores.push(regla);
    }
    if (errores.length) return renderForm(res, { usuario: formulario, errores, status: 400 });

    await usuarioModel.actualizar(req.params.id, req.body);
    res.redirect('/usuarios?ok=Usuario+actualizado');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const actual = await usuarioModel.buscarPorId(req.params.id);
    if (!actual) return res.redirect('/usuarios');
    const roles = await usuarioModel.listarRoles();
    const regla = actual.usuario_id === req.session.usuario.usuario_id
      ? 'No puedes eliminar tu propio usuario.'
      : await verificarReglasAdmin(req, actual, roles, { eliminar: true });
    if (regla) return renderLista(req, res, { error: regla, status: 409 });

    await usuarioModel.eliminar(req.params.id);
    res.redirect('/usuarios?ok=Usuario+eliminado');
  } catch (err) {
    next(err);
  }
});

module.exports = router;

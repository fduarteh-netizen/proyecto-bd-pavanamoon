// =============================================================================
// Archivo:      src/routes/empleadoRoutes.js
// Descripción:  CRUD del módulo Empleados (Entrega 4, solo administrador).
//               Rutas delgadas: validan (A3) y delegan al modelo (A1).
// Dependencias: empleadoModel, validate, auth
// =============================================================================

const express = require('express');
const empleadoModel = require('../models/empleadoModel');
const { validarEmpleado, extraerTelefonos } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth, requireRole('empleados'));

/** Renderiza el listado con un mensaje opcional (éxito o error de negocio). */
async function renderLista(req, res, { mensaje = null, error = null, status = 200 } = {}) {
  const buscar = (req.query.buscar || '').trim().slice(0, 60);
  const empleados = await empleadoModel.listar({ buscar });
  res.status(status).render('empleados/list', { empleados, buscar, mensaje, error });
}

router.get('/', async (req, res, next) => {
  try {
    await renderLista(req, res, { mensaje: req.query.ok || null });
  } catch (err) {
    next(err);
  }
});

router.get('/nuevo', (req, res) => {
  res.render('empleados/form', { empleado: null, errores: [] });
});

router.post('/', async (req, res, next) => {
  try {
    const errores = validarEmpleado(req.body);
    if (errores.length) return res.status(400).render('empleados/form', { empleado: req.body, errores });
    await empleadoModel.crear({ ...req.body, telefonos: extraerTelefonos(req.body.telefonos) });
    res.redirect('/empleados?ok=Empleado+registrado');
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(400).render('empleados/form', { empleado: req.body, errores: ['Ya existe un empleado con ese DPI.'] });
    }
    next(err);
  }
});

router.get('/:id/editar', async (req, res, next) => {
  try {
    const empleado = await empleadoModel.buscarPorId(req.params.id);
    if (!empleado) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Empleado no encontrado.' });
    res.render('empleados/form', { empleado, errores: [] });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  const empleado = { ...req.body, empleado_id: req.params.id };
  try {
    const errores = validarEmpleado(req.body);
    if (errores.length) return res.status(400).render('empleados/form', { empleado, errores });
    await empleadoModel.actualizar(req.params.id, { ...req.body, telefonos: extraerTelefonos(req.body.telefonos) });
    res.redirect('/empleados?ok=Empleado+actualizado');
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(400).render('empleados/form', { empleado, errores: ['Ya existe otro empleado con ese DPI.'] });
    }
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const ref = await empleadoModel.contarReferencias(req.params.id);
    const motivos = [];
    if (ref.usuario) motivos.push('tiene un usuario del sistema');
    if (ref.pedidos) motivos.push(`atendió ${ref.pedidos} pedido(s)`);
    if (ref.ingresos) motivos.push(`registró ${ref.ingresos} ingreso(s)`);
    if (ref.movimientos) motivos.push(`aparece en ${ref.movimientos} movimiento(s) del kardex`);
    if (motivos.length) {
      return renderLista(req, res, {
        status: 409,
        error: `No se puede eliminar: el empleado ${motivos.join(', ')}. ` +
               'Para que deje de operar, desactiva su usuario en el módulo Usuarios (el historial se conserva).',
      });
    }
    await empleadoModel.eliminar(req.params.id);
    res.redirect('/empleados?ok=Empleado+eliminado');
  } catch (err) {
    next(err);
  }
});

module.exports = router;

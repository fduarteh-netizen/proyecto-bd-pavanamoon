// =============================================================================
// Archivo: src/routes/clienteRoutes.js
// CRUD de clientes + varios teléfonos (en cliente_telefono, 1FN).
// =============================================================================
const express = require('express');
const clienteModel = require('../models/clienteModel');
const catalogoModel = require('../models/catalogoModel');
const { validarCliente, extraerTelefonos } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth, requireRole('clientes'));

function idValido(id) {
  return /^\d+$/.test(String(id)) && Number.isSafeInteger(Number(id)) && Number(id) > 0;
}

async function formulario(res, cliente, errores = [], status = 200) {
  const tiposCliente = await catalogoModel.listarTiposCliente();
  res.status(status).render('clientes/form', { cliente, tiposCliente, errores });
}

async function listado(req, res, { mensaje = null, error = null, status = 200 } = {}) {
  const clientes = await clienteModel.listarTodos();
  res.status(status).render('clientes/list', { clientes, mensaje, error });
}

router.get('/', async (req, res, next) => {
  try { await listado(req, res, { mensaje: typeof req.query.ok === 'string' ? req.query.ok : null }); }
  catch (err) { next(err); }
});

router.get('/nuevo', async (req, res, next) => {
  try { await formulario(res, null); } catch (err) { next(err); }
});

router.post('/', async (req, res, next) => {
  try {
    const errores = validarCliente(req.body);
    if (errores.length) return await formulario(res, req.body, errores, 400);
    await clienteModel.crear({ ...req.body, telefonos: extraerTelefonos(req.body.telefonos ?? req.body.telefono) });
    res.redirect('/clientes?ok=Cliente+creado');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return formulario(res, req.body, ['Ya existe otro cliente con ese NIT o teléfono repetido.'], 409).catch(next);
    if (err.code === 'ER_NO_REFERENCED_ROW_2') return formulario(res, req.body, ['El tipo de cliente seleccionado no existe.'], 400).catch(next);
    next(err);
  }
});

router.get('/:id/editar', async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Cliente no encontrado.' });
    const cliente = await clienteModel.buscarPorId(req.params.id);
    if (!cliente) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Cliente no encontrado.' });
    await formulario(res, cliente);
  } catch (err) { next(err); }
});

router.put('/:id', async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Cliente no encontrado.' });
    const edicion = { ...req.body, cliente_id: req.params.id };
    const errores = validarCliente(req.body);
    if (errores.length) return await formulario(res, edicion, errores, 400);
    const actualizado = await clienteModel.actualizar(req.params.id, {
      ...req.body, telefonos: extraerTelefonos(req.body.telefonos ?? req.body.telefono),
    });
    if (!actualizado) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Cliente no encontrado.' });
    res.redirect('/clientes?ok=Cliente+actualizado');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return formulario(res, { ...req.body, cliente_id: req.params.id }, ['Ya existe otro cliente con ese NIT o teléfono repetido.'], 409).catch(next);
    if (err.code === 'ER_NO_REFERENCED_ROW_2') return formulario(res, { ...req.body, cliente_id: req.params.id }, ['El tipo de cliente seleccionado no existe.'], 400).catch(next);
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Cliente no encontrado.' });
    if (await clienteModel.contarPedidos(req.params.id)) {
      return await listado(req, res, { status: 409, error: 'No se puede eliminar este cliente porque tiene pedidos. Debemos conservar el historial de ventas.' });
    }
    const eliminado = await clienteModel.eliminar(req.params.id);
    if (!eliminado) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Cliente no encontrado.' });
    res.redirect('/clientes?ok=Cliente+eliminado');
  } catch (err) {
    if (err.code === 'ER_ROW_IS_REFERENCED_2') return listado(req, res, { status: 409, error: 'El cliente está relacionado con pedidos y no se puede eliminar.' }).catch(next);
    next(err);
  }
});

module.exports = router;

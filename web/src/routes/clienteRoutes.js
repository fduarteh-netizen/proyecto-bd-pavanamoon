// =============================================================================
// Archivo:      src/routes/clienteRoutes.js
// Descripción:  Rutas CRUD del módulo Cliente (2 de los 2 módulos exigidos
//               para el 30% de avance de la Entrega 2).
// Dependencias: src/models/clienteModel.js, src/utils/validate.js,
//               src/middleware/auth.js
// =============================================================================

const express = require('express');
const clienteModel = require('../models/clienteModel');
const catalogoModel = require('../models/catalogoModel');
const { validarCliente } = require('../utils/validate');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth);

router.get('/', async (req, res, next) => {
  try {
    const clientes = await clienteModel.listarTodos();
    res.render('clientes/list', { clientes });
  } catch (err) {
    next(err);
  }
});

router.get('/nuevo', async (req, res, next) => {
  try {
    const tiposCliente = await catalogoModel.listarTiposCliente();
    res.render('clientes/form', { cliente: null, tiposCliente, errores: [] });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const errores = validarCliente(req.body);
    if (errores.length) {
      const tiposCliente = await catalogoModel.listarTiposCliente();
      return res.status(400).render('clientes/form', { cliente: req.body, tiposCliente, errores });
    }
    await clienteModel.crear(req.body);
    res.redirect('/clientes');
  } catch (err) {
    next(err);
  }
});

router.get('/:id/editar', async (req, res, next) => {
  try {
    const cliente = await clienteModel.buscarPorId(req.params.id);
    if (!cliente) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Cliente no encontrado.' });
    const tiposCliente = await catalogoModel.listarTiposCliente();
    res.render('clientes/form', { cliente, tiposCliente, errores: [] });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const errores = validarCliente(req.body);
    if (errores.length) {
      const tiposCliente = await catalogoModel.listarTiposCliente();
      return res.status(400).render('clientes/form', {
        cliente: { ...req.body, cliente_id: req.params.id },
        tiposCliente,
        errores,
      });
    }
    await clienteModel.actualizar(req.params.id, req.body);
    res.redirect('/clientes');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await clienteModel.eliminar(req.params.id);
    res.redirect('/clientes');
  } catch (err) {
    next(err);
  }
});

module.exports = router;

// =============================================================================
// Archivo:      src/routes/furgonRoutes.js
// Descripción:  CRUD del módulo Furgones (RF06). Rutas delgadas: validan y
//               delegan al modelo (A1, A5).
// Dependencias: furgonModel, validate, auth
// =============================================================================

const express = require('express');
const furgonModel = require('../models/furgonModel');
const { validarFurgon } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth, requireRole('furgones'));

router.get('/', async (req, res, next) => {
  try {
    res.render('furgones/list', { furgones: await furgonModel.listarTodos() });
  } catch (err) {
    next(err);
  }
});

router.get('/nuevo', (req, res) => {
  res.render('furgones/form', { furgon: null, errores: [] });
});

router.post('/', async (req, res, next) => {
  try {
    const errores = validarFurgon(req.body);
    if (errores.length) return res.status(400).render('furgones/form', { furgon: req.body, errores });
    await furgonModel.crear(req.body);
    res.redirect('/furgones');
  } catch (err) {
    next(err);
  }
});

router.get('/:id/editar', async (req, res, next) => {
  try {
    const furgon = await furgonModel.buscarPorId(req.params.id);
    if (!furgon) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Furgón no encontrado.' });
    res.render('furgones/form', { furgon, errores: [] });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const errores = validarFurgon(req.body);
    if (errores.length) {
      return res.status(400).render('furgones/form', { furgon: { ...req.body, furgon_id: req.params.id }, errores });
    }
    await furgonModel.actualizar(req.params.id, req.body);
    res.redirect('/furgones');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await furgonModel.eliminar(req.params.id);
    res.redirect('/furgones');
  } catch (err) {
    next(err);
  }
});

module.exports = router;

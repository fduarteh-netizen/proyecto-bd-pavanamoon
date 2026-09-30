// =============================================================================
// Archivo:      src/routes/kardexRoutes.js
// Descripción:  Consulta del kardex (RF16, RF18) con filtros por SKU y rango
//               de fechas. Solo lectura.
// Dependencias: kardexModel, auth
// =============================================================================

const express = require('express');
const kardexModel = require('../models/kardexModel');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
const FECHA = /^\d{4}-\d{2}-\d{2}$/;

router.use(requireAuth, requireRole('kardex'));

router.get('/', async (req, res, next) => {
  try {
    const filtros = {
      sku: (req.query.sku || '').trim().slice(0, 40),
      desde: FECHA.test(req.query.desde || '') ? req.query.desde : '',
      hasta: FECHA.test(req.query.hasta || '') ? req.query.hasta : '',
    };
    res.render('kardex/list', { movimientos: await kardexModel.listar(filtros), filtros });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

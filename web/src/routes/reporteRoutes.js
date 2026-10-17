// =============================================================================
// Archivo:      src/routes/reporteRoutes.js
// Descripción:  Módulo Reportes (Entrega 4, solo administrador): ventas por
//               periodo y ranking de modelos. Solo lectura. Los parámetros de
//               la URL se validan contra formato o lista blanca antes de
//               llegar al modelo (A3).
// Dependencias: reporteModel, auth
// =============================================================================

const express = require('express');
const reporteModel = require('../models/reporteModel');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
const FECHA = /^\d{4}-\d{2}-\d{2}$/;
const LIMITES = [5, 10, 20, 50];

router.use(requireAuth, requireRole('reportes'));

router.get('/', async (req, res, next) => {
  try {
    const rango = {
      desde: FECHA.test(req.query.desde || '') ? req.query.desde : '',
      hasta: FECHA.test(req.query.hasta || '') ? req.query.hasta : '',
    };
    const limite = LIMITES.includes(Number(req.query.limite)) ? Number(req.query.limite) : 10;
    const orden = req.query.orden === 'menos' ? 'menos' : 'mas';

    const errores = [];
    if (rango.desde && rango.hasta && rango.desde > rango.hasta) {
      errores.push('La fecha "desde" no puede ser posterior a "hasta".');
    }

    const [resumen, porMes, porDia, modelos] = errores.length
      ? [null, [], [], []]
      : await Promise.all([
          reporteModel.resumenVentas(rango),
          reporteModel.ventasPorMes(rango),
          reporteModel.ventasPorDia(rango),
          reporteModel.rankingModelos({ limite, orden }),
        ]);

    res.render('reportes/index', {
      filtros: { ...rango, limite, orden }, limites: LIMITES, errores, resumen, porMes, porDia, modelos,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

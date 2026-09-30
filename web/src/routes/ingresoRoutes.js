// =============================================================================
// Archivo:      src/routes/ingresoRoutes.js
// Descripción:  Módulo Ingresos de mercadería (RF07-RF09). El responsable
//               del ingreso es el empleado del usuario en sesión (no se
//               elige en el formulario, evita suplantación).
// Dependencias: ingresoModel, furgonModel, varianteModel, validate, auth
// =============================================================================

const express = require('express');
const ingresoModel = require('../models/ingresoModel');
const furgonModel = require('../models/furgonModel');
const varianteModel = require('../models/varianteModel');
const { validarIngreso, extraerLineas } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
const FILAS_FORMULARIO = 5;

router.use(requireAuth, requireRole('ingresos'));

router.get('/', async (req, res, next) => {
  try {
    res.render('ingresos/list', { ingresos: await ingresoModel.listar() });
  } catch (err) {
    next(err);
  }
});

router.get('/nuevo', async (req, res, next) => {
  try {
    res.render('ingresos/form', { ...(await cargarCatalogos()), datos: {}, errores: [], filas: FILAS_FORMULARIO });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const lineas = extraerLineas(req.body, 'variante_id');
    const errores = validarIngreso(req.body, lineas);
    if (errores.length) {
      return res.status(400).render('ingresos/form', {
        ...(await cargarCatalogos()), datos: req.body, errores, filas: FILAS_FORMULARIO,
      });
    }
    const id = await ingresoModel.crear({
      furgon_id: req.body.furgon_id,
      bodega_destino: req.body.bodega_destino.trim(),
      empleado_id: req.session.usuario.empleado_id,
      lineas,
    });
    res.redirect(`/ingresos/${id}`);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const ingreso = await ingresoModel.buscarDetalle(req.params.id);
    if (!ingreso) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Ingreso no encontrado.' });
    res.render('ingresos/detalle', { ingreso });
  } catch (err) {
    next(err);
  }
});

async function cargarCatalogos() {
  const [furgones, variantes] = await Promise.all([furgonModel.listarRecibidos(), varianteModel.listarTodasSimple()]);
  return { furgones, variantes };
}

module.exports = router;

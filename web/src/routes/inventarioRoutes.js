// =============================================================================
// Archivo: src/routes/inventarioRoutes.js
// Consulta: todos los roles autorizados; escritura: administrador/bodeguero.
// =============================================================================
const express = require('express');
const varianteModel = require('../models/varianteModel');
const catalogoModel = require('../models/catalogoModel');
const { validarVariante } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth, requireRole('inventario'));

function idValido(id) {
  return /^\d+$/.test(String(id)) && Number.isSafeInteger(Number(id)) && Number(id) > 0;
}

async function cargarCatalogos() {
  const [productos, tallas, colores] = await Promise.all([
    catalogoModel.listarProductosSimple(),
    catalogoModel.listarTallas(),
    catalogoModel.listarColores(),
  ]);
  return { productos, tallas, colores };
}

async function formulario(res, variante, errores = [], status = 200) {
  res.status(status).render('inventario/form', { ...(await cargarCatalogos()), variante, errores });
}

async function listado(req, res, { mensaje = null, error = null, status = 200 } = {}) {
  const soloAlertas = req.query.alertas === '1';
  const busqueda = typeof req.query.q === 'string' ? req.query.q.trim().slice(0, 50) : '';
  const variantes = await varianteModel.listar({ soloAlertas, busqueda });
  res.status(status).render('inventario/list', { variantes, soloAlertas, busqueda, mensaje, error });
}

router.get('/', async (req, res, next) => {
  try { await listado(req, res, { mensaje: typeof req.query.ok === 'string' ? req.query.ok : null }); }
  catch (err) { next(err); }
});

router.get('/nueva', requireRole('productos'), async (req, res, next) => {
  try { await formulario(res, null); } catch (err) { next(err); }
});

router.post('/', requireRole('productos'), async (req, res, next) => {
  try {
    const errores = validarVariante(req.body);
    if (errores.length) return await formulario(res, req.body, errores, 400);
    await varianteModel.crear(req.body);
    res.redirect('/inventario?ok=Variante+creada');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return formulario(res, req.body, ['Ya existe una variante con esa combinación de producto, talla y color.'], 409).catch(next);
    if (err.code === 'ER_NO_REFERENCED_ROW_2') return formulario(res, req.body, ['Selecciona un producto, talla y color existentes.'], 400).catch(next);
    next(err);
  }
});

router.get('/:id/editar', requireRole('productos'), async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Variante no encontrada.' });
    const variante = await varianteModel.buscarPorId(req.params.id);
    if (!variante) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Variante no encontrada.' });
    await formulario(res, variante);
  } catch (err) { next(err); }
});

router.put('/:id', requireRole('productos'), async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Variante no encontrada.' });
    const actual = await varianteModel.buscarPorId(req.params.id);
    if (!actual) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Variante no encontrada.' });
    const errores = validarVariante(req.body);
    const edicion = { ...actual, ...req.body, variante_id: actual.variante_id, identidadBloqueada: actual.identidadBloqueada };
    if (errores.length) return await formulario(res, edicion, errores, 400);
    await varianteModel.actualizar(req.params.id, req.body);
    res.redirect('/inventario?ok=Variante+actualizada');
  } catch (err) {
    if (['VARIANTE_BLOQUEADA', 'ER_DUP_ENTRY', 'ER_NO_REFERENCED_ROW_2'].includes(err.code)) {
      const actual = await varianteModel.buscarPorId(req.params.id).catch(() => null);
      const mensaje = err.code === 'ER_DUP_ENTRY' ? 'Ya existe una variante con esa combinación de producto, talla y color.'
        : err.code === 'ER_NO_REFERENCED_ROW_2' ? 'Selecciona un producto, talla y color existentes.' : err.message;
      if (actual) return formulario(res, { ...actual, ...req.body, variante_id: actual.variante_id, identidadBloqueada: actual.identidadBloqueada }, [mensaje], 409).catch(next);
    }
    next(err);
  }
});

router.delete('/:id', requireRole('productos'), async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Variante no encontrada.' });
    const eliminado = await varianteModel.eliminar(req.params.id);
    if (!eliminado) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Variante no encontrada.' });
    res.redirect('/inventario?ok=Variante+eliminada');
  } catch (err) {
    if (['VARIANTE_BLOQUEADA', 'ER_ROW_IS_REFERENCED_2'].includes(err.code)) {
      return listado(req, res, {
        status: 409,
        error: err.code === 'VARIANTE_BLOQUEADA' ? err.message : 'Esta variante tiene registros relacionados y no puede eliminarse.',
      }).catch(next);
    }
    next(err);
  }
});

module.exports = router;

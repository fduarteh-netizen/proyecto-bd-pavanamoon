// =============================================================================
// Archivo:      src/routes/inventarioRoutes.js
// Descripción:  Módulo Inventario (RF02-RF04): listado de stock por variante
//               con filtro de alertas, y alta de variantes. El vendedor
//               solo puede consultar; crear variantes es de bodega/admin.
// Dependencias: varianteModel, catalogoModel, validate, auth
// =============================================================================

const express = require('express');
const varianteModel = require('../models/varianteModel');
const catalogoModel = require('../models/catalogoModel');
const { validarVariante } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth, requireRole('inventario'));

router.get('/', async (req, res, next) => {
  try {
    const soloAlertas = req.query.alertas === '1';
    const busqueda = (req.query.q || '').trim().slice(0, 50);
    const variantes = await varianteModel.listar({ soloAlertas, busqueda });
    res.render('inventario/list', { variantes, soloAlertas, busqueda });
  } catch (err) {
    next(err);
  }
});

// Crear variantes: mismo permiso que el módulo Productos (admin, bodeguero).
router.get('/nueva', requireRole('productos'), async (req, res, next) => {
  try {
    res.render('inventario/form', { ...(await cargarCatalogos()), variante: null, errores: [] });
  } catch (err) {
    next(err);
  }
});

router.post('/', requireRole('productos'), async (req, res, next) => {
  try {
    const errores = validarVariante(req.body);
    if (errores.length) {
      return res.status(400).render('inventario/form', { ...(await cargarCatalogos()), variante: req.body, errores });
    }
    await varianteModel.crear(req.body);
    res.redirect('/inventario');
  } catch (err) {
    next(err);
  }
});

async function cargarCatalogos() {
  const [productos, tallas, colores] = await Promise.all([
    catalogoModel.listarProductosSimple(),
    catalogoModel.listarTallas(),
    catalogoModel.listarColores(),
  ]);
  return { productos, tallas, colores };
}

module.exports = router;

// =============================================================================
// Archivo:      src/routes/productoRoutes.js
// Descripción:  Rutas CRUD del módulo Producto (1 de los 2 módulos exigidos
//               para el 30% de avance de la Entrega 2). Las rutas son
//               "delgadas": validan entrada y delegan el acceso a datos al
//               modelo (estándar A1/A5, responsabilidad única).
// Dependencias: src/models/productoModel.js, src/models/catalogoModel.js,
//               src/utils/validate.js, src/middleware/auth.js
// =============================================================================

const express = require('express');
const productoModel = require('../models/productoModel');
const catalogoModel = require('../models/catalogoModel');
const { validarProducto } = require('../utils/validate');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth);

router.get('/', async (req, res, next) => {
  try {
    const productos = await productoModel.listarTodos();
    res.render('productos/list', { productos });
  } catch (err) {
    next(err);
  }
});

router.get('/nuevo', async (req, res, next) => {
  try {
    const categorias = await catalogoModel.listarCategorias();
    res.render('productos/form', { producto: null, categorias, errores: [] });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const errores = validarProducto(req.body);
    if (errores.length) {
      const categorias = await catalogoModel.listarCategorias();
      return res.status(400).render('productos/form', { producto: req.body, categorias, errores });
    }
    await productoModel.crear(req.body);
    res.redirect('/productos');
  } catch (err) {
    next(err);
  }
});

router.get('/:id/editar', async (req, res, next) => {
  try {
    const producto = await productoModel.buscarPorId(req.params.id);
    if (!producto) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Producto no encontrado.' });
    const categorias = await catalogoModel.listarCategorias();
    res.render('productos/form', { producto, categorias, errores: [] });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const errores = validarProducto(req.body);
    if (errores.length) {
      const categorias = await catalogoModel.listarCategorias();
      return res.status(400).render('productos/form', {
        producto: { ...req.body, producto_id: req.params.id },
        categorias,
        errores,
      });
    }
    await productoModel.actualizar(req.params.id, req.body);
    res.redirect('/productos');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await productoModel.eliminar(req.params.id);
    res.redirect('/productos');
  } catch (err) {
    next(err);
  }
});

module.exports = router;

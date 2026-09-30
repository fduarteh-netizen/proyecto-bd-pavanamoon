// =============================================================================
// Archivo:      src/routes/pedidoRoutes.js
// Descripción:  Módulo Pedidos (RF11-RF14, RF17). El vendedor responsable es
//               el empleado del usuario en sesión. El precio NO viaja desde
//               el formulario: lo calcula la BD (fn_calcular_precio_linea).
// Dependencias: pedidoModel, catalogoModel, varianteModel, validate, auth
// =============================================================================

const express = require('express');
const pedidoModel = require('../models/pedidoModel');
const catalogoModel = require('../models/catalogoModel');
const varianteModel = require('../models/varianteModel');
const { validarPedido, extraerLineas, esEnteroPositivo } = require('../utils/validate');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
const FILAS_FORMULARIO = 5;

router.use(requireAuth, requireRole('pedidos'));

router.get('/', async (req, res, next) => {
  try {
    const clienteId = esEnteroPositivo(req.query.cliente) ? Number(req.query.cliente) : null;
    const [pedidos, clientes] = await Promise.all([pedidoModel.listar({ clienteId }), catalogoModel.listarClientesSimple()]);
    res.render('pedidos/list', { pedidos, clientes, clienteId });
  } catch (err) {
    next(err);
  }
});

router.get('/nuevo', async (req, res, next) => {
  try {
    res.render('pedidos/form', { ...(await cargarCatalogos()), datos: {}, errores: [], filas: FILAS_FORMULARIO });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  const lineas = extraerLineas(req.body, 'variante_id');
  const errores = validarPedido(req.body, lineas);
  try {
    if (errores.length) {
      return res.status(400).render('pedidos/form', {
        ...(await cargarCatalogos()), datos: req.body, errores, filas: FILAS_FORMULARIO,
      });
    }
    const id = await pedidoModel.crear({
      cliente_id: req.body.cliente_id,
      empleado_id: req.session.usuario.empleado_id,
      lineas,
    });
    res.redirect(`/pedidos/${id}`);
  } catch (err) {
    // Reglas de negocio de triggers/procedimientos (SIGNAL 45000): se
    // muestran en el mismo formulario para que el vendedor corrija.
    if (err && err.sqlState === '45000') {
      return res.status(400).render('pedidos/form', {
        ...(await cargarCatalogos()), datos: req.body, errores: [err.sqlMessage], filas: FILAS_FORMULARIO,
      });
    }
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const pedido = await pedidoModel.buscarDetalle(req.params.id);
    if (!pedido) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Pedido no encontrado.' });
    res.render('pedidos/detalle', { pedido, mensaje: req.query.ok || null, error: null });
  } catch (err) {
    next(err);
  }
});

router.post('/:id/completar', async (req, res, next) => {
  try {
    await pedidoModel.completar(req.params.id);
    res.redirect(`/pedidos/${req.params.id}?ok=Pedido+completado`);
  } catch (err) {
    next(err);
  }
});

router.post('/:id/devolucion', async (req, res, next) => {
  try {
    await pedidoModel.registrarDevolucion({
      pedido_id: req.params.id,
      variante_id: req.body.variante_id,
      pares: Number(req.body.pares),
      empleado_id: req.session.usuario.empleado_id,
    });
    res.redirect(`/pedidos/${req.params.id}?ok=Devoluci%C3%B3n+registrada`);
  } catch (err) {
    if (err && err.sqlState === '45000') {
      const pedido = await pedidoModel.buscarDetalle(req.params.id);
      return res.status(400).render('pedidos/detalle', { pedido, mensaje: null, error: err.sqlMessage });
    }
    next(err);
  }
});

async function cargarCatalogos() {
  const [clientes, variantes, presentaciones] = await Promise.all([
    catalogoModel.listarClientesSimple(),
    varianteModel.listarDisponibles(),
    catalogoModel.listarPresentaciones(),
  ]);
  return { clientes, variantes, presentaciones };
}

module.exports = router;

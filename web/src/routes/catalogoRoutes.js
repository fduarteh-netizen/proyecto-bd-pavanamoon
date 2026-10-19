// =============================================================================
// Archivo:      src/routes/catalogoRoutes.js
// Descripción:  Módulo Catálogos (Entrega 4, solo administrador): CRUD de
//               categorías, tallas, colores, tipos de cliente y presentaciones
//               de venta, con una sola ruta parametrizada por :clave (la
//               clave solo se acepta si existe en catalogoAdminModel.CATALOGOS).
//
// Reglas de negocio que se validan aquí:
//   1) No se borra un registro en uso (FK RESTRICT): se explica cuántos
//      registros lo usan. Para presentaciones se sugiere desactivarla.
//   2) Presentación usada en pedidos: NO se puede cambiar cantidad_pares.
//      Los triggers, sp_registrar_devolucion, sp_cancelar_pedido y las vistas
//      de reportes recalculan los pares con la cantidad_pares ACTUAL; si
//      cambiara, cancelar o devolver un pedido viejo movería un número de
//      pares distinto al que salió del inventario. Sí se puede renombrar o
//      desactivar (la presentación inactiva deja de ofrecerse en pedidos
//      nuevos, pero los pedidos existentes la conservan).
//   3) Siempre debe quedar al menos una presentación activa (sin ella no se
//      pueden registrar pedidos).
//   4) Categoría: solo nino/juvenil/adulto (ck_categoria_nombre).
//   5) Cambiar el % de descuento de un tipo de cliente solo afecta pedidos
//      futuros: detalle_pedido guarda el precio_unitario calculado al vender.
// Dependencias: catalogoAdminModel, validateCatalogo, auth
// =============================================================================

const express = require('express');
const catalogoAdminModel = require('../models/catalogoAdminModel');
const { validarCatalogo, CATEGORIAS_PERMITIDAS } = require('../utils/validateCatalogo');
const { requireAuth, requireRole } = require('../middleware/auth');

const router = express.Router();
const { CATALOGOS } = catalogoAdminModel;

router.use(requireAuth, requireRole('catalogos'));

// El id debe ser un entero positivo: MySQL convertiría '1 OR 1=1' en 1 y
// abriría otro registro (no es inyección porque va parametrizado, pero sí
// una entrada inválida que no debe llegar a la BD, A3).
router.param('id', (req, res, next, id) => {
  if (!/^[1-9]\d{0,9}$/.test(id)) {
    return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Registro no encontrado.' });
  }
  next();
});

/** Responde 404 si la clave no es un catálogo conocido; si existe, devuelve su definición. */
function obtenerDefinicion(req, res) {
  const def = catalogoAdminModel.definicion(req.params.clave);
  if (!def) {
    res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Ese catálogo no existe.' });
  }
  return def;
}

/** Traduce errores de MySQL a mensajes comprensibles (A2). Devuelve null si no lo reconoce. */
function mensajeErrorBD(err, def) {
  if (!err) return null;
  if (err.code === 'ER_DUP_ENTRY') return `Ya existe un registro de ${def.singular} con ese nombre o valor.`;
  if (err.code === 'ER_ROW_IS_REFERENCED_2') return `No se puede eliminar: la ${def.singular} está en uso.`;
  if (err.code === 'ER_CHECK_CONSTRAINT_VIOLATED') return 'El valor no cumple las reglas del catálogo.';
  return null;
}

async function renderLista(req, res, def, { mensaje = null, error = null, status = 200 } = {}) {
  const registros = await catalogoAdminModel.listar(def);
  res.status(status).render('catalogos/list', {
    catalogos: CATALOGOS, clave: req.params.clave, def, registros, mensaje, error,
  });
}

async function renderForm(req, res, def, { registro, errores = [], status = 200 }) {
  // Categoría: el <select> ofrece solo los valores permitidos que aún no existen.
  let categoriasDisponibles = [];
  if (req.params.clave === 'categorias') {
    const usadas = await catalogoAdminModel.categoriasExistentes(registro && registro[def.pk] ? registro[def.pk] : 0);
    categoriasDisponibles = CATEGORIAS_PERMITIDAS.filter((c) => !usadas.includes(c));
  }
  res.status(status).render('catalogos/form', {
    catalogos: CATALOGOS, clave: req.params.clave, def, registro, errores, categoriasDisponibles,
  });
}

/** Reglas 2 y 3 (presentaciones). `actual` es null en altas. Devuelve lista de errores. */
async function reglasPresentacion(actual, datos) {
  const errores = [];
  if (actual && Number(actual.uso) > 0 && Number(actual.cantidad_pares) !== datos.cantidad_pares) {
    errores.push(
      `No se puede cambiar la cantidad de pares: esta presentación ya se usó en ${actual.uso} línea(s) de pedido ` +
      'y las devoluciones, cancelaciones y reportes dependen de ella. Crea una presentación nueva con la cantidad que necesitas.'
    );
  }
  const desactiva = actual && actual.estado === 'activo' && datos.estado === 'inactivo';
  if (desactiva && (await catalogoAdminModel.contarOtrasPresentacionesActivas(actual.presentacion_id)) === 0) {
    errores.push('Debe quedar al menos una presentación activa; sin ella no se pueden registrar pedidos.');
  }
  return errores;
}

router.get('/', (req, res) => res.redirect('/catalogos/categorias'));

router.get('/:clave', async (req, res, next) => {
  try {
    const def = obtenerDefinicion(req, res);
    if (!def) return;
    await renderLista(req, res, def, { mensaje: req.query.ok || null });
  } catch (err) {
    next(err);
  }
});

router.get('/:clave/nuevo', async (req, res, next) => {
  try {
    const def = obtenerDefinicion(req, res);
    if (!def) return;
    await renderForm(req, res, def, { registro: req.params.clave === 'presentaciones' ? { estado: 'activo' } : null });
  } catch (err) {
    next(err);
  }
});

router.post('/:clave', async (req, res, next) => {
  const def = catalogoAdminModel.definicion(req.params.clave);
  try {
    if (!obtenerDefinicion(req, res)) return;
    const { errores, datos } = validarCatalogo(req.params.clave, req.body);
    if (errores.length) return renderForm(req, res, def, { registro: req.body, errores, status: 400 });
    await catalogoAdminModel.crear(def, datos);
    res.redirect(`/catalogos/${req.params.clave}?ok=Registro+creado`);
  } catch (err) {
    const mensaje = mensajeErrorBD(err, def);
    if (mensaje) return renderForm(req, res, def, { registro: req.body, errores: [mensaje], status: 400 });
    next(err);
  }
});

router.get('/:clave/:id/editar', async (req, res, next) => {
  try {
    const def = obtenerDefinicion(req, res);
    if (!def) return;
    const registro = await catalogoAdminModel.buscarPorId(def, req.params.id);
    if (!registro) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Registro no encontrado.' });
    await renderForm(req, res, def, { registro });
  } catch (err) {
    next(err);
  }
});

router.put('/:clave/:id', async (req, res, next) => {
  const def = catalogoAdminModel.definicion(req.params.clave);
  try {
    if (!obtenerDefinicion(req, res)) return;
    const actual = await catalogoAdminModel.buscarPorId(def, req.params.id);
    if (!actual) return res.status(404).render('error', { titulo: 'No encontrado', mensaje: 'Registro no encontrado.' });

    const { errores, datos } = validarCatalogo(req.params.clave, req.body);
    if (!errores.length && req.params.clave === 'presentaciones') {
      errores.push(...(await reglasPresentacion(actual, datos)));
    }
    const formulario = { ...actual, ...req.body };
    if (errores.length) return renderForm(req, res, def, { registro: formulario, errores, status: 400 });

    await catalogoAdminModel.actualizar(def, req.params.id, datos);
    res.redirect(`/catalogos/${req.params.clave}?ok=Registro+actualizado`);
  } catch (err) {
    const mensaje = mensajeErrorBD(err, def);
    if (mensaje) {
      return renderForm(req, res, def, {
        registro: { ...req.body, [def.pk]: req.params.id }, errores: [mensaje], status: 400,
      });
    }
    next(err);
  }
});

router.delete('/:clave/:id', async (req, res, next) => {
  const def = catalogoAdminModel.definicion(req.params.clave);
  try {
    if (!obtenerDefinicion(req, res)) return;
    const actual = await catalogoAdminModel.buscarPorId(def, req.params.id);
    if (!actual) return res.redirect(`/catalogos/${req.params.clave}`);

    const uso = await catalogoAdminModel.detalleUso(def, req.params.id);
    if (uso.length) {
      const sugerencia = req.params.clave === 'presentaciones'
        ? ' Para que deje de ofrecerse sin perder el historial, edítala y cámbiala a inactiva.'
        : '';
      return renderLista(req, res, def, {
        status: 409,
        error: `No se puede eliminar "${actual[def.campos[0]]}": la usan ${uso.join(' y ')}.${sugerencia}`,
      });
    }
    if (req.params.clave === 'presentaciones' && actual.estado === 'activo'
        && (await catalogoAdminModel.contarOtrasPresentacionesActivas(actual.presentacion_id)) === 0) {
      return renderLista(req, res, def, {
        status: 409, error: 'Debe quedar al menos una presentación activa; sin ella no se pueden registrar pedidos.',
      });
    }

    await catalogoAdminModel.eliminar(def, req.params.id);
    res.redirect(`/catalogos/${req.params.clave}?ok=Registro+eliminado`);
  } catch (err) {
    const mensaje = mensajeErrorBD(err, def);
    if (mensaje) return renderLista(req, res, def, { status: 409, error: mensaje });
    next(err);
  }
});

module.exports = router;

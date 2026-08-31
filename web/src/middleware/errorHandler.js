// =============================================================================
// Archivo:      src/middleware/errorHandler.js
// Descripción:  Manejo centralizado de errores (estándar A2): nunca se
//               exponen mensajes de error SQL crudos ni stack traces al
//               usuario final; se registran en consola (log del servidor)
//               y se muestra una vista genérica y comprensible.
// Dependencias: views/error.ejs
// =============================================================================

function notFoundHandler(req, res) {
  res.status(404).render('error', {
    titulo: 'Página no encontrada',
    mensaje: 'La página o el recurso que buscas no existe.',
  });
}

// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  console.error('[ERROR]', new Date().toISOString(), err);

  let mensaje = 'Ocurrió un error inesperado. Intenta nuevamente.';

  // Traducimos algunos códigos de MySQL comunes a mensajes entendibles,
  // sin filtrar el detalle técnico del motor de base de datos.
  if (err && err.code === 'ER_DUP_ENTRY') {
    mensaje = 'Ya existe un registro con ese valor único (NIT, SKU, username, etc.).';
  } else if (err && err.code === 'ER_ROW_IS_REFERENCED_2') {
    mensaje = 'No se puede eliminar: este registro está referenciado por otros datos.';
  } else if (err && err.code && err.code.startsWith('ER_')) {
    mensaje = 'No se pudo completar la operación por una restricción de la base de datos.';
  }

  res.status(500).render('error', {
    titulo: 'Error del servidor',
    mensaje,
  });
}

module.exports = { notFoundHandler, errorHandler };

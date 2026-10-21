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
  let status = 500;

  // Traducimos algunos códigos de MySQL comunes a mensajes entendibles,
  // sin filtrar el detalle técnico del motor de base de datos.
  if (err && err.sqlState === '45000') {
    // Mensaje de regla de negocio escrito por el equipo en un SIGNAL de un
    // trigger/procedimiento (ej. "Stock insuficiente..."): es seguro
    // mostrarlo porque no contiene detalle técnico del motor.
    mensaje = err.sqlMessage;
  } else if (err && (err.code === 'ER_LOCK_DEADLOCK' || err.code === 'ER_LOCK_WAIT_TIMEOUT')) {
    // Dos operaciones simultáneas sobre los mismos registros (Entrega 4).
    // Este manejador es genérico y NO sabe si la ruta usaba una transacción,
    // así que no afirma que "no se guardó nada":
    //  - ER_LOCK_DEADLOCK: MySQL revierte la transacción víctima, pero si la
    //    ruta hizo pasos previos fuera de una transacción, esos quedan.
    //  - ER_LOCK_WAIT_TIMEOUT: con innodb_rollback_on_timeout=OFF (valor por
    //    defecto) MySQL revierte solo la ÚLTIMA sentencia, no la transacción.
    //    Los modelos que usan transacción (pedidos, ingresos, empleados,
    //    clientes, variantes) hacen ROLLBACK en su catch, pero eso no se
    //    puede garantizar aquí para cualquier ruta.
    status = 409;
    mensaje = err.code === 'ER_LOCK_DEADLOCK'
      ? 'La operación coincidió con otra que modificaba los mismos datos y la base de datos la canceló. ' +
        'Revisa si el cambio quedó registrado antes de intentarlo de nuevo.'
      : 'La operación esperó demasiado a que terminara otra sobre los mismos datos y no se completó. ' +
        'Revisa si el cambio quedó registrado antes de intentarlo de nuevo.';
  } else if (err && err.code === 'ER_DUP_ENTRY') {
    mensaje = 'Ya existe un registro con ese valor único (NIT, SKU, username, etc.).';
  } else if (err && err.code === 'ER_ROW_IS_REFERENCED_2') {
    mensaje = 'No se puede eliminar: este registro está referenciado por otros datos.';
  } else if (err && err.code && err.code.startsWith('ER_')) {
    mensaje = 'No se pudo completar la operación por una restricción de la base de datos.';
  }

  res.status(status).render('error', {
    titulo: 'Error del servidor',
    mensaje,
  });
}

module.exports = { notFoundHandler, errorHandler };

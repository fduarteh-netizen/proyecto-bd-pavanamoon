// =============================================================================
// Archivo:      src/utils/validate.js
// Descripción:  Validaciones de entrada reutilizables (estándar A3). Se
//               aplican antes de tocar la base de datos, además de las
//               restricciones CHECK/NOT NULL/UNIQUE definidas en el DDL
//               (defensa en profundidad: la app valida por experiencia de
//               usuario, la BD valida como última línea de defensa).
// =============================================================================

function esTextoNoVacio(valor, maxLength = 255) {
  return typeof valor === 'string' && valor.trim().length > 0 && valor.trim().length <= maxLength;
}

function esDecimalPositivo(valor) {
  const n = Number(valor);
  return Number.isFinite(n) && n > 0;
}

function esNIT(valor) {
  return typeof valor === 'string' && /^[0-9Kk-]{4,15}$/.test(valor.trim());
}

function validarProducto(body) {
  const errores = [];
  if (!body.categoria_id) errores.push('Debes seleccionar una categoría.');
  if (!esTextoNoVacio(body.modelo, 100)) errores.push('El modelo es obligatorio (máx. 100 caracteres).');
  if (!['hule', 'flex', 'tpu'].includes(body.tipo_suela)) errores.push('Debes seleccionar un tipo de suela válido.');
  if (!esDecimalPositivo(body.precio_venta)) errores.push('El precio de venta debe ser un número mayor a 0.');
  return errores;
}

function validarCliente(body) {
  const errores = [];
  if (!body.tipo_cliente_id) errores.push('Debes seleccionar un tipo de cliente.');
  if (!esTextoNoVacio(body.nombre_cliente, 150)) errores.push('El nombre del cliente es obligatorio.');
  if (!esNIT(body.nit)) errores.push('El NIT no tiene un formato válido.');
  return errores;
}

module.exports = { validarProducto, validarCliente };

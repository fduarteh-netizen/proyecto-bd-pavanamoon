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

function esEnteroPositivo(valor) {
  const n = Number(valor);
  return Number.isInteger(n) && n > 0;
}

function esFecha(valor) {
  return typeof valor === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(valor) && !Number.isNaN(Date.parse(valor));
}

/**
 * Convierte las filas del formulario (lineas[i][campo]) en un arreglo,
 * descartando las filas vacías. Se usa en pedidos e ingresos.
 */
function extraerLineas(body, campoClave) {
  const crudas = body.lineas ? Object.values(body.lineas) : [];
  return crudas.filter((l) => l && l[campoClave]);
}

function validarVariante(body) {
  const errores = [];
  if (!esEnteroPositivo(body.producto_id)) errores.push('Debes seleccionar un producto.');
  if (!esEnteroPositivo(body.talla_id)) errores.push('Debes seleccionar una talla.');
  if (!esEnteroPositivo(body.color_id)) errores.push('Debes seleccionar un color.');
  const minimo = Number(body.stock_minimo);
  if (!Number.isInteger(minimo) || minimo < 0) errores.push('El stock mínimo debe ser un entero mayor o igual a 0.');
  return errores;
}

function validarFurgon(body) {
  const errores = [];
  if (!esTextoNoVacio(body.numero_furgon, 30)) errores.push('El número de furgón es obligatorio (máx. 30 caracteres).');
  if (!esFecha(body.fecha_llegada)) errores.push('La fecha de llegada no es válida.');
  if (!['en_transito', 'recibido', 'cancelado'].includes(body.estado)) errores.push('Estado de furgón inválido.');
  return errores;
}

function validarIngreso(body, lineas) {
  const errores = [];
  if (!esEnteroPositivo(body.furgon_id)) errores.push('Debes seleccionar un furgón.');
  if (!esTextoNoVacio(body.bodega_destino, 60)) errores.push('La bodega de destino es obligatoria.');
  if (lineas.length === 0) errores.push('Agrega al menos una línea de mercadería.');
  const vistas = new Set();
  lineas.forEach((l, i) => {
    if (!esEnteroPositivo(l.cantidad)) errores.push(`Línea ${i + 1}: la cantidad debe ser un entero mayor a 0.`);
    if (!esDecimalPositivo(l.costo_unitario)) errores.push(`Línea ${i + 1}: el costo unitario debe ser mayor a 0.`);
    if (vistas.has(l.variante_id)) errores.push(`Línea ${i + 1}: la variante está repetida.`);
    vistas.add(l.variante_id);
  });
  return errores;
}

function validarPedido(body, lineas) {
  const errores = [];
  if (!esEnteroPositivo(body.cliente_id)) errores.push('Debes seleccionar un cliente.');
  if (lineas.length === 0) errores.push('Agrega al menos un producto al pedido.');
  const vistas = new Set();
  lineas.forEach((l, i) => {
    if (!esEnteroPositivo(l.presentacion_id)) errores.push(`Línea ${i + 1}: selecciona la presentación.`);
    if (!esEnteroPositivo(l.cantidad)) errores.push(`Línea ${i + 1}: la cantidad debe ser un entero mayor a 0.`);
    if (vistas.has(l.variante_id)) errores.push(`Línea ${i + 1}: la variante está repetida.`);
    vistas.add(l.variante_id);
  });
  return errores;
}

module.exports = {
  validarProducto,
  validarCliente,
  validarVariante,
  validarFurgon,
  validarIngreso,
  validarPedido,
  extraerLineas,
  esEnteroPositivo,
};

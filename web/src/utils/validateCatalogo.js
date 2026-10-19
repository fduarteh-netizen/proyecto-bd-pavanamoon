// =============================================================================
// Archivo:      src/utils/validateCatalogo.js
// Descripción:  Validación y normalización de los formularios del módulo
//               Catálogos (Entrega 4, A3). Cada validador devuelve
//               { errores, datos }: `datos` trae los valores ya limpios
//               (trim, minúsculas, números) listos para el modelo.
//               Las reglas replican las restricciones de la BD para dar un
//               mensaje claro ANTES de llegar a MySQL:
//                 - categoria: ck_categoria_nombre (solo nino/juvenil/adulto)
//                 - tipo_cliente: ck_tipo_cliente_descuento (0 a 50)
//                 - presentacion_venta: ck_presentacion_cantidad (> 0)
//               Se normaliza a minúsculas porque los datos existentes están
//               así y la intercalación de MySQL ya trata "Rojo" = "rojo" como
//               duplicado (UNIQUE); así la lista se ve uniforme.
// Dependencias: ninguna
// =============================================================================

const CATEGORIAS_PERMITIDAS = ['nino', 'juvenil', 'adulto'];
const ESTADOS = ['activo', 'inactivo'];
const SOLO_LETRAS = /^[a-záéíóúüñ ]+$/;

/** trim + espacios internos simples + minúsculas. */
function normalizarTexto(valor) {
  return typeof valor === 'string' ? valor.trim().replace(/\s+/g, ' ').toLowerCase() : '';
}

function validarCategoria(body) {
  let nombre = normalizarTexto(body.nombre_categoria);
  if (nombre === 'niño' || nombre === 'ninos' || nombre === 'niños') nombre = 'nino';
  const errores = CATEGORIAS_PERMITIDAS.includes(nombre)
    ? []
    : ['La categoría debe ser nino, juvenil o adulto (regla de negocio: clasificación por edad, ck_categoria_nombre).'];
  return { errores, datos: { nombre_categoria: nombre } };
}

function validarTalla(body) {
  const valor = typeof body.valor_talla === 'string' ? body.valor_talla.trim().replace(',', '.') : '';
  const errores = [];
  if (!/^\d{2}(\.5)?$/.test(valor) || Number(valor) < 15 || Number(valor) > 50) {
    errores.push('La talla debe ser un número entre 15 y 50 (se permite media talla, ej. 38.5).');
  }
  return { errores, datos: { valor_talla: valor } };
}

function validarColor(body) {
  const nombre = normalizarTexto(body.nombre_color);
  const errores = [];
  if (nombre.length < 3 || nombre.length > 40 || !SOLO_LETRAS.test(nombre)) {
    errores.push('El color debe tener de 3 a 40 letras (sin números ni símbolos).');
  }
  return { errores, datos: { nombre_color: nombre } };
}

function validarTipoCliente(body) {
  const nombre = normalizarTexto(body.nombre);
  const descripcion = typeof body.descripcion === 'string' ? body.descripcion.trim() : '';
  const textoDescuento = typeof body.porcentaje_descuento === 'string'
    ? body.porcentaje_descuento.trim().replace(',', '.')
    : '';
  const errores = [];
  if (nombre.length < 3 || nombre.length > 50 || !SOLO_LETRAS.test(nombre)) {
    errores.push('El nombre debe tener de 3 a 50 letras.');
  }
  if (descripcion.length > 255) errores.push('La descripción admite como máximo 255 caracteres.');
  if (!/^\d{1,2}(\.\d{1,2})?$/.test(textoDescuento) || Number(textoDescuento) > 50) {
    errores.push('El descuento debe ser un porcentaje entre 0 y 50, con máximo 2 decimales.');
  }
  return {
    errores,
    datos: { nombre, descripcion: descripcion || null, porcentaje_descuento: Number(textoDescuento) },
  };
}

function validarPresentacion(body) {
  const nombre = normalizarTexto(body.nombre);
  const cantidad = typeof body.cantidad_pares === 'string' ? body.cantidad_pares.trim() : String(body.cantidad_pares || '');
  const errores = [];
  if (nombre.length < 2 || nombre.length > 50 || !SOLO_LETRAS.test(nombre)) {
    errores.push('El nombre debe tener de 2 a 50 letras (ej. unidad, caja, media caja).');
  }
  if (!/^\d{1,4}$/.test(cantidad) || Number(cantidad) < 1 || Number(cantidad) > 1000) {
    errores.push('La cantidad de pares debe ser un entero entre 1 y 1000.');
  }
  if (!ESTADOS.includes(body.estado)) errores.push('El estado debe ser activo o inactivo.');
  return { errores, datos: { nombre, cantidad_pares: Number(cantidad), estado: body.estado } };
}

const VALIDADORES = {
  categorias: validarCategoria,
  tallas: validarTalla,
  colores: validarColor,
  'tipos-cliente': validarTipoCliente,
  presentaciones: validarPresentacion,
};

/** Valida el formulario del catálogo `clave`. */
function validarCatalogo(clave, body) {
  return VALIDADORES[clave](body || {});
}

module.exports = { validarCatalogo, CATEGORIAS_PERMITIDAS };

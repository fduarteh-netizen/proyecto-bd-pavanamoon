// =============================================================================
// Archivo:      src/models/catalogoAdminModel.js
// Descripción:  Administración (CRUD) de los 5 catálogos: categoria, talla,
//               color, tipo_cliente y presentacion_venta (Entrega 4).
//               No reemplaza a catalogoModel.js: ese archivo sigue siendo la
//               fuente de lectura para los <select> de otros módulos.
//
//   Seguridad (A4): los VALORES siempre viajan como parámetros (?). Los
//   nombres de tabla/columna salen exclusivamente de CATALOGOS (lista blanca
//   fija en este archivo); la ruta solo acepta claves que existan aquí, así
//   que nada que escriba el usuario llega a formar parte del SQL.
//
//   Integridad: todas las FK hacia estos catálogos son ON DELETE RESTRICT.
//   Antes de borrar se cuenta el uso (contarUso) para explicar el motivo;
//   si aun así la BD rechaza (ER_ROW_IS_REFERENCED_2), la ruta lo traduce.
// Dependencias: src/config/db.js
// =============================================================================

const pool = require('../config/db');

/**
 * Definición de cada catálogo. `campos` lista las columnas editables en el
 * orden del formulario; `usadoEn` son las tablas hijas (FK RESTRICT).
 */
const CATALOGOS = {
  categorias: {
    titulo: 'Categorías',
    singular: 'categoría',
    tabla: 'categoria',
    pk: 'categoria_id',
    orden: 'nombre_categoria',
    campos: ['nombre_categoria'],
    usadoEn: [{ tabla: 'producto', columna: 'categoria_id', etiqueta: 'producto(s)' }],
  },
  tallas: {
    titulo: 'Tallas',
    singular: 'talla',
    tabla: 'talla',
    pk: 'talla_id',
    orden: 'CAST(valor_talla AS DECIMAL(4,1))',
    campos: ['valor_talla'],
    usadoEn: [{ tabla: 'variante_producto', columna: 'talla_id', etiqueta: 'variante(s) de producto' }],
  },
  colores: {
    titulo: 'Colores',
    singular: 'color',
    tabla: 'color',
    pk: 'color_id',
    orden: 'nombre_color',
    campos: ['nombre_color'],
    usadoEn: [{ tabla: 'variante_producto', columna: 'color_id', etiqueta: 'variante(s) de producto' }],
  },
  'tipos-cliente': {
    titulo: 'Tipos de cliente',
    singular: 'tipo de cliente',
    tabla: 'tipo_cliente',
    pk: 'tipo_cliente_id',
    orden: 'nombre',
    campos: ['nombre', 'descripcion', 'porcentaje_descuento'],
    usadoEn: [{ tabla: 'cliente', columna: 'tipo_cliente_id', etiqueta: 'cliente(s)' }],
  },
  presentaciones: {
    titulo: 'Presentaciones de venta',
    singular: 'presentación',
    tabla: 'presentacion_venta',
    pk: 'presentacion_id',
    orden: 'cantidad_pares, nombre',
    campos: ['nombre', 'cantidad_pares', 'estado'],
    usadoEn: [{ tabla: 'detalle_pedido', columna: 'presentacion_id', etiqueta: 'línea(s) de pedido' }],
  },
};

/** Devuelve la definición del catálogo o null si la clave no existe. */
function definicion(clave) {
  return Object.prototype.hasOwnProperty.call(CATALOGOS, clave) ? CATALOGOS[clave] : null;
}

/** Subconsulta que suma el uso del registro en todas sus tablas hijas. */
function sqlUso(def, alias) {
  return def.usadoEn
    .map((u) => `(SELECT COUNT(*) FROM ${u.tabla} h WHERE h.${u.columna} = ${alias}.${def.pk})`)
    .join(' + ');
}

/** Lista el catálogo con una columna `uso` (cuántos registros lo usan). */
async function listar(def) {
  const [rows] = await pool.query(
    `SELECT c.*, ${sqlUso(def, 'c')} AS uso FROM ${def.tabla} c ORDER BY ${def.orden}`
  );
  return rows;
}

/** Busca un registro del catálogo `def` por su PK (tabla y columna salen de la lista blanca CATALOGOS; el id va parametrizado). */
async function buscarPorId(def, id) {
  const [rows] = await pool.query(
    `SELECT c.*, ${sqlUso(def, 'c')} AS uso FROM ${def.tabla} c WHERE c.${def.pk} = ?`,
    [id]
  );
  return rows[0] || null;
}

/** Detalle del uso por tabla hija, para explicar por qué no se puede borrar. */
async function detalleUso(def, id) {
  const partes = [];
  for (const u of def.usadoEn) {
    const [[fila]] = await pool.query(
      `SELECT COUNT(*) AS n FROM ${u.tabla} WHERE ${u.columna} = ?`,
      [id]
    );
    if (fila.n > 0) partes.push(`${fila.n} ${u.etiqueta}`);
  }
  return partes;
}

/** Inserta con los campos ya validados y normalizados (`datos`). */
async function crear(def, datos) {
  const columnas = def.campos.filter((c) => datos[c] !== undefined);
  const [result] = await pool.query(
    `INSERT INTO ${def.tabla} (${columnas.join(', ')}) VALUES (${columnas.map(() => '?').join(', ')})`,
    columnas.map((c) => datos[c])
  );
  return result.insertId;
}

/** Actualiza un registro del catálogo `def` con los campos permitidos por su definición (UPDATE parametrizado). */
async function actualizar(def, id, datos) {
  const columnas = def.campos.filter((c) => datos[c] !== undefined);
  await pool.query(
    `UPDATE ${def.tabla} SET ${columnas.map((c) => `${c} = ?`).join(', ')} WHERE ${def.pk} = ?`,
    [...columnas.map((c) => datos[c]), id]
  );
}

/** Elimina un registro del catálogo `def` (DELETE parametrizado; la FK impide borrar si está en uso). */
async function eliminar(def, id) {
  await pool.query(`DELETE FROM ${def.tabla} WHERE ${def.pk} = ?`, [id]);
}

/** Presentaciones activas distintas de `excluirId` (debe quedar al menos una). */
async function contarOtrasPresentacionesActivas(excluirId) {
  const [[fila]] = await pool.query(
    "SELECT COUNT(*) AS n FROM presentacion_venta WHERE estado = 'activo' AND presentacion_id <> ?",
    [excluirId]
  );
  return fila.n;
}

/** Valores de categoría ya usados (el CHECK solo admite nino/juvenil/adulto). */
async function categoriasExistentes(excluirId = 0) {
  const [rows] = await pool.query(
    'SELECT nombre_categoria FROM categoria WHERE categoria_id <> ?',
    [excluirId]
  );
  return rows.map((r) => r.nombre_categoria);
}

module.exports = {
  CATALOGOS,
  definicion,
  listar,
  buscarPorId,
  detalleUso,
  crear,
  actualizar,
  eliminar,
  contarOtrasPresentacionesActivas,
  categoriasExistentes,
};

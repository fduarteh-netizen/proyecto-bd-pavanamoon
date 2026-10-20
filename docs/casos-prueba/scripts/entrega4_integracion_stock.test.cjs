// =============================================================================
// Archivo:      entrega4_integracion_stock.test.cjs
// Autor:        Equipo Pavanamoon
// Descripción:  Pruebas de INTEGRACIÓN contra MySQL real (Entrega 4, Lote 5):
//               ingresos, pedidos simultáneos, devoluciones y cancelaciones
//               concurrentes, y la invariante "stock = suma del kardex".
//               Usa el código real de la app (src/models/*), no copias.
//
//   El stock NUNCA se escribe a mano: entra por un ingreso de mercadería
//   (trigger trg_detalle_ingreso_ai) y sale por pedidos (triggers de
//   detalle_pedido), igual que en la aplicación.
//
//   ESCRIBE DATOS, por eso SOLO corre contra una base de PRUEBA independiente,
//   creada con instalar_bd_prueba.cjs. Se exigen las tres condiciones:
//     1) $env:PVM_BD_PRUEBA con un nombre que termine en "_prueba", distinto
//        de "pavanamoon" y de DB_NAME de web/.env (la base de la app);
//     2) SELECT DATABASE() confirma que la conexión está en esa base;
//     3) la base contiene la tabla marcadora zz_bd_de_prueba, que solo crea
//        el instalador (una copia renombrada de la base real no la tiene).
//   Si falta PVM_BD_PRUEBA, las pruebas se omiten; si se define pero no se
//   cumple 1, 2 o 3, fallan sin escribir nada. Ya no existe
//   CONFIRMAR_BD_PRUEBA: una variable de confirmación no garantiza a qué
//   base se conecta.
//
//     PowerShell (desde la raíz del repo):
//       node docs/casos-prueba/scripts/instalar_bd_prueba.cjs     # una vez (ver ese archivo)
//       $env:PVM_BD_PRUEBA = "pavanamoon_prueba"
//       node --test docs/casos-prueba/scripts/entrega4_integracion_stock.test.cjs
//       Remove-Item Env:PVM_BD_PRUEBA
//   Usuario de conexión: DB_USER/DB_PASSWORD de web/.env (el instalador le da
//   permisos sobre la base de prueba), o $env:PVM_TEST_DB_USER / PVM_TEST_DB_PASSWORD.
// Dependencias: web/.env, web/node_modules, instalar_bd_prueba.cjs (base de
//               prueba con los scripts del Lote 5: sql/procedures/03 y
//               sql/triggers/02 con FOR UPDATE)
// =============================================================================
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const WEB = path.resolve(__dirname, '../../../web');
// Cargar web/.env explícitamente (db.js usa dotenv desde el directorio actual).
require(path.join(WEB, 'node_modules/dotenv')).config({ path: path.join(WEB, '.env') });
const { validarNombrePrueba, MARCADOR } = require('./instalar_bd_prueba.cjs');

const BD_APP = process.env.DB_NAME || 'pavanamoon'; // base habitual de la app
const BD_PRUEBA = process.env.PVM_BD_PRUEBA || '';
const ERROR_NOMBRE = BD_PRUEBA ? validarNombrePrueba(BD_PRUEBA, BD_APP) : null;
if (BD_PRUEBA && !ERROR_NOMBRE) {
  // db.js (y por lo tanto los modelos de la app) se conectarán SOLO a la base de prueba.
  process.env.DB_NAME = BD_PRUEBA;
  if (process.env.PVM_TEST_DB_USER) process.env.DB_USER = process.env.PVM_TEST_DB_USER;
  if (process.env.PVM_TEST_DB_PASSWORD !== undefined) process.env.DB_PASSWORD = process.env.PVM_TEST_DB_PASSWORD;
}
const modelo = (nombre) => require(path.join(WEB, 'src/models', nombre));

let pool, productoModel, varianteModel, furgonModel, ingresoModel, pedidoModel;
const ctx = {}; // datos creados por la prueba

/** Clasifica un error: 'negocio' (SIGNAL 45000), 'deadlock', 'espera' u 'otro'. */
function tipoError(err) {
  if (err && err.sqlState === '45000') return 'negocio';
  if (err && err.code === 'ER_LOCK_DEADLOCK') return 'deadlock';
  if (err && err.code === 'ER_LOCK_WAIT_TIMEOUT') return 'espera';
  return 'otro';
}

/** Ejecuta las promesas en paralelo y resume resultados por tipo. */
async function enParalelo(tareas) {
  const resultados = await Promise.allSettled(tareas.map((t) => t()));
  const resumen = { ok: 0, negocio: 0, deadlock: 0, espera: 0, otro: 0, mensajes: [], valores: [] };
  for (const r of resultados) {
    if (r.status === 'fulfilled') {
      resumen.ok += 1;
      resumen.valores.push(r.value);
    } else {
      const tipo = tipoError(r.reason);
      resumen[tipo] += 1;
      resumen.mensajes.push(`${tipo}: ${r.reason.sqlMessage || r.reason.message}`);
    }
  }
  return resumen;
}

async function stock(varianteId) {
  const [[fila]] = await pool.query('SELECT stock_actual FROM variante_producto WHERE variante_id = ?', [varianteId]);
  return fila.stock_actual;
}

async function sumaKardex(varianteId) {
  const [[fila]] = await pool.query(
    'SELECT COALESCE(SUM(efecto_stock), 0) AS s FROM vw_kardex WHERE variante_id = ?', [varianteId]
  );
  return Number(fila.s);
}

/** Pedido de una línea de `pares` pares (presentación de 1 par) de la variante. */
function pedidoDe(varianteId, pares) {
  return () => pedidoModel.crear({
    cliente_id: ctx.clienteId,
    empleado_id: ctx.empleadoId,
    lineas: [{ variante_id: varianteId, presentacion_id: ctx.presentacionUnidad, cantidad: pares }],
  });
}

function ingresoDe(lineas) {
  return () => ingresoModel.crear({
    furgon_id: ctx.furgonId, bodega_destino: 'Bodega prueba', empleado_id: ctx.empleadoId, lineas,
  });
}

const opciones = {
  skip: BD_PRUEBA ? false : 'Define $env:PVM_BD_PRUEBA con una base creada por instalar_bd_prueba.cjs.',
};

test.before(async () => {
  if (!BD_PRUEBA) return;
  // Condición 1: nombre (se valida ANTES de abrir cualquier conexión).
  if (ERROR_NOMBRE) throw new Error(`PVM_BD_PRUEBA rechazada: ${ERROR_NOMBRE} No se escribió nada.`);
  pool = require(path.join(WEB, 'src/config/db'));
  // Condición 2: la conexión realmente está en esa base.
  const [[{ bd }]] = await pool.query('SELECT DATABASE() AS bd');
  if (bd !== BD_PRUEBA) throw new Error(`Conectado a "${bd}" en vez de "${BD_PRUEBA}". No se escribió nada.`);
  // Condición 3: la base fue creada por el instalador de pruebas.
  const [[{ marcas }]] = await pool.query(
    'SELECT COUNT(*) AS marcas FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?', [bd, MARCADOR]
  );
  if (!marcas) throw new Error(`"${bd}" no tiene la tabla ${MARCADOR}: no es una base creada por instalar_bd_prueba.cjs. No se escribió nada.`);
  console.log(`  base de prueba verificada: ${bd}`);

  productoModel = modelo('productoModel');
  varianteModel = modelo('varianteModel');
  furgonModel = modelo('furgonModel');
  ingresoModel = modelo('ingresoModel');
  pedidoModel = modelo('pedidoModel');

  const marca = new Date().toISOString().replace(/\D/g, '').slice(0, 14) + '-' + require('node:crypto').randomBytes(2).toString('hex');
  const [[cat]] = await pool.query('SELECT MIN(categoria_id) AS id FROM categoria');
  const [[cli]] = await pool.query(
    "SELECT MIN(c.cliente_id) AS id FROM cliente c JOIN tipo_cliente t USING (tipo_cliente_id) WHERE t.nombre = 'individual'"
  );
  const [[emp]] = await pool.query(
    "SELECT MIN(u.empleado_id) AS id FROM usuario u WHERE u.estado = 'activo'"
  );
  const [[pres]] = await pool.query(
    "SELECT MIN(presentacion_id) AS id FROM presentacion_venta WHERE cantidad_pares = 1 AND estado = 'activo'"
  );
  const [tallas] = await pool.query('SELECT talla_id FROM talla ORDER BY talla_id LIMIT 2');
  const [[color]] = await pool.query('SELECT MIN(color_id) AS id FROM color');
  assert.ok(cat.id && cli.id && emp.id && pres.id && tallas.length === 2 && color.id, 'faltan datos semilla');

  Object.assign(ctx, { clienteId: cli.id, empleadoId: emp.id, presentacionUnidad: pres.id });
  ctx.productoId = await productoModel.crear({
    categoria_id: cat.id, modelo: `ZZ-PRUEBA-INTEGRACION ${marca}`, tipo_suela: 'tpu', precio_venta: 100,
  });
  ctx.varA = await varianteModel.crear({ producto_id: ctx.productoId, talla_id: tallas[0].talla_id, color_id: color.id, stock_minimo: 0 });
  ctx.varB = await varianteModel.crear({ producto_id: ctx.productoId, talla_id: tallas[1].talla_id, color_id: color.id, stock_minimo: 0 });
  ctx.furgonId = await furgonModel.crear({
    numero_furgon: `PRUEBA-${marca}`, fecha_llegada: new Date().toISOString().slice(0, 10),
    procedencia: 'Prueba automatizada', transportista: 'Prueba', estado: 'recibido',
  });
  console.log(`  datos de prueba: producto ${ctx.productoId}, variantes ${ctx.varA} y ${ctx.varB}, furgón ${ctx.furgonId}`);
});

test.after(async () => {
  if (pool) await pool.end();
});

test('INT-01 una variante nueva inicia en 0 y el ingreso suma stock y kardex', opciones, async () => {
  assert.equal(await stock(ctx.varA), 0);
  await ingresoDe([
    { variante_id: ctx.varA, cantidad: 10, costo_unitario: 50 },
    { variante_id: ctx.varB, cantidad: 10, costo_unitario: 50 },
  ])();
  assert.equal(await stock(ctx.varA), 10);
  assert.equal(await stock(ctx.varB), 10);
  assert.equal(await sumaKardex(ctx.varA), 10, 'el kardex debe registrar la entrada');
});

test('INT-02 cuatro ingresos simultáneos de la misma variante: todos se aplican, sin deadlock', opciones, async () => {
  const antes = await stock(ctx.varA);
  const r = await enParalelo(Array.from({ length: 4 }, () => ingresoDe([{ variante_id: ctx.varA, cantidad: 5, costo_unitario: 50 }])));
  assert.deepEqual({ ok: r.ok, deadlock: r.deadlock, otro: r.otro }, { ok: 4, deadlock: 0, otro: 0 }, r.mensajes.join(' | '));
  assert.equal(await stock(ctx.varA), antes + 20);
});

test('INT-03 seis pedidos simultáneos por más stock del que hay: no se sobrevende', opciones, async () => {
  const s = await stock(ctx.varA); // 30
  const pares = 7;
  const r = await enParalelo(Array.from({ length: 6 }, () => pedidoDe(ctx.varA, pares)));
  const esperados = Math.floor(s / pares);
  assert.equal(r.deadlock, 0, `no debe haber deadlocks: ${r.mensajes.join(' | ')}`);
  assert.equal(r.otro, 0, `errores técnicos inesperados: ${r.mensajes.join(' | ')}`);
  assert.equal(r.ok, esperados, `se esperaban ${esperados} ventas`);
  assert.equal(r.negocio, 6 - esperados);
  assert.ok(r.mensajes.every((m) => m.includes('Stock insuficiente')), r.mensajes.join(' | '));
  assert.equal(await stock(ctx.varA), s - esperados * pares);
  ctx.pedidosA = r.valores; // ids de pedidos creados
  // Los pedidos rechazados no dejan cabecera huérfana (todo fue una transacción).
  const [[{ n }]] = await pool.query(
    'SELECT COUNT(DISTINCT pedido_id) AS n FROM detalle_pedido WHERE variante_id = ?', [ctx.varA]
  );
  assert.equal(n, esperados);
});

test('INT-04 pedidos de varias líneas en orden opuesto (A,B contra B,A): sin deadlock', opciones, async () => {
  await ingresoDe([
    { variante_id: ctx.varA, cantidad: 20, costo_unitario: 50 },
    { variante_id: ctx.varB, cantidad: 20, costo_unitario: 50 },
  ])();
  const sa = await stock(ctx.varA);
  const sb = await stock(ctx.varB);
  const linea = (v) => ({ variante_id: v, presentacion_id: ctx.presentacionUnidad, cantidad: 1 });
  const tareas = [];
  for (let i = 0; i < 8; i += 1) {
    tareas.push(() => pedidoModel.crear({ cliente_id: ctx.clienteId, empleado_id: ctx.empleadoId, lineas: [linea(ctx.varA), linea(ctx.varB)] }));
    tareas.push(() => pedidoModel.crear({ cliente_id: ctx.clienteId, empleado_id: ctx.empleadoId, lineas: [linea(ctx.varB), linea(ctx.varA)] }));
  }
  const r = await enParalelo(tareas);
  assert.deepEqual({ ok: r.ok, deadlock: r.deadlock, otro: r.otro }, { ok: 16, deadlock: 0, otro: 0 }, r.mensajes.join(' | '));
  assert.equal(await stock(ctx.varA), sa - 16);
  assert.equal(await stock(ctx.varB), sb - 16);
});

test('INT-05 devolución: parcial, luego dos simultáneas por el resto (solo una pasa)', opciones, async () => {
  const pedidoId = ctx.pedidosA[0]; // 7 pares de A
  assert.equal(await pedidoModel.completar(pedidoId), true);
  const s0 = await stock(ctx.varA);
  const devolver = (pares) => () => pedidoModel.registrarDevolucion({
    pedido_id: pedidoId, variante_id: ctx.varA, pares, empleado_id: ctx.empleadoId,
  });

  await devolver(3)(); // quedan 4 por devolver
  const r = await enParalelo([devolver(4), devolver(4)]);
  assert.deepEqual({ ok: r.ok, negocio: r.negocio, deadlock: r.deadlock, otro: r.otro },
    { ok: 1, negocio: 1, deadlock: 0, otro: 0 }, r.mensajes.join(' | '));
  await assert.rejects(devolver(1)(), (err) => tipoError(err) === 'negocio', 'ya no queda nada por devolver');
  assert.equal(await stock(ctx.varA), s0 + 7, 'se devuelven exactamente los 7 pares vendidos');
});

test('INT-06 dos cancelaciones simultáneas del mismo pedido: el stock vuelve una sola vez', opciones, async () => {
  const pedidoId = ctx.pedidosA[1]; // 7 pares de A, pendiente
  const s0 = await stock(ctx.varA);
  const cancelar = () => pedidoModel.cancelar(pedidoId, ctx.empleadoId);
  const r = await enParalelo([cancelar, cancelar]);
  assert.deepEqual({ ok: r.ok, negocio: r.negocio, deadlock: r.deadlock, otro: r.otro },
    { ok: 1, negocio: 1, deadlock: 0, otro: 0 }, r.mensajes.join(' | '));
  assert.equal(await stock(ctx.varA), s0 + 7);
  await assert.rejects(pedidoModel.cancelar(ctx.pedidosA[0], ctx.empleadoId),
    (err) => tipoError(err) === 'negocio', 'un pedido completado no se cancela');
});

test('INT-07 invariante: stock = suma del kardex (variantes de prueba y TODA la base)', opciones, async () => {
  for (const v of [ctx.varA, ctx.varB]) {
    assert.equal(await stock(v), await sumaKardex(v), `variante ${v}`);
  }
  const [descuadres] = await pool.query(
    `SELECT v.variante_id, v.stock_actual, COALESCE(SUM(k.efecto_stock), 0) AS kardex
       FROM variante_producto v LEFT JOIN vw_kardex k ON k.variante_id = v.variante_id
      GROUP BY v.variante_id, v.stock_actual
     HAVING v.stock_actual <> COALESCE(SUM(k.efecto_stock), 0)`
  );
  assert.deepEqual(descuadres, [], 'ninguna variante debe tener stock distinto a su kardex');
  const [[{ negativos }]] = await pool.query('SELECT COUNT(*) AS negativos FROM variante_producto WHERE stock_actual < 0');
  assert.equal(negativos, 0);
});

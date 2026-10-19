// Pruebas aisladas sin conexión a MySQL (no alteran datos).
// Ejecutar desde la raíz del repo: node --test docs/casos-prueba/scripts/entrega4_variantes_clientes_unit.cjs
const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('node:module');
const path = require('node:path');

const validar = require(path.resolve(__dirname, '../../../web/src/utils/validate.js'));

function cargarModelo(ruta, pool) {
  const absoluto = path.resolve(__dirname, '../../../web/src/models', ruta);
  const original = Module._load;
  Module._load = function (request, parent, isMain) {
    if (request === '../config/db') return pool;
    return original.call(this, request, parent, isMain);
  };
  try {
    delete require.cache[require.resolve(absoluto)];
    return require(absoluto);
  } finally {
    Module._load = original;
  }
}

test('cliente: acepta 2 números, elimina duplicados', () => {
  const telefonos = validar.extraerTelefonos('55551234\n55555678\n55551234');
  assert.deepEqual(telefonos, ['55551234', '55555678']);
  assert.deepEqual(validar.validarCliente({ tipo_cliente_id: '1', nombre_cliente: 'Cliente Prueba', nit: '1234567-8', telefonos: '55551234\n55555678' }), []);
});

test('cliente: rechaza más de 5 teléfonos y formatos inválidos', () => {
  const base = { tipo_cliente_id: '1', nombre_cliente: 'Cliente Prueba', nit: '1234567-8' };
  assert.ok(validar.validarCliente({ ...base, telefonos: '11111111\n22222222\n33333333\n44444444\n55555555\n66666666' }).length);
  assert.ok(validar.validarCliente({ ...base, telefonos: '5555abc4' }).length);
});

test('variantes: rechaza IDs no decimales y stock inválido', () => {
  assert.deepEqual(validar.validarVariante({ producto_id:'1', talla_id:'2', color_id:'3', stock_minimo:'0' }), []);
  assert.ok(validar.validarVariante({ producto_id:'1 OR 1=1', talla_id:'2', color_id:'3', stock_minimo:'0' }).length);
  assert.ok(validar.validarVariante({ producto_id:'1', talla_id:'2', color_id:'3', stock_minimo:'-1' }).length);
});

test('variante: con stock solo puede cambiar el stock mínimo', async () => {
  const ejecutadas = [];
  let commit = 0;
  const conn = {
    async beginTransaction() {},
    async query(sql, args) {
      ejecutadas.push({ sql, args });
      if (sql.includes('SELECT producto_id')) return [[{ producto_id:1, talla_id:2, color_id:3, stock_actual:8 }]];
      if (sql.includes('UPDATE variante_producto')) return [{ affectedRows:1 }];
      throw new Error('SQL inesperado: ' + sql);
    },
    async commit() { commit++; },
    async rollback() { throw new Error('rollback inesperado'); },
    release() {},
  };
  const m = cargarModelo('varianteModel.js', { getConnection: async () => conn });
  assert.equal(await m.actualizar(7, { producto_id:1, talla_id:2, color_id:3, stock_minimo:5 }), true);
  assert.equal(commit,1);
  assert.ok(ejecutadas.some((q) => /SET stock_minimo = \? WHERE/.test(q.sql)));
  assert.ok(ejecutadas.every((q) => !q.sql.includes('stock_actual =')));
});

test('variante: rechaza cambiar talla cuando tiene stock', async () => {
  let rollback = 0;
  const conn = {
    async beginTransaction() {},
    async query(sql) {
      if (sql.includes('SELECT producto_id')) return [[{ producto_id:1, talla_id:2, color_id:3, stock_actual:8 }]];
      throw new Error('SQL inesperado: ' + sql);
    },
    async commit() { throw new Error('no debe confirmar'); },
    async rollback() { rollback++; },
    release() {},
  };
  const m = cargarModelo('varianteModel.js', { getConnection: async () => conn });
  await assert.rejects(m.actualizar(7, { producto_id:1, talla_id:4, color_id:3, stock_minimo:5 }), { code:'VARIANTE_BLOQUEADA' });
  assert.equal(rollback,1);
});

test('cliente: creación inserta 2 teléfonos en una transacción', async () => {
  const log = [];
  const conn = {
    async beginTransaction() { log.push('begin'); },
    async query(sql, params) {
      log.push([sql, params]);
      if (sql.startsWith('INSERT INTO cliente (')) return [{ insertId:33 }];
      if (sql.startsWith('INSERT INTO cliente_telefono')) return [{ affectedRows:1 }];
      throw new Error('SQL inesperado');
    },
    async commit() { log.push('commit'); },
    async rollback() { throw new Error('rollback inesperado'); },
    release() {},
  };
  const m = cargarModelo('clienteModel.js', { getConnection: async () => conn });
  assert.equal(await m.crear({ tipo_cliente_id:1, nombre_cliente:'Prueba', nit:'1234567-8', telefonos:['55551234','55555678'] }),33);
  assert.equal(log.filter((e) => Array.isArray(e) && e[0].startsWith('INSERT INTO cliente_telefono')).length,2);
  assert.equal(log.at(-1),'commit');
});

test('cliente: rollback si falla la inserción de un teléfono', async () => {
  let rollback = 0;
  const conn = {
    async beginTransaction() {},
    async query(sql) {
      if (sql.startsWith('INSERT INTO cliente (')) return [{ insertId:34 }];
      throw new Error('falló la inserción');
    },
    async commit() { throw new Error('no debe confirmar'); },
    async rollback() { rollback++; },
    release() {},
  };
  const m = cargarModelo('clienteModel.js', { getConnection: async () => conn });
  await assert.rejects(m.crear({ tipo_cliente_id:1, nombre_cliente:'Prueba', nit:'1234567-8', telefonos:['55551234'] }));
  assert.equal(rollback,1);
});

test('variante: impide eliminar cuando hay movimientos aunque stock sea cero', async () => {
  let rollback = 0;
  const conn = {
    async beginTransaction() {},
    async query(sql) {
      if (sql.includes('SELECT stock_actual')) return [[{ stock_actual:0 }]];
      if (sql.includes('EXISTS(')) return [[{ pedidos:0, ingresos:0, movimientos:1 }]];
      throw new Error('No debe borrar una variante con historial');
    },
    async commit() { throw new Error('no debe confirmar'); },
    async rollback() { rollback++; },
    release() {},
  };
  const m = cargarModelo('varianteModel.js', { getConnection:async () => conn });
  await assert.rejects(m.eliminar(7), { code:'VARIANTE_BLOQUEADA' });
  assert.equal(rollback,1);
});

test('variante: nueva variante deriva SKU y stock inicial siempre cero', async () => {
  let parametros;
  const m = cargarModelo('varianteModel.js', { async query(sql, args) {
    assert.ok(sql.includes('VALUES (?, ?, ?, ?, 0, ?)'));
    parametros=args;
    return [{insertId:77}];
  } });
  assert.equal(await m.crear({producto_id:2,talla_id:5,color_id:3,stock_minimo:6}),77);
  assert.deepEqual(parametros,[2,5,3,'PVM-002-T05-C03',6]);
});

test('cliente: editar actualiza los teléfonos y confirma una sola transacción', async () => {
  const ejecutadas = [];
  const conn = {
    async beginTransaction(){ ejecutadas.push('BEGIN'); },
    async query(sql,args) {
      ejecutadas.push([sql,args]);
      if (sql.includes('FOR UPDATE')) return [[{ cliente_id:9 }]];
      return [{ affectedRows:1 }];
    },
    async commit(){ ejecutadas.push('COMMIT'); },
    async rollback(){ throw new Error('rollback inesperado'); },
    release() {},
  };
  const m=cargarModelo('clienteModel.js',{getConnection:async()=>conn});
  assert.equal(await m.actualizar(9,{tipo_cliente_id:1,nombre_cliente:'Prueba',nit:'1234567-8',telefonos:['55551234','55555678']}),true);
  assert.equal(ejecutadas.filter(x=>Array.isArray(x)&&x[0].startsWith('INSERT INTO cliente_telefono')).length,2);
  assert.equal(ejecutadas.at(-1),'COMMIT');
});

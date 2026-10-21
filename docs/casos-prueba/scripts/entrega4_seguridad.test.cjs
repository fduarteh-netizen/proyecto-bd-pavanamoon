// =============================================================================
// Archivo:      entrega4_seguridad.test.cjs
// Autor:        Equipo Pavanamoon
// Descripción:  Pruebas de SEGURIDAD de la app web (Entrega 4, Lote 5) por
//               HTTP contra la app en ejecución:
//                 - sin credenciales de demostración en el login;
//                 - cookie de sesión HttpOnly + SameSite=Lax (+ Secure en
//                   producción) y regeneración del id al iniciar sesión;
//                 - la cookie no sirve después de cerrar sesión;
//                 - cabeceras de seguridad;
//                 - rechazo de POST desde otro sitio (CSRF);
//                 - límite de intentos fallidos (429);
//                 - matriz de autorización: cada módulo de permisos.js con
//                   cada rol (200 o 403) y sin sesión (redirige a /login);
//                 - en producción la app NO arranca con un secreto débil, la
//                   cookie lleva Secure y un POST sin Origin/Referer o con
//                   Origin "null" se rechaza (CSRF estricto);
//                 - el mensaje de bloqueo/deadlock no afirma que "no se
//                   guardó nada" (el manejador no puede saberlo).
//               Solo LEE datos (inicia sesión y abre páginas): no crea ni
//               borra registros. Los intentos fallidos usan un usuario
//               inexistente aleatorio, así nunca bloquea a un usuario real.
//
//   PowerShell (desde la raíz del repo, con la app corriendo en otra terminal):
//     node --test docs/casos-prueba/scripts/entrega4_seguridad.test.cjs
//   Opcional: $env:APP_URL = "http://localhost:3000"
//   Las contraseñas se establecen solo en PowerShell con
//   $env:PVM_PASS_ADMIN, $env:PVM_PASS_BODEGA, $env:PVM_PASS_VENTAS
// Dependencias: Node 18+ (fetch), app web corriendo, web/.env, BD con datos
//               semilla, web/src/config/permisos.js
// =============================================================================
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const crypto = require('node:crypto');
const { spawn } = require('node:child_process');

const WEB = path.resolve(__dirname, '../../../web');
const APP = (process.env.APP_URL || 'http://localhost:3000').replace(/\/$/, '');
const { MODULOS } = require(path.join(WEB, 'src/config/permisos.js'));

// Las contraseñas se reciben por variables de entorno de PowerShell;
// nunca se almacenan contraseñas reales en el repositorio.
const USUARIOS = {
  administrador: { username: 'admin', password: process.env.PVM_PASS_ADMIN },
  bodeguero: { username: 'cabrito', password: process.env.PVM_PASS_BODEGA },
  vendedor: { username: 'fernanflo', password: process.env.PVM_PASS_VENTAS },
};

/** Cookies de la respuesta como arreglo de strings "Set-Cookie". */
function setCookies(res) {
  if (typeof res.headers.getSetCookie === 'function') return res.headers.getSetCookie();
  const unido = res.headers.get('set-cookie');
  return unido ? unido.split(/,(?=\s*[^;=\s]+=)/) : [];
}

/** "nombre=valor" de la cookie de sesión, o null. */
function cookieSesion(res) {
  const c = setCookies(res).find((x) => x.trim().startsWith('pavanamoon.sid='));
  return c ? c.trim().split(';')[0] : null;
}

async function login(username, password, cookie, base = APP, extraHeaders = {}) {
  return fetch(`${base}/login`, {
    method: 'POST',
    redirect: 'manual',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', ...(cookie ? { Cookie: cookie } : {}), ...extraHeaders },
    body: new URLSearchParams({ username, password }).toString(),
  });
}

async function sesionDe(rol) {
  const { username, password } = USUARIOS[rol];
  const res = await login(username, password);
  assert.equal(res.status, 302, `login de ${username} debe funcionar (revisa la cuenta activa y la contraseña de la variable de entorno)`);
  return cookieSesion(res);
}

const get = (ruta, cookie) => fetch(`${APP}${ruta}`, { redirect: 'manual', headers: cookie ? { Cookie: cookie } : {} });

test.before(async () => {
  const faltantes = ['PVM_PASS_ADMIN', 'PVM_PASS_BODEGA', 'PVM_PASS_VENTAS']
    .filter((nombre) => !process.env[nombre]);
  if (faltantes.length) {
    throw new Error(`Configura primero estas variables de entorno en PowerShell: ${faltantes.join(', ')}`);
  }
  try {
    await fetch(`${APP}/login`);
  } catch (err) {
    throw new Error(`La app no responde en ${APP}. Arráncala primero (cd web; npm start).`);
  }
});

test('SEG-01 la página de login no muestra credenciales de demostración', async () => {
  const html = await (await get('/login')).text();
  for (const secreto of ['Admin#2026', 'Bodega#2026', 'Ventas#2026']) {
    assert.ok(!html.includes(secreto), `el login no debe mostrar ${secreto}`);
  }
});

test('SEG-02 cookie de sesión: nombre propio, HttpOnly y SameSite=Lax', async () => {
  const res = await login(USUARIOS.administrador.username, USUARIOS.administrador.password);
  const cruda = setCookies(res).find((c) => c.trim().startsWith('pavanamoon.sid='));
  assert.ok(cruda, 'debe emitir la cookie pavanamoon.sid (no connect.sid)');
  assert.match(cruda, /HttpOnly/i);
  assert.match(cruda, /SameSite=Lax/i);
});

test('SEG-03 el id de sesión cambia al iniciar sesión (sin fijación de sesión)', async () => {
  const primera = await sesionDe('vendedor');
  const res = await login(USUARIOS.vendedor.username, USUARIOS.vendedor.password, primera);
  const segunda = cookieSesion(res);
  assert.ok(segunda, 'el segundo login debe emitir cookie');
  assert.notEqual(segunda, primera, 'el id de sesión debe regenerarse');
  assert.equal((await get('/', primera)).status, 302, 'el id anterior ya no debe servir');
  assert.equal((await get('/', segunda)).status, 200);
});

test('SEG-04 tras cerrar sesión la cookie ya no da acceso', async () => {
  const cookie = await sesionDe('administrador');
  assert.equal((await get('/', cookie)).status, 200);
  const salida = await fetch(`${APP}/logout`, { method: 'POST', redirect: 'manual', headers: { Cookie: cookie } });
  assert.equal(salida.status, 302);
  assert.equal((await get('/', cookie)).status, 302);
});

test('SEG-05 cabeceras de seguridad y sin X-Powered-By', async () => {
  const res = await get('/', await sesionDe('administrador'));
  assert.equal(res.headers.get('x-frame-options'), 'DENY');
  assert.equal(res.headers.get('x-content-type-options'), 'nosniff');
  assert.match(res.headers.get('cache-control') || '', /no-store/);
  assert.equal(res.headers.get('x-powered-by'), null);
});

test('SEG-06 un POST desde otro sitio se rechaza aunque haya sesión (CSRF)', async () => {
  const cookie = await sesionDe('administrador');
  const ajeno = await fetch(`${APP}/catalogos/colores`, {
    method: 'POST', redirect: 'manual',
    headers: { Cookie: cookie, Origin: 'https://sitio-malicioso.example', 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'nombre_color=intruso',
  });
  assert.equal(ajeno.status, 403);
  // Origin "null" (iframes con sandbox, redirecciones) también se rechaza.
  const nulo = await fetch(`${APP}/catalogos/colores`, {
    method: 'POST', redirect: 'manual',
    headers: { Cookie: cookie, Origin: 'null', 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'nombre_color=intruso',
  });
  assert.equal(nulo.status, 403);
  // Mismo origen: pasa la verificación (400 por validación, nunca 403).
  const propio = await fetch(`${APP}/catalogos/colores`, {
    method: 'POST', redirect: 'manual',
    headers: { Cookie: cookie, Origin: APP, 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'nombre_color=1',
  });
  assert.equal(propio.status, 400);
});

test('SEG-07 límite de intentos: tras 5 fallos responde 429; otro usuario sigue entrando', async () => {
  const falso = `noexiste_${crypto.randomBytes(4).toString('hex')}`;
  for (let i = 1; i <= 5; i += 1) {
    assert.equal((await login(falso, 'incorrecta')).status, 401, `intento ${i}`);
  }
  const bloqueado = await login(falso, 'incorrecta');
  assert.equal(bloqueado.status, 429);
  assert.ok(Number(bloqueado.headers.get('retry-after')) > 0);
  assert.match(await bloqueado.text(), /Demasiados intentos/);
  assert.equal((await login(USUARIOS.bodeguero.username, USUARIOS.bodeguero.password)).status, 302);
});

test('SEG-08 matriz de autorización: cada módulo × cada rol, y sin sesión', async () => {
  const sesiones = {};
  for (const rol of Object.keys(USUARIOS)) sesiones[rol] = await sesionDe(rol);
  const fallos = [];
  for (const m of MODULOS) {
    const sinSesion = await get(m.ruta);
    if (sinSesion.status !== 302 || !(sinSesion.headers.get('location') || '').includes('/login')) {
      fallos.push(`${m.ruta} sin sesión -> ${sinSesion.status}`);
    }
    for (const rol of Object.keys(USUARIOS)) {
      const esperado = m.roles.includes(rol) ? 200 : 403;
      const res = await get(m.ruta, sesiones[rol]);
      // Un módulo puede redirigir a su primera página (ej. /catalogos -> /catalogos/categorias).
      const destino = res.headers.get('location') || '';
      const real = res.status === 302 && destino.startsWith(`${m.ruta}/`) ? 200 : res.status;
      if (real !== esperado) fallos.push(`${m.ruta} como ${rol}: esperado ${esperado}, obtenido ${res.status} ${destino}`);
    }
  }
  assert.deepEqual(fallos, [], fallos.join('\n'));
  console.log(`  verificadas ${MODULOS.length} rutas × ${Object.keys(USUARIOS).length} roles + sin sesión`);
});

/** Arranca una copia de la app con variables propias; resuelve con {code, salida, proceso}. */
function arrancar(env, esperarMs) {
  return new Promise((resolve) => {
    const proceso = spawn(process.execPath, ['server.js'], { cwd: WEB, env: { ...process.env, ...env } });
    let salida = '';
    proceso.stdout.on('data', (d) => { salida += d; });
    proceso.stderr.on('data', (d) => { salida += d; });
    const timer = setTimeout(() => resolve({ code: null, salida, proceso }), esperarMs);
    proceso.on('exit', (code) => { clearTimeout(timer); resolve({ code, salida, proceso }); });
  });
}

test('SEG-09 en producción la app NO arranca con un SESSION_SECRET débil', async () => {
  for (const secreto of ['', 'corto', 'change_this_to_a_random_long_string']) {
    const r = await arrancar({ NODE_ENV: 'production', SESSION_SECRET: secreto, WEB_PORT: '0' }, 4000);
    if (r.code === null) r.proceso.kill();
    assert.notEqual(r.code, 0, `con SESSION_SECRET="${secreto}" no debe arrancar`);
    assert.notEqual(r.code, null, `con SESSION_SECRET="${secreto}" se quedó escuchando`);
    assert.match(r.salida, /SESSION_SECRET/);
  }
});

test('SEG-10 en producción: cookie Secure detrás de HTTPS y CSRF estricto', async () => {
  const puerto = String(40000 + Math.floor(Math.random() * 10000));
  const r = await arrancar({
    NODE_ENV: 'production', SESSION_SECRET: crypto.randomBytes(48).toString('hex'), TRUST_PROXY: '1', WEB_PORT: puerto,
  }, 2500);
  try {
    assert.equal(r.code, null, `la app de producción debió arrancar: ${r.salida}`);
    const base = `http://localhost:${puerto}`;
    const credenciales = [USUARIOS.administrador.username, USUARIOS.administrador.password, null, base];
    // Sin Origin ni Referer: en producción se rechaza.
    assert.equal((await login(...credenciales, { 'X-Forwarded-Proto': 'https' })).status, 403,
      'en producción un POST sin Origin ni Referer debe rechazarse');
    // Con Origin de otro sitio: rechazado.
    assert.equal((await login(...credenciales, { 'X-Forwarded-Proto': 'https', Origin: 'https://otro.example' })).status, 403);
    // Con Origin propio: aceptado.
    const res = await login(...credenciales, { 'X-Forwarded-Proto': 'https', Origin: base });
    assert.equal(res.status, 302);
    const cruda = setCookies(res).find((c) => c.trim().startsWith('pavanamoon.sid='));
    assert.ok(cruda, 'debe emitir la cookie');
    assert.match(cruda, /;\s*Secure/i);
  } finally {
    r.proceso.kill();
  }
});

test('SEG-11 el mensaje de deadlock/timeout no afirma que "no se guardó nada"', () => {
  const { errorHandler } = require(path.join(WEB, 'src/middleware/errorHandler.js'));
  const original = console.error;
  console.error = () => {}; // el manejador registra el error; aquí no interesa
  try {
    for (const code of ['ER_LOCK_DEADLOCK', 'ER_LOCK_WAIT_TIMEOUT']) {
      let estado;
      let datos;
      const res = { status(s) { estado = s; return this; }, render(_vista, d) { datos = d; } };
      errorHandler({ code }, {}, res, () => {});
      assert.equal(estado, 409, code);
      assert.doesNotMatch(datos.mensaje, /no se guard[oó] nada/i, code);
      assert.match(datos.mensaje, /Revisa si el cambio quedó registrado/, code);
    }
  } finally {
    console.error = original;
  }
});

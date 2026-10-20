// =============================================================================
// Archivo:      src/middleware/seguridad.js
// Autor:        Equipo Pavanamoon
// Descripción:  Endurecimiento de seguridad de la app web (Entrega 4, Lote 5).
//               Sin dependencias nuevas (npm audit sigue en 0).
//
//   1) opcionesSesion(): configuración de express-session.
//      - En producción (NODE_ENV=production) la app NO arranca si falta
//        SESSION_SECRET, si mide menos de 32 caracteres o si es el valor de
//        ejemplo de .env.example. Antes usaba 'dev-secret-change-me', un
//        secreto público con el que cualquiera podía firmar cookies de sesión.
//      - En desarrollo, si falta el secreto se genera uno aleatorio por
//        proceso (las sesiones se cierran al reiniciar, pero nunca se usa un
//        secreto conocido).
//      - Cookie: httpOnly (JavaScript no puede leerla), sameSite=lax (el
//        navegador no la envía en POST desde otros sitios: defensa CSRF),
//        secure en producción (solo HTTPS) y nombre propio.
//   2) cabecerasSeguridad: nosniff, anti-iframe (clickjacking), referrer y
//      no-store en páginas dinámicas (tras cerrar sesión, "Atrás" no muestra
//      datos de la caché).
//   3) verificarOrigen (CSRF, segunda capa además de sameSite=lax): para
//      POST/PUT/DELETE/PATCH compara el host de Origin (o Referer) con los
//      hosts permitidos: Host de la petición, X-Forwarded-Host si
//      TRUST_PROXY=1, y ORIGENES_PERMITIDOS. Origin "null" se rechaza.
//      Sin Origin NI Referer: en producción se RECHAZA (todo navegador
//      moderno envía Origin en un POST); en desarrollo se permite para los
//      scripts de prueba (curl), que igual necesitan una sesión válida.
//      Alcance y límites (ver LEEME del Lote 5): no hay tokens CSRF por
//      formulario; la defensa es SameSite + verificación de origen
//      (OWASP: defensa válida en profundidad, no sustituto pleno de tokens).
//      Requiere que ninguna ruta GET modifique datos (verificado en Lote 5).
//      Un XSS en el propio sitio anula cualquier defensa CSRF.
//   4) limitadorLogin: bloquea temporalmente tras varios intentos fallidos,
//      por usuario+IP y por IP (fuerza bruta y prueba de muchos usuarios).
//
//   DESPLIEGUE CON VARIAS INSTANCIAS: NO SOPORTADO TAL COMO ESTÁ.
//   - Sesiones: express-session usa MemoryStore (memoria del proceso). Con 2+
//     instancias detrás de un balanceador, cada una tiene sus propias
//     sesiones: el usuario "pierde" la sesión al caer en otra instancia, y
//     desactivar/cerrar sesión no se propaga. MemoryStore además no libera
//     sesiones vencidas de forma eficiente (express-session lo advierte en
//     producción). Al reiniciar, todas las sesiones se pierden.
//   - Límite de intentos: el mapa `intentos` también es por proceso: con N
//     instancias un atacante obtiene N veces más intentos, y un reinicio lo
//     pone en cero.
//   Despliegue soportado: UNA sola instancia (ej. réplicas = 1). Para escalar
//   haría falta un almacén compartido para sesiones (p. ej. una tabla en
//   MySQL con express-mysql-session, o Redis) y para el límite de intentos;
//   no se incluye para no agregar dependencias en esta entrega.
// Variables de entorno: NODE_ENV, SESSION_SECRET, TRUST_PROXY,
//               ORIGENES_PERMITIDOS, LOGIN_MAX_INTENTOS, LOGIN_MAX_INTENTOS_IP,
//               LOGIN_BLOQUEO_MINUTOS
// Dependencias: crypto (Node), express-session (server.js)
// Estándar:     A2, A3, R6
// =============================================================================

const crypto = require('crypto');

const NOMBRE_COOKIE = 'pavanamoon.sid';
const SECRETO_EJEMPLO = 'change_this_to_a_random_long_string';
const esProduccion = () => process.env.NODE_ENV === 'production';

/** Lee un entero positivo de una variable de entorno, con valor por defecto. */
function enteroEnv(nombre, porDefecto) {
  const valor = Number(process.env[nombre]);
  return Number.isInteger(valor) && valor > 0 ? valor : porDefecto;
}

/**
 * Devuelve las opciones para express-session. Lanza un error (y la app no
 * arranca) si en producción el secreto falta o es débil.
 */
function opcionesSesion() {
  let secreto = process.env.SESSION_SECRET || '';
  const debil = secreto.length < 32 || secreto === SECRETO_EJEMPLO;

  if (esProduccion() && debil) {
    throw new Error(
      'SESSION_SECRET falta, mide menos de 32 caracteres o es el valor de ejemplo. ' +
      'Genera uno con: node -e "console.log(require(\'crypto\').randomBytes(48).toString(\'hex\'))"'
    );
  }
  if (debil) {
    secreto = crypto.randomBytes(48).toString('hex');
    console.warn('[seguridad] SESSION_SECRET ausente o débil: se usa uno aleatorio temporal (solo desarrollo).');
  }

  return {
    name: NOMBRE_COOKIE,
    secret: secreto,
    resave: false,
    saveUninitialized: false,
    cookie: {
      httpOnly: true,
      sameSite: 'lax',
      secure: esProduccion(), // en producción la cookie solo viaja por HTTPS
      maxAge: 1000 * 60 * 60 * 4, // 4 horas
    },
  };
}

/** Cabeceras de seguridad básicas para todas las respuestas dinámicas. */
function cabecerasSeguridad(req, res, next) {
  res.set({
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Content-Security-Policy': "frame-ancestors 'none'",
    'Referrer-Policy': 'same-origin',
    'Cache-Control': 'no-store',
  });
  next();
}

/** host:puerto de una URL, o null si no es válida (incluye Origin "null"). */
function hostDe(url) {
  try {
    const u = new URL(url);
    return u.host || null;
  } catch (err) {
    return null;
  }
}

/** Hosts desde los que se aceptan formularios. */
function hostsPermitidos(req) {
  const hosts = new Set();
  if (req.get('host')) hosts.add(req.get('host').toLowerCase());
  if (process.env.TRUST_PROXY === '1' && req.get('x-forwarded-host')) {
    hosts.add(req.get('x-forwarded-host').split(',')[0].trim().toLowerCase());
  }
  for (const origen of (process.env.ORIGENES_PERMITIDOS || '').split(',')) {
    const host = hostDe(origen.trim());
    if (host) hosts.add(host.toLowerCase());
  }
  return hosts;
}

/**
 * CSRF: rechaza peticiones que cambian datos si el navegador declara que
 * vienen de otro sitio, o (solo en producción) si no declaran procedencia.
 */
function verificarOrigen(req, res, next) {
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) return next();
  const procedencia = req.get('origin') || req.get('referer');
  const rechazar = () => res.status(403).render('error', {
    titulo: 'Solicitud rechazada',
    mensaje: 'La solicitud no proviene de este sitio.',
  });
  if (!procedencia) return esProduccion() ? rechazar() : next();
  const host = hostDe(procedencia);
  if (!host || !hostsPermitidos(req).has(host.toLowerCase())) return rechazar();
  next();
}

// --- Límite de intentos de inicio de sesión ---------------------------------

const intentos = new Map(); // clave -> { fallos, bloqueadoHasta, ultimo }

function configLimitador() {
  return {
    maxPorUsuario: enteroEnv('LOGIN_MAX_INTENTOS', 5),
    maxPorIp: enteroEnv('LOGIN_MAX_INTENTOS_IP', 20),
    bloqueoMs: enteroEnv('LOGIN_BLOQUEO_MINUTOS', 15) * 60 * 1000,
  };
}

function clavesDe(ip, username) {
  const usuario = String(username || '').trim().toLowerCase();
  return { usuario: `u:${ip}|${usuario}`, ip: `ip:${ip}` };
}

/** Segundos de bloqueo restantes para ip+usuario (0 = puede intentar). */
function segundosBloqueado(ip, username) {
  const ahora = Date.now();
  let maximo = 0;
  for (const clave of Object.values(clavesDe(ip, username))) {
    const registro = intentos.get(clave);
    if (registro && registro.bloqueadoHasta > ahora) {
      maximo = Math.max(maximo, Math.ceil((registro.bloqueadoHasta - ahora) / 1000));
    }
  }
  return maximo;
}

/** Registra un intento fallido; al llegar al máximo, bloquea. */
function registrarFallo(ip, username) {
  const { maxPorUsuario, maxPorIp, bloqueoMs } = configLimitador();
  const ahora = Date.now();
  const claves = clavesDe(ip, username);
  for (const [tipo, clave] of Object.entries(claves)) {
    const maximo = tipo === 'ip' ? maxPorIp : maxPorUsuario;
    const registro = intentos.get(clave) || { fallos: 0, bloqueadoHasta: 0, ultimo: ahora };
    if (ahora - registro.ultimo > bloqueoMs) registro.fallos = 0; // ventana vencida
    registro.fallos += 1;
    registro.ultimo = ahora;
    if (registro.fallos >= maximo) {
      registro.bloqueadoHasta = ahora + bloqueoMs;
      registro.fallos = 0;
    }
    intentos.set(clave, registro);
  }
}

/**
 * Inicio de sesión correcto: se olvidan los fallos de ese usuario en esa IP
 * y los de la IP. Así una oficina con varios empleados detrás de la misma IP
 * no queda bloqueada por errores de tipeo acumulados; el límite de
 * LOGIN_MAX_INTENTOS por usuario sigue impidiendo adivinar la contraseña de
 * otra cuenta aunque se intercalen inicios de sesión válidos.
 */
function registrarExito(ip, username) {
  const claves = clavesDe(ip, username);
  intentos.delete(claves.usuario);
  intentos.delete(claves.ip);
}

// Limpieza periódica para que el mapa no crezca sin límite.
setInterval(() => {
  const limite = Date.now() - configLimitador().bloqueoMs;
  for (const [clave, registro] of intentos) {
    if (registro.bloqueadoHasta < Date.now() && registro.ultimo < limite) intentos.delete(clave);
  }
}, 10 * 60 * 1000).unref();

module.exports = {
  NOMBRE_COOKIE,
  opcionesSesion,
  cabecerasSeguridad,
  verificarOrigen,
  limitadorLogin: { segundosBloqueado, registrarFallo, registrarExito },
};

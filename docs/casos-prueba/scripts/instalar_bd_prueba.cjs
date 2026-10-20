// =============================================================================
// Archivo:      instalar_bd_prueba.cjs
// Autor:        Equipo Pavanamoon
// Descripción:  Crea una base de datos INDEPENDIENTE para pruebas que escriben
//               datos (ej. entrega4_integracion_stock.test.cjs), ejecutando los
//               mismos scripts del repositorio que INSTALL.md (ddl, dml, views,
//               triggers, procedures) con el nombre de base cambiado.
//
//   Garantías:
//   - El nombre DEBE terminar en "_prueba" y ser distinto de DB_NAME de
//     web/.env y de "pavanamoon". Cualquier otro nombre se rechaza.
//   - Nunca toca la base habitual: cada script se reescribe para usar la base
//     de prueba (USE / CREATE DATABASE) antes de ejecutarse.
//   - NO ejecuta sql/security/*: esos scripts crean/eliminan roles y usuarios
//     GLOBALES del servidor (rol_*, pvm_*) y afectarían su instalación.
//   - Crea la tabla marcadora zz_bd_de_prueba: las pruebas que escriben datos
//     se niegan a correr en una base que no la tenga.
//   - Si la base de prueba ya existe, solo la recrea con --recrear (y solo
//     porque su nombre termina en _prueba).
//   - Concede al usuario de la app (DB_USER de web/.env) SELECT, INSERT,
//     UPDATE, DELETE y EXECUTE SOLO sobre la base de prueba (aditivo; no
//     cambia sus permisos sobre la base habitual). Omitir con --sin-permisos.
//
//   PowerShell (desde la raíz del repo; requiere un usuario administrador de MySQL):
//     $env:PVM_ADMIN_USER = "root"
//     $env:PVM_ADMIN_PASSWORD = "su_clave_de_root"
//     node docs/casos-prueba/scripts/instalar_bd_prueba.cjs                 # crea pavanamoon_prueba
//     node docs/casos-prueba/scripts/instalar_bd_prueba.cjs --recrear       # la borra y la vuelve a crear
//     Remove-Item Env:PVM_ADMIN_PASSWORD
//   Opciones: --bd=otro_nombre_prueba  --sin-permisos
// Dependencias: web/node_modules (mysql2, dotenv), web/.env, sql/*
// =============================================================================
const fs = require('node:fs');
const path = require('node:path');

const RAIZ = path.resolve(__dirname, '../../..');
const WEB = path.join(RAIZ, 'web');
require(path.join(WEB, 'node_modules/dotenv')).config({ path: path.join(WEB, '.env') });
const mysql = require(path.join(WEB, 'node_modules/mysql2/promise'));

const NOMBRE_ORIGINAL = 'pavanamoon';
const MARCADOR = 'zz_bd_de_prueba';
const args = process.argv.slice(2);
const opcion = (nombre) => args.includes(`--${nombre}`);
const valor = (nombre, defecto) => {
  const a = args.find((x) => x.startsWith(`--${nombre}=`));
  return a ? a.slice(nombre.length + 3) : defecto;
};

/** Reglas para aceptar un nombre de base de prueba. Devuelve un mensaje de error o null. */
function validarNombrePrueba(nombre, bdHabitual) {
  if (!/^[A-Za-z0-9_]{1,56}_prueba$/.test(nombre)) return `"${nombre}" no termina en _prueba o tiene caracteres no permitidos.`;
  if (nombre.toLowerCase() === NOMBRE_ORIGINAL) return 'No se permite usar la base habitual "pavanamoon".';
  if (bdHabitual && nombre.toLowerCase() === bdHabitual.toLowerCase()) {
    return `"${nombre}" es la base que usa la app (DB_NAME de web/.env).`;
  }
  return null;
}

/** Scripts en el mismo orden que INSTALL.md, SIN sql/security (afecta roles globales). */
function scriptsEnOrden() {
  const listar = (carpeta, filtro = () => true) => fs.readdirSync(path.join(RAIZ, 'sql', carpeta))
    .filter((f) => f.endsWith('.sql') && filtro(f)).sort()
    .map((f) => path.join('sql', carpeta, f));
  return [
    ...listar('ddl'),
    ...listar('dml', (f) => /^0[01]_/.test(f)), // 00_seed_minimo, 01_datos_prueba
    ...listar('views'),
    ...listar('triggers'),
    ...listar('procedures'),
  ];
}

/**
 * Quita un comentario "-- ..." de una línea, solo si está fuera de una cadena
 * entre comillas simples (las comillas antes del "--" deben estar balanceadas).
 * El cliente mysql también elimina los comentarios antes de enviar cada
 * sentencia; así las rutinas quedan iguales a una instalación con mysql.
 */
function quitarComentario(linea) {
  const re = /(^|\s)--(\s|$)/g;
  let m;
  while ((m = re.exec(linea)) !== null) {
    const antes = linea.slice(0, m.index);
    const comillas = (antes.replace(/\\'|''/g, '').match(/'/g) || []).length;
    if (comillas % 2 === 0) return antes.trimEnd();
  }
  return linea;
}

/**
 * Divide un script en sentencias respetando DELIMITER (como el cliente mysql).
 */
function dividirSentencias(texto) {
  const sentencias = [];
  let delimitador = ';';
  let actual = [];
  for (const original of texto.split(/\r?\n/)) {
    const cambio = original.match(/^\s*DELIMITER\s+(\S+)\s*$/i);
    if (cambio) { delimitador = cambio[1]; continue; }
    const linea = quitarComentario(original);
    if (!linea.trim()) continue;
    actual.push(linea);
    if (linea.trimEnd().endsWith(delimitador)) {
      const sentencia = actual.join('\n').trimEnd().slice(0, -delimitador.length).trim();
      if (sentencia.replace(/^\s*--.*$/gm, '').trim()) sentencias.push(sentencia);
      actual = [];
    }
  }
  if (actual.join('').trim()) throw new Error('Sentencia sin terminar al final del script.');
  return sentencias;
}

/** Cambia el nombre de la base (palabra completa: no toca pavanamoon_app ni "Pavanamoon"). */
function cambiarBase(sql, nombre) {
  return sql.replace(/(?<![\w])pavanamoon(?![\w])/g, nombre);
}

async function main() {
  const bdHabitual = process.env.DB_NAME || NOMBRE_ORIGINAL;
  const nombre = valor('bd', `${NOMBRE_ORIGINAL}_prueba`);
  const error = validarNombrePrueba(nombre, bdHabitual);
  if (error) throw new Error(`Nombre de base de prueba rechazado: ${error}`);
  if (process.env.PVM_ADMIN_PASSWORD === undefined && !process.env.PVM_MYSQL_SOCKET) {
    throw new Error('Define $env:PVM_ADMIN_USER y $env:PVM_ADMIN_PASSWORD (usuario administrador de MySQL).');
  }

  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    socketPath: process.env.PVM_MYSQL_SOCKET || undefined,
    user: process.env.PVM_ADMIN_USER || 'root',
    password: process.env.PVM_ADMIN_PASSWORD || undefined,
    charset: 'utf8mb4',
  });
  try {
    const [[existe]] = await conn.query('SELECT COUNT(*) AS n FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = ?', [nombre]);
    if (existe.n) {
      if (!opcion('recrear')) throw new Error(`La base "${nombre}" ya existe. Usa --recrear para borrarla y crearla de nuevo.`);
      // Doble verificación antes de un DROP: solo nombres *_prueba ya validados.
      if (validarNombrePrueba(nombre, bdHabitual)) throw new Error('Verificación de seguridad fallida.');
      await conn.query(`DROP DATABASE \`${nombre}\``);
      console.log(`- base "${nombre}" eliminada para recrearla`);
    }

    for (const archivo of scriptsEnOrden()) {
      const texto = cambiarBase(fs.readFileSync(path.join(RAIZ, archivo), 'utf8'), nombre);
      const sentencias = dividirSentencias(texto);
      for (const sentencia of sentencias) {
        try {
          await conn.query(sentencia);
        } catch (err) {
          throw new Error(`${archivo}: ${err.message}\n--- sentencia ---\n${sentencia.slice(0, 300)}`);
        }
      }
      console.log(`- ${archivo} (${sentencias.length} sentencias)`);
    }

    await conn.query(`USE \`${nombre}\``);
    await conn.query(
      `CREATE TABLE ${MARCADOR} (
         creada_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
         origen    VARCHAR(100) NOT NULL
       ) COMMENT = 'Marca esta base como base de PRUEBAS (ver instalar_bd_prueba.cjs)'`
    );
    await conn.query(`INSERT INTO ${MARCADOR} (origen) VALUES ('instalar_bd_prueba.cjs')`);

    if (!opcion('sin-permisos') && process.env.DB_USER) {
      const [hosts] = await conn.query('SELECT Host FROM mysql.user WHERE User = ?', [process.env.DB_USER]);
      for (const { Host } of hosts) {
        await conn.query(`GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON \`${nombre}\`.* TO ?@?`, [process.env.DB_USER, Host]);
        console.log(`- permisos sobre "${nombre}" concedidos a ${process.env.DB_USER}@${Host}`);
      }
      if (!hosts.length) console.log(`! el usuario ${process.env.DB_USER} no existe en MySQL: no se concedieron permisos`);
    }
    const [[conteo]] = await conn.query(
      `SELECT (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_TYPE = 'BASE TABLE') AS tablas,
              (SELECT COUNT(*) FROM information_schema.VIEWS WHERE TABLE_SCHEMA = ?) AS vistas,
              (SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = ?) AS rutinas,
              (SELECT COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = ?) AS triggers`,
      [nombre, nombre, nombre, nombre]
    );
    console.log(`Listo: base de prueba "${nombre}" con ${conteo.tablas} tablas (incluye ${MARCADOR}), ` +
      `${conteo.vistas} vistas, ${conteo.rutinas} rutinas y ${conteo.triggers} triggers.`);
  } finally {
    await conn.end();
  }
}

if (require.main === module) {
  main().catch((err) => {
    console.error(`ERROR: ${err.message}`);
    process.exit(1);
  });
}

module.exports = { validarNombrePrueba, dividirSentencias, cambiarBase, MARCADOR };

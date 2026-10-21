// =============================================================================
// Archivo:      src/config/permisos.js
// Descripción:  Matriz única de permisos por rol (RF21). Es la fuente de
//               verdad para: (1) el middleware requireRole que protege las
//               rutas, (2) el menú de navegación y (3) las tarjetas del
//               inicio. Así un rol nunca ve un enlace a un módulo que el
//               servidor le va a negar (y aunque escriba la URL a mano, el
//               servidor responde 403).
//               Alineada con sql/security/01_roles_privilegios.sql.
// =============================================================================

const MODULOS = [
  { clave: 'productos',  ruta: '/productos',  titulo: 'Productos',   descripcion: 'Catálogo de modelos de calzado y precios.',            roles: ['administrador', 'bodeguero'] },
  { clave: 'inventario', ruta: '/inventario', titulo: 'Inventario',  descripcion: 'Stock por variante (talla/color) y alertas de mínimo.', roles: ['administrador', 'bodeguero', 'vendedor'] },
  { clave: 'furgones',   ruta: '/furgones',   titulo: 'Furgones',    descripcion: 'Registro de furgones que traen la mercadería.',        roles: ['administrador', 'bodeguero'] },
  { clave: 'ingresos',   ruta: '/ingresos',   titulo: 'Ingresos',    descripcion: 'Recepción de mercadería a bodega (suma stock).',      roles: ['administrador', 'bodeguero'] },
  { clave: 'clientes',   ruta: '/clientes',   titulo: 'Clientes',    descripcion: 'Clientes individuales y mayoristas.',                  roles: ['administrador', 'vendedor'] },
  { clave: 'pedidos',    ruta: '/pedidos',    titulo: 'Pedidos',     descripcion: 'Ventas con precio y descuento calculados en la BD.',   roles: ['administrador', 'vendedor'] },
  { clave: 'kardex',     ruta: '/kardex',     titulo: 'Kardex',      descripcion: 'Historial auditable de movimientos de stock.',         roles: ['administrador', 'bodeguero'] },
  // --- Entrega 4 ---
  { clave: 'reportes',   ruta: '/reportes',   titulo: 'Reportes',    descripcion: 'Ventas por periodo y modelos más/menos vendidos.',      roles: ['administrador'] },
  { clave: 'empleados',  ruta: '/empleados',  titulo: 'Empleados',   descripcion: 'Personal de la empresa y sus teléfonos.',              roles: ['administrador'] },
  { clave: 'usuarios',   ruta: '/usuarios',   titulo: 'Usuarios',    descripcion: 'Cuentas de acceso, roles y activación (RF19).',        roles: ['administrador'] },
  { clave: 'catalogos',  ruta: '/catalogos',  titulo: 'Catálogos',   descripcion: 'Categorías, tallas, colores, tipos de cliente y presentaciones.', roles: ['administrador'] },
];

function rolesDe(clave) {
  const modulo = MODULOS.find((m) => m.clave === clave);
  return modulo ? modulo.roles : ['administrador'];
}

function modulosPermitidos(rol) {
  return MODULOS.filter((m) => m.roles.includes(rol));
}

module.exports = { MODULOS, rolesDe, modulosPermitidos };

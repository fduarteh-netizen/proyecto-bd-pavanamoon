#!/usr/bin/env bash
# =============================================================================
# Archivo:      entrega4_casos_web.sh
# Autor:        Equipo Pavanamoon
# Descripción:  Casos CP4-08 a CP4-14: módulos web nuevos de la Entrega 4
#               (empleados, usuarios, reportes, cancelación de pedidos) y
#               control de acceso por rol, contra la BD real.
#               Imprime OK/FALLA por verificación y un resumen al final.
# Uso:          bash entrega4_casos_web.sh   (app corriendo; APP_URL opcional)
# Dependencias: app web levantada (npm start), BD instalada según INSTALL.md,
#               cliente mysql con acceso root local (MYSQL="mysql -uroot -p..." opcional)
# =============================================================================
B=${APP_URL:-http://localhost:3000}
MYSQL=${MYSQL:-"mysql -uroot"}
OK=0; FALLA=0
q(){ $MYSQL -N -e "$1" pavanamoon; }
check(){ if [ "$2" == "$3" ]; then echo "  OK    $1"; OK=$((OK+1)); else echo "  FALLA $1 (esperado '$3', obtenido '$2')"; FALLA=$((FALLA+1)); fi; }
login(){ rm -f /tmp/$1.jar; curl -s -c /tmp/$1.jar -b /tmp/$1.jar -o /dev/null -w "%{http_code}" --data-urlencode "username=$1" --data-urlencode "password=$2" $B/login; }
code(){ curl -s -b /tmp/$1.jar -o /dev/null -w "%{http_code}" "$B$2"; }
post(){ local u=$1 ruta=$2; shift 2; curl -s -X POST -b /tmp/$u.jar -c /tmp/$u.jar -o /tmp/resp.html -w "%{http_code}" "$@" "$B$ruta"; }

SUF=$(date +%H%M%S)
check "login admin"  "$(login admin  'Admin#2026')"  302
check "login bodega" "$(login bodega 'Bodega#2026')" 302
check "login ventas" "$(login ventas 'Ventas#2026')" 302

echo "--- CP4-08 Control de acceso a módulos nuevos (solo administrador)"
for m in reportes empleados usuarios; do
  check "admin  /$m" "$(code admin /$m)" 200
  check "bodega /$m" "$(code bodega /$m)" 403
  check "ventas /$m" "$(code ventas /$m)" 403
done

echo "--- CP4-09 Empleados: alta con 2 teléfonos (1FN), DPI duplicado, validación"
DPI="99${SUF}00000"; DPI=${DPI:0:13}
check "alta empleado" "$(post admin /empleados --data-urlencode "nombres_apellidos=Prueba E4 $SUF" --data-urlencode "dpi=$DPI" --data-urlencode $'telefonos=55551111\n44442222')" 302
EMP=$(q "SELECT empleado_id FROM empleado WHERE dpi='$DPI'")
check "2 filas en empleado_telefono" "$(q "SELECT COUNT(*) FROM empleado_telefono WHERE empleado_id=$EMP")" 2
check "DPI duplicado -> 400" "$(post admin /empleados --data-urlencode "nombres_apellidos=Otro" --data-urlencode "dpi=$DPI" --data-urlencode "telefonos=")" 400
grep -q "Ya existe un empleado con ese DPI" /tmp/resp.html && check "mensaje DPI duplicado" si si || check "mensaje DPI duplicado" no si
check "DPI de 5 dígitos -> 400" "$(post admin /empleados --data-urlencode "nombres_apellidos=Otro" --data-urlencode "dpi=12345")" 400
check "editar: deja 1 teléfono" "$(post admin "/empleados/$EMP?_method=PUT" --data-urlencode "nombres_apellidos=Prueba E4 $SUF editado" --data-urlencode "dpi=$DPI" --data-urlencode "telefonos=55553333")" 302
check "teléfonos tras editar" "$(q "SELECT GROUP_CONCAT(telefono) FROM empleado_telefono WHERE empleado_id=$EMP")" 55553333

echo "--- CP4-10 Usuarios: alta, login del nuevo usuario, contraseña hasheada"
check "alta usuario vendedor" "$(post admin /usuarios --data-urlencode "username=e4_$SUF" --data-urlencode "empleado_id=$EMP" --data-urlencode "rol_id=3" --data-urlencode "estado=activo" --data-urlencode "password=Prueba2026x" --data-urlencode "password_confirmacion=Prueba2026x")" 302
USR=$(q "SELECT usuario_id FROM usuario WHERE username='e4_$SUF'")
check "hash bcrypt (no texto plano)" "$(q "SELECT LEFT(password_hash,4) FROM usuario WHERE usuario_id=$USR")" '$2a$'
check "login del usuario nuevo" "$(login e4_$SUF 'Prueba2026x')" 302
check "nuevo vendedor entra a /pedidos" "$(code e4_$SUF /pedidos)" 200
check "contraseña débil -> 400" "$(post admin /usuarios --data-urlencode "username=x_$SUF" --data-urlencode "empleado_id=$EMP" --data-urlencode "rol_id=3" --data-urlencode "estado=activo" --data-urlencode "password=abc" --data-urlencode "password_confirmacion=abc")" 400

echo "--- CP4-11 Cambio de rol y desactivación con la sesión ABIERTA"
post admin "/usuarios/$USR?_method=PUT" --data-urlencode "rol_id=2" --data-urlencode "estado=activo" >/dev/null
check "ahora bodeguero: /pedidos -> 403" "$(code e4_$SUF /pedidos)" 403
check "ahora bodeguero: /furgones -> 200" "$(code e4_$SUF /furgones)" 200
post admin "/usuarios/$USR?_method=PUT" --data-urlencode "rol_id=2" --data-urlencode "estado=inactivo" >/dev/null
check "desactivado: sesión cerrada (redirige)" "$(code e4_$SUF /furgones)" 302
check "desactivado: no puede volver a entrar" "$(login e4_$SUF 'Prueba2026x')" 401

echo "--- CP4-12 Reglas del administrador (no bloquearse)"
ADMIN_ID=$(q "SELECT usuario_id FROM usuario WHERE username='admin'")
check "admin se desactiva a sí mismo -> 400" "$(post admin "/usuarios/$ADMIN_ID?_method=PUT" --data-urlencode "rol_id=1" --data-urlencode "estado=inactivo")" 400
check "admin se quita el rol -> 400" "$(post admin "/usuarios/$ADMIN_ID?_method=PUT" --data-urlencode "rol_id=3" --data-urlencode "estado=activo")" 400
check "admin se elimina -> 409" "$(post admin "/usuarios/$ADMIN_ID?_method=DELETE")" 409
check "admin sigue activo" "$(q "SELECT CONCAT(estado,'/',rol_id) FROM usuario WHERE usuario_id=$ADMIN_ID")" activo/1

echo "--- CP4-13 Borrado de empleado con usuario: mensaje de negocio, no error SQL"
check "eliminar empleado con usuario -> 409" "$(post admin "/empleados/$EMP?_method=DELETE")" 409
grep -q "tiene un usuario del sistema" /tmp/resp.html && check "explica el motivo" si si || check "explica el motivo" no si
check "eliminar usuario de prueba" "$(post admin "/usuarios/$USR?_method=DELETE")" 302
check "ahora sí se elimina el empleado" "$(post admin "/empleados/$EMP?_method=DELETE")" 302
check "teléfonos borrados en cascada" "$(q "SELECT COUNT(*) FROM empleado_telefono WHERE empleado_id=$EMP")" 0

echo "--- CP4-14 Cancelación de pedido desde la web (vendedor)"
CLI=$(q "SELECT MIN(cliente_id) FROM cliente WHERE tipo_cliente_id=1")
VAR=$(q "SELECT variante_id FROM variante_producto ORDER BY stock_actual DESC, variante_id LIMIT 1")
S0=$(q "SELECT stock_actual FROM variante_producto WHERE variante_id=$VAR")
post ventas /pedidos --data-urlencode "cliente_id=$CLI" --data-urlencode "lineas[0][variante_id]=$VAR" --data-urlencode "lineas[0][presentacion_id]=1" --data-urlencode "lineas[0][cantidad]=3" >/dev/null
PED=$(q "SELECT MAX(pedido_id) FROM pedido")
check "stock baja 3 al vender" "$(q "SELECT stock_actual FROM variante_producto WHERE variante_id=$VAR")" $((S0-3))
check "cancelar pedido" "$(post ventas /pedidos/$PED/cancelar)" 302
check "stock vuelve al original" "$(q "SELECT stock_actual FROM variante_producto WHERE variante_id=$VAR")" $S0
check "estado cancelado" "$(q "SELECT estado FROM pedido WHERE pedido_id=$PED")" cancelado
check "kardex 'cancelacion' con pedido" "$(q "SELECT COUNT(*) FROM movimiento_stock WHERE pedido_id=$PED AND tipo_movimiento='cancelacion'")" 1
check "cancelar otra vez -> 400" "$(post ventas /pedidos/$PED/cancelar)" 400
grep -q "Solo se pueden cancelar pedidos pendientes" /tmp/resp.html && check "mensaje de negocio (no SQL crudo)" si si || check "mensaje de negocio (no SQL crudo)" no si

echo "--- CP4-15 Reportes cuadran con la BD"
curl -s -b /tmp/admin.jar "$B/reportes" > /tmp/rep.html
WEB=$(grep -o 'Monto vendido</span><strong>Q [0-9,.]*' /tmp/rep.html | sed 's/.*Q //;s/,//g')
check "monto en pantalla = SUM(total_pedido) completados" "$WEB" "$(q "SELECT SUM(total_pedido) FROM pedido WHERE estado='completado'")"
check "rango invertido -> mensaje" "$(curl -s -b /tmp/admin.jar "$B/reportes?desde=2026-09-01&hasta=2026-08-01" | grep -c 'no puede ser posterior')" 1

echo "=================================================="
echo "RESULTADO: $OK OK, $FALLA FALLA"
[ $FALLA -eq 0 ]

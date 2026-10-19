#!/usr/bin/env bash
# =============================================================================
# Archivo:      entrega4_casos_catalogos.sh
# Autor:        Equipo Pavanamoon
# Descripción:  Casos CP4-16 a CP4-22: módulo Catálogos (categorías, tallas,
#               colores, tipos de cliente y presentaciones de venta).
#               Verifica acceso por rol, validaciones, duplicados, borrado con
#               FK en uso, protección del historial de presentaciones y que el
#               descuento del tipo de cliente llegue a fn_calcular_precio_linea.
#               Deja la BD como la encontró (borra lo que crea y restaura lo
#               que edita). Imprime OK/FALLA por verificación y un resumen.
# Uso:          bash entrega4_casos_catalogos.sh   (app corriendo; APP_URL opcional)
# Dependencias: app web levantada, BD instalada según INSTALL.md, cliente mysql
#               (MYSQL="mysql -uroot -pCLAVE" si root tiene contraseña)
# =============================================================================
B=${APP_URL:-http://localhost:3000}
MYSQL=${MYSQL:-"mysql -uroot"}
OK=0; FALLA=0
q(){ $MYSQL -N --default-character-set=utf8mb4 -e "$1" pavanamoon; }
check(){ if [ "$2" == "$3" ]; then echo "  OK    $1"; OK=$((OK+1)); else echo "  FALLA $1 (esperado '$3', obtenido '$2')"; FALLA=$((FALLA+1)); fi; }
contiene(){ grep -q "$2" /tmp/resp.html && check "$1" si si || check "$1" no si; }
login(){ rm -f /tmp/$1.jar; curl -s -c /tmp/$1.jar -b /tmp/$1.jar -o /dev/null -w "%{http_code}" --data-urlencode "username=$1" --data-urlencode "password=$2" $B/login; }
code(){ curl -s -b /tmp/$1.jar -o /tmp/resp.html -w "%{http_code}" "$B$2"; }
post(){ local u=$1 ruta=$2; shift 2; curl -s -X POST -b /tmp/$u.jar -c /tmp/$u.jar -o /tmp/resp.html -w "%{http_code}" "$@" "$B$ruta"; }

check "login admin"  "$(login admin  'Admin#2026')"  302
check "login bodega" "$(login bodega 'Bodega#2026')" 302
check "login ventas" "$(login ventas 'Ventas#2026')" 302

echo "--- CP4-16 Acceso: solo administrador"
for k in categorias tallas colores tipos-cliente presentaciones; do
  check "admin  /catalogos/$k" "$(code admin /catalogos/$k)" 200
done
check "bodega /catalogos/colores -> 403" "$(code bodega /catalogos/colores)" 403
check "ventas /catalogos/colores -> 403" "$(code ventas /catalogos/colores)" 403
check "ventas no puede crear (POST) -> 403" "$(post ventas /catalogos/colores --data-urlencode 'nombre_color=intruso')" 403
check "catálogo inexistente -> 404" "$(code admin /catalogos/rol)" 404
check "menú del admin muestra Catálogos" "$(curl -s -b /tmp/admin.jar $B/ | grep -q 'href="/catalogos"' && echo si)" si

echo "--- CP4-17 Colores: alta normalizada, duplicado, validación, edición, borrado"
check "alta '  Verde   Limón '" "$(post admin /catalogos/colores --data-urlencode 'nombre_color=  Verde   Limón ')" 302
ID=$(q "SELECT color_id FROM color WHERE nombre_color='verde limón'")
check "guardado en minúsculas y sin espacios extra" "$([ -n "$ID" ] && echo si)" si
check "duplicado 'VERDE LIMÓN' -> 400" "$(post admin /catalogos/colores --data-urlencode 'nombre_color=VERDE LIMÓN')" 400
contiene "mensaje de duplicado" "Ya existe"
check "con números 'r3d' -> 400" "$(post admin /catalogos/colores --data-urlencode 'nombre_color=r3d')" 400
check "editar a 'verde menta'" "$(post admin "/catalogos/colores/$ID?_method=PUT" --data-urlencode 'nombre_color=verde menta')" 302
check "eliminar color sin uso" "$(post admin "/catalogos/colores/$ID?_method=DELETE")" 302
check "ya no existe" "$(q "SELECT COUNT(*) FROM color WHERE color_id=$ID")" 0
USADO=$(q "SELECT color_id FROM variante_producto GROUP BY color_id ORDER BY COUNT(*) DESC LIMIT 1")
check "eliminar color en uso -> 409" "$(post admin "/catalogos/colores/$USADO?_method=DELETE")" 409
contiene "explica cuántas variantes lo usan" "variante(s) de producto"
check "el color en uso sigue existiendo" "$(q "SELECT COUNT(*) FROM color WHERE color_id=$USADO")" 1

echo "--- CP4-18 Tallas"
NUEVA=$(q "SELECT v FROM (SELECT '45' v UNION SELECT '46' UNION SELECT '47') x WHERE v NOT IN (SELECT valor_talla FROM talla) LIMIT 1")
check "alta talla $NUEVA" "$(post admin /catalogos/tallas --data-urlencode "valor_talla=$NUEVA")" 302
check "media talla '38,5' se guarda como 38.5" "$(post admin /catalogos/tallas --data-urlencode 'valor_talla=38,5')" 302
check "duplicada -> 400" "$(post admin /catalogos/tallas --data-urlencode "valor_talla=$NUEVA")" 400
check "fuera de rango '99' -> 400" "$(post admin /catalogos/tallas --data-urlencode 'valor_talla=99')" 400
check "texto 'XL' -> 400" "$(post admin /catalogos/tallas --data-urlencode 'valor_talla=XL')" 400
for v in "$NUEVA" "38.5"; do
  T=$(q "SELECT talla_id FROM talla WHERE valor_talla='$v'")
  check "eliminar talla $v sin uso" "$(post admin "/catalogos/tallas/$T?_method=DELETE")" 302
done
TU=$(q "SELECT talla_id FROM variante_producto LIMIT 1")
check "eliminar talla en uso -> 409" "$(post admin "/catalogos/tallas/$TU?_method=DELETE")" 409

echo "--- CP4-19 Categorías (ck_categoria_nombre)"
check "valor fuera de la regla 'senior' -> 400" "$(post admin /catalogos/categorias --data-urlencode 'nombre_categoria=senior')" 400
check "duplicada 'adulto' -> 400" "$(post admin /catalogos/categorias --data-urlencode 'nombre_categoria=adulto')" 400
CA=$(q "SELECT categoria_id FROM categoria WHERE nombre_categoria='adulto'")
check "eliminar categoría con productos -> 409" "$(post admin "/catalogos/categorias/$CA?_method=DELETE")" 409
contiene "explica cuántos productos" "producto(s)"
check "con las 3 categorías no se ofrece 'Nueva'" "$(curl -s -b /tmp/admin.jar $B/catalogos/categorias | grep -c '/catalogos/categorias/nuevo')" 0

echo "--- CP4-20 Tipos de cliente: descuento llega a fn_calcular_precio_linea"
check "alta 'distribuidor' 20 %" "$(post admin /catalogos/tipos-cliente --data-urlencode 'nombre=distribuidor' --data-urlencode 'descripcion=Prueba E4' --data-urlencode 'porcentaje_descuento=20')" 302
TD=$(q "SELECT tipo_cliente_id FROM tipo_cliente WHERE nombre='distribuidor'")
check "descuento guardado" "$(q "SELECT porcentaje_descuento FROM tipo_cliente WHERE tipo_cliente_id=$TD")" 20.00
check "descuento 60 % -> 400 (máx 50)" "$(post admin /catalogos/tipos-cliente --data-urlencode 'nombre=otro' --data-urlencode 'porcentaje_descuento=60')" 400
check "descuento negativo -> 400" "$(post admin /catalogos/tipos-cliente --data-urlencode 'nombre=otro' --data-urlencode 'porcentaje_descuento=-5')" 400
TM=$(q "SELECT tipo_cliente_id FROM tipo_cliente WHERE nombre='mayorista'")
DESC0=$(q "SELECT porcentaje_descuento FROM tipo_cliente WHERE tipo_cliente_id=$TM")
CM=$(q "SELECT MIN(cliente_id) FROM cliente WHERE tipo_cliente_id=$TM")
VR=$(q "SELECT MIN(variante_id) FROM variante_producto")
PRECIO_PAR=$(q "SELECT p.precio_venta FROM variante_producto v JOIN producto p USING(producto_id) WHERE v.variante_id=$VR")
DETALLE0=$(q "SELECT COALESCE(SUM(precio_unitario),0) FROM detalle_pedido")
post admin "/catalogos/tipos-cliente/$TM?_method=PUT" --data-urlencode 'nombre=mayorista' --data-urlencode 'descripcion=Comercio o revendedor que compra en volumen (B2B)' --data-urlencode 'porcentaje_descuento=20' >/dev/null
check "precio mayorista unidad con 20 %" "$(q "SELECT fn_calcular_precio_linea($VR, 1, $CM)")" "$(q "SELECT ROUND($PRECIO_PAR*0.80,2)")"
check "precios ya vendidos NO cambian" "$(q "SELECT COALESCE(SUM(precio_unitario),0) FROM detalle_pedido")" "$DETALLE0"
post admin "/catalogos/tipos-cliente/$TM?_method=PUT" --data-urlencode 'nombre=mayorista' --data-urlencode 'descripcion=Comercio o revendedor que compra en volumen (B2B)' --data-urlencode "porcentaje_descuento=$DESC0" >/dev/null
check "descuento mayorista restaurado" "$(q "SELECT porcentaje_descuento FROM tipo_cliente WHERE tipo_cliente_id=$TM")" "$DESC0"
TI=$(q "SELECT tipo_cliente_id FROM tipo_cliente WHERE nombre='individual'")
check "eliminar tipo con clientes -> 409" "$(post admin "/catalogos/tipos-cliente/$TI?_method=DELETE")" 409
check "eliminar 'distribuidor' sin clientes" "$(post admin "/catalogos/tipos-cliente/$TD?_method=DELETE")" 302

echo "--- CP4-21 Presentaciones: protección del historial y desactivación"
PU=$(q "SELECT presentacion_id FROM presentacion_venta WHERE nombre='unidad'")
PC=$(q "SELECT presentacion_id FROM presentacion_venta WHERE nombre='caja'")
check "alta 'media caja' (6 pares)" "$(post admin /catalogos/presentaciones --data-urlencode 'nombre=media caja' --data-urlencode 'cantidad_pares=6' --data-urlencode 'estado=activo')" 302
PM=$(q "SELECT presentacion_id FROM presentacion_venta WHERE nombre='media caja'")
check "aparece en el formulario de pedidos" "$(curl -s -b /tmp/ventas.jar $B/pedidos/nuevo | grep -q 'media caja' && echo si)" si
check "0 pares -> 400" "$(post admin /catalogos/presentaciones --data-urlencode 'nombre=vacia' --data-urlencode 'cantidad_pares=0' --data-urlencode 'estado=activo')" 400
check "sin uso: sí puede cambiar a 8 pares" "$(post admin "/catalogos/presentaciones/$PM?_method=PUT" --data-urlencode 'nombre=media caja' --data-urlencode 'cantidad_pares=8' --data-urlencode 'estado=activo')" 302
check "en uso: cambiar pares de 'unidad' -> 400" "$(post admin "/catalogos/presentaciones/$PU?_method=PUT" --data-urlencode 'nombre=unidad' --data-urlencode 'cantidad_pares=2' --data-urlencode 'estado=activo')" 400
contiene "explica por qué (historial)" "No se puede cambiar la cantidad de pares"
check "'unidad' conserva 1 par" "$(q "SELECT cantidad_pares FROM presentacion_venta WHERE presentacion_id=$PU")" 1
check "desactivar 'media caja'" "$(post admin "/catalogos/presentaciones/$PM?_method=PUT" --data-urlencode 'nombre=media caja' --data-urlencode 'cantidad_pares=8' --data-urlencode 'estado=inactivo')" 302
check "inactiva ya no se ofrece en pedidos" "$(curl -s -b /tmp/ventas.jar $B/pedidos/nuevo | grep -c 'media caja')" 0
check "eliminar 'caja' en uso -> 409" "$(post admin "/catalogos/presentaciones/$PC?_method=DELETE")" 409
contiene "sugiere desactivar" "cámbiala a inactiva"
post admin "/catalogos/presentaciones/$PC?_method=PUT" --data-urlencode 'nombre=caja' --data-urlencode 'cantidad_pares=12' --data-urlencode 'estado=inactivo' >/dev/null
check "desactivar la ÚLTIMA activa -> 400" "$(post admin "/catalogos/presentaciones/$PU?_method=PUT" --data-urlencode 'nombre=unidad' --data-urlencode 'cantidad_pares=1' --data-urlencode 'estado=inactivo')" 400
contiene "explica que debe quedar una activa" "al menos una presentación activa"
post admin "/catalogos/presentaciones/$PC?_method=PUT" --data-urlencode 'nombre=caja' --data-urlencode 'cantidad_pares=12' --data-urlencode 'estado=activo' >/dev/null
check "'caja' reactivada" "$(q "SELECT estado FROM presentacion_venta WHERE presentacion_id=$PC")" activo
check "eliminar 'media caja' sin uso" "$(post admin "/catalogos/presentaciones/$PM?_method=DELETE")" 302

echo "--- CP4-22 Inyección SQL y entradas maliciosas"
check "clave con SQL en la URL -> 404" "$(code admin "/catalogos/color%3BDROP%20TABLE%20color")" 404
check "valor con SQL -> 400 (validación)" "$(post admin /catalogos/colores --data-urlencode "nombre_color=rojo'; DROP TABLE color;--")" 400
check "tabla color intacta" "$(q "SELECT COUNT(*) > 0 FROM color")" 1
check "id no numérico -> 404" "$(code admin "/catalogos/colores/1%20OR%201=1/editar")" 404

echo "=================================================="
echo "RESULTADO: $OK OK, $FALLA FALLA"
[ $FALLA -eq 0 ]

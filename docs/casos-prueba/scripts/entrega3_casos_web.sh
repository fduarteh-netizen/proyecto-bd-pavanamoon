#!/usr/bin/env bash
# =============================================================================
# Archivo:      entrega3_casos_web.sh
# Autor:        Equipo Pavanamoon
# Descripción:  Caso CP3-08: control de acceso por rol en la app web y flujos
#               de pedido / ingreso contra la BD real (app corriendo en :3000).
# Dependencias: app web levantada (npm start), datos de prueba cargados
# =============================================================================
B=${APP_URL:-http://localhost:3000}
login(){ rm -f /tmp/$1.jar; curl -s -c /tmp/$1.jar -b /tmp/$1.jar -o /dev/null -w "login $1 -> HTTP %{http_code}\n" -d "username=$1&password=$2" $B/login; }
code(){ curl -s -b /tmp/$1.jar -o /dev/null -w "%{http_code}" "$B$2"; }
login admin 'Admin#2026'; login ventas 'Ventas#2026'; login bodega 'Bodega#2026'
echo "--- (a) Rutas por rol (200 = permitido, 403 = denegado)"
printf "%-12s %-10s %-10s %-10s\n" modulo admin bodega ventas
for m in productos inventario furgones ingresos clientes pedidos kardex; do
  printf "%-12s %-10s %-10s %-10s\n" $m $(code admin /$m) $(code bodega /$m) $(code ventas /$m); done
echo "--- (b) Menú visible por rol"
for u in admin bodega ventas; do echo "$u: $(curl -s -b /tmp/$u.jar $B/ | grep -o '<h2>[^<]*</h2>' | sed 's/<[^>]*>//g' | tr '\n' ' ')"; done
echo "--- (c) ventas registra pedido web (cliente mayorista 1 caja de variante 3)"
MAY=$(mysql -uroot -N -e "SELECT MIN(cliente_id) FROM pavanamoon.cliente WHERE tipo_cliente_id=2")
ANTES=$(mysql -uroot -N -e "SELECT stock_actual FROM pavanamoon.variante_producto WHERE variante_id=3")
curl -s -b /tmp/ventas.jar -o /dev/null -w "POST /pedidos -> HTTP %{http_code} %{redirect_url}\n" \
  --data-urlencode "cliente_id=$MAY" --data-urlencode "lineas[0][variante_id]=3" --data-urlencode "lineas[0][presentacion_id]=2" --data-urlencode "lineas[0][cantidad]=1" $B/pedidos
echo "stock variante 3: antes=$ANTES despues=$(mysql -uroot -N -e "SELECT stock_actual FROM pavanamoon.variante_producto WHERE variante_id=3") (esperado -12)"
mysql -uroot -t -e "SELECT pedido_id, nombre_cliente, tipo_cliente, pares_totales, total_pedido FROM pavanamoon.vw_pedidos_resumen ORDER BY pedido_id DESC LIMIT 1"
echo "--- (d) ventas intenta vender 999 cajas (stock insuficiente): mensaje de negocio y ROLLBACK"
N1=$(mysql -uroot -N -e "SELECT COUNT(*) FROM pavanamoon.pedido")
curl -s -b /tmp/ventas.jar --data-urlencode "cliente_id=$MAY" --data-urlencode "lineas[0][variante_id]=4" --data-urlencode "lineas[0][presentacion_id]=2" --data-urlencode "lineas[0][cantidad]=999" $B/pedidos | grep -o '<li>[^<]*</li>'
echo "pedidos antes=$N1 despues=$(mysql -uroot -N -e "SELECT COUNT(*) FROM pavanamoon.pedido") (esperado igual: no queda pedido huérfano)"
echo "--- (e) bodega registra ingreso web de 30 pares a variante 5"
ANTES=$(mysql -uroot -N -e "SELECT stock_actual FROM pavanamoon.variante_producto WHERE variante_id=5")
curl -s -b /tmp/bodega.jar -o /dev/null -w "POST /ingresos -> HTTP %{http_code} %{redirect_url}\n" \
  --data-urlencode "furgon_id=1" --data-urlencode "bodega_destino=Bodega Central Xela" --data-urlencode "lineas[0][variante_id]=5" --data-urlencode "lineas[0][cantidad]=30" --data-urlencode "lineas[0][costo_unitario]=95.50" $B/ingresos
echo "stock variante 5: antes=$ANTES despues=$(mysql -uroot -N -e "SELECT stock_actual FROM pavanamoon.variante_producto WHERE variante_id=5") (esperado +30)"
echo "--- (f) ventas escribe a mano la URL de furgones"
curl -s -b /tmp/ventas.jar $B/furgones | grep -o 'Tu rol[^<]*'

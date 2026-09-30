#!/usr/bin/env bash
# =============================================================================
# Archivo:      entrega3_casos_seguridad.sh
# Autor:        Equipo Pavanamoon
# Descripción:  Casos CP3-06 y CP3-07: privilegios diferenciados por rol de
#               MySQL. Usa las contraseñas PLACEHOLDER de
#               sql/security/01_roles_privilegios.sql (solo ambiente local).
# Dependencias: sql/security/01_roles_privilegios.sql ya ejecutado
# =============================================================================
H=${DB_HOST:-127.0.0.1}
run(){ echo "[$1] $3"; mysql -h "$H" -u "$1" -p"$2" pavanamoon -e "$3" 2>&1 | grep -v "Using a password" | sed 's/^/    /'; }
echo "=== CP3-06 rol_vendedor ==="
run pvm_ventas 'Cambiar#Ventas2026' "SELECT CURRENT_ROLE();"
run pvm_ventas 'Cambiar#Ventas2026' "SELECT COUNT(*) AS clientes_visibles FROM cliente;"
run pvm_ventas 'Cambiar#Ventas2026' "SELECT username, password_hash FROM usuario LIMIT 1;"
run pvm_ventas 'Cambiar#Ventas2026' "INSERT INTO furgon (numero_furgon, fecha_llegada) VALUES ('X-HACK', CURDATE());"
run pvm_ventas 'Cambiar#Ventas2026' "UPDATE variante_producto SET stock_actual = 9999 WHERE variante_id = 1;"
run pvm_ventas 'Cambiar#Ventas2026' "DELETE FROM cliente WHERE cliente_id = 1;"
run pvm_ventas 'Cambiar#Ventas2026' "CALL sp_crear_pedido(1, 3, @p); SELECT @p AS pedido_creado_por_procedimiento;"
echo "=== CP3-07 rol_bodeguero ==="
run pvm_bodega 'Cambiar#Bodega2026' "SELECT COUNT(*) FROM cliente;"
run pvm_bodega 'Cambiar#Bodega2026' "SELECT COUNT(*) FROM pedido;"
run pvm_bodega 'Cambiar#Bodega2026' "INSERT INTO furgon (numero_furgon, fecha_llegada, estado) VALUES ('FRG-PRUEBA-SEG', CURDATE(), 'en_transito'); SELECT numero_furgon, estado FROM furgon WHERE numero_furgon='FRG-PRUEBA-SEG';"
run pvm_bodega 'Cambiar#Bodega2026' "DELETE FROM furgon WHERE numero_furgon='FRG-PRUEBA-SEG';"
echo "=== rol_administrador ==="
run pvm_admin 'Cambiar#Admin2026' "DELETE FROM furgon WHERE numero_furgon='FRG-PRUEBA-SEG'; DELETE FROM pedido WHERE estado='pendiente' AND total_pedido=0; SELECT 'admin puede borrar (limpieza de datos de prueba)' AS resultado;"

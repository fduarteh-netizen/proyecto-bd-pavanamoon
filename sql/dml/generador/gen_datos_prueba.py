# Generador reproducible (semilla fija) de sql/dml/01_datos_prueba.sql.
# Uso: python3 sql/dml/generador/gen_datos_prueba.py
# Hashes bcrypt precalculados de las contraseñas de prueba (solo local, R6).
import os, random, datetime
random.seed(2026)
out=[]
w=out.append
H_BOD='$2a$10$haKS55FXIZOx.DK22qu9vuhNUi3nDqi7.Gt6T9L9L650WGUWx952y'
H_VEN='$2a$10$tyk0HgShFmTQ6eRkevlEGumKDz0sjfsnF1EpFC79sxSNpqv1QAbXm'
w("""-- =============================================================================
-- Archivo:      01_datos_prueba.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Carga masiva de datos de prueba (Sección 5, req. 7: mínimo 50
--               registros por tabla principal). Generado de forma
--               reproducible (semilla fija) y revisado por el equipo.
--               Los datos son CONSISTENTES: el stock_actual de cada variante
--               es exactamente entradas - salidas + devoluciones registradas
--               en movimiento_stock, y pedido.total_pedido = SUM(subtotal).
--               También agrega 2 usuarios de prueba (uno por rol restante):
--                 bodega / Bodega#2026  (rol bodeguero)
--                 ventas / Ventas#2026  (rol vendedor)
--               SOLO para ambiente local de pruebas (estándar R6).
-- IMPORTANTE:   Ejecutar ANTES de sql/triggers/ (orden de INSTALL.md). Si los
--               triggers ya existen, los INSERT de detalle volverían a mover
--               el stock y se duplicarían los movimientos.
-- Dependencias: sql/ddl/01..06, sql/dml/00_seed_minimo.sql
-- Estándar:     S1, S2, S3, R6
-- =============================================================================

USE pavanamoon;

-- Fuerza UTF-8 en la sesión del cliente para que los acentos se carguen bien
-- (sin esto, algunos clientes cargan 'Salcajá' como 'SalcajÃ¡').
SET NAMES utf8mb4;

-- Descuento por segmento de cliente (RF13): mayorista 15 %, individual 0 %.
UPDATE tipo_cliente SET porcentaje_descuento = 0  WHERE nombre = 'individual';
UPDATE tipo_cliente SET porcentaje_descuento = 15 WHERE nombre = 'mayorista';

-- Catálogos adicionales (tallas de niño/juvenil y más colores).
INSERT INTO talla (valor_talla) VALUES ('26'),('28'),('30'),('32'),('35'),('37'),('39'),('41'),('43');
INSERT INTO color (nombre_color) VALUES ('verde'),('amarillo'),('naranja'),('gris'),('morado'),('celeste');
""")
NT=15; NC=10
nombres=['Carlos','María','José','Ana','Luis','Sofía','Jorge','Lucía','Pedro','Carmen','Miguel','Andrea','Diego','Paola','Javier','Gabriela','Ricardo','Daniela','Oscar','Fernanda','Mario','Karla','Hugo','Silvia','Erick']
apellidos=['López','García','Pérez','Hernández','Martínez','Morales','Ramírez','Castillo','Gómez','Reyes','Cruz','Juárez','Méndez','Ortiz','Rodas','Barrios','Cifuentes','Estrada','Velásquez','Monzón']
def persona(): return f"{random.choice(nombres)} {random.choice(nombres)} {random.choice(apellidos)} {random.choice(apellidos)}"
def tel(): return f"{random.choice('345')}{random.randint(1000000,9999999)}"
def q(s): return "'"+s.replace("'","''")+"'"
# EMPLEADOS 2..56
w("\n-- EMPLEADO (55 adicionales) y sus teléfonos\nINSERT INTO empleado (empleado_id, nombres_apellidos, dpi) VALUES")
rows=[]; tels=[]
for i in range(2,57):
    rows.append(f"    ({i}, {q(persona())}, '{2000000000000+i*7919}')")
    tels.append(f"    ({i}, '{tel()}')")
w(",\n".join(rows)+";")
w("INSERT INTO empleado_telefono (empleado_id, telefono) VALUES\n"+",\n".join(tels)+";")
# USUARIOS
w("\n-- USUARIO: bodega y ventas (credenciales de prueba) + 50 cuentas de empleados")
urows=[f"    ('bodega', '{H_BOD}', 'activo', 2, 2)", f"    ('ventas', '{H_VEN}', 'activo', 3, 3)"]
for i in range(4,54):
    rol=random.choice([2,3,3]); est='activo' if random.random()<0.85 else 'inactivo'
    urows.append(f"    ('emp{i:03d}', '{H_VEN if rol==3 else H_BOD}', '{est}', {rol}, {i})")
w("INSERT INTO usuario (username, password_hash, estado, rol_id, empleado_id) VALUES\n"+",\n".join(urows)+";")
# PRODUCTOS
modelos=['Striker','Velocity','Phantom','Titan','Falcon','Blaze','Comet','Viper','Storm','Rocket','Thunder','Eclipse','Nova','Predator','Legend','Fury','Apex','Pulse','Orion','Zenit']
w("\n-- PRODUCTO (55)\nINSERT INTO producto (producto_id, categoria_id, modelo, tipo_suela, precio_venta) VALUES")
prods=[]; precio={}
for i in range(1,56):
    cat=random.randint(1,3); base={1:180,2:260,3:340}[cat]
    p=base+random.choice([0,20,40,60,80,100,120])+0.00
    precio[i]=p
    prods.append(f"    ({i}, {cat}, '{random.choice(modelos)} {['Kids','Junior','Pro'][cat-1]} {i:02d}', '{random.choice(['hule','flex','tpu'])}', {p:.2f})")
w(",\n".join(prods)+";")
# VARIANTES
w("\n-- VARIANTE_PRODUCTO (165): stock_actual se calcula al final del script")
var=[]; vid=0; combos=set()
for p in range(1,56):
    for _ in range(3):
        while True:
            t=random.randint(1,NT); c=random.randint(1,NC)
            if (p,t,c) not in combos: combos.add((p,t,c)); break
        vid+=1; var.append((vid,p,t,c))
w("INSERT INTO variante_producto (variante_id, producto_id, talla_id, color_id, sku, stock_actual, stock_minimo) VALUES\n"+
  ",\n".join(f"    ({v}, {p}, {t}, {c}, 'PVM-{p:03d}-T{t:02d}-C{c:02d}', 0, {random.choice([5,5,8,10])})" for v,p,t,c in var)+";")
NV=len(var); stock={v[0]:0 for v in var}; movs=[]
# CLIENTES
empresas=['Deportes','Calzado','Distribuidora','Comercial','Tienda','Almacén']
lugares=['Xela','Quetzaltenango','Totonicapán','San Marcos','Huehuetenango','Retalhuleu','Mazatenango','Guatemala','Salcajá','Olintepeque']
w("\n-- CLIENTE (60) y sus teléfonos")
cl=[]; ctel=[]; tipo={}
for i in range(1,61):
    t=2 if random.random()<0.35 else 1; tipo[i]=t
    nom = f"{random.choice(empresas)} {random.choice(lugares)} {i}" if t==2 else persona()
    cl.append(f"    ({i}, {t}, {q(nom)}, '{random.randint(1000000,99999999)}{random.choice('0123456789K')}')")
    ctel.append(f"    ({i}, '{tel()}')")
w("INSERT INTO cliente (cliente_id, tipo_cliente_id, nombre_cliente, nit) VALUES\n"+",\n".join(cl)+";")
w("INSERT INTO cliente_telefono (cliente_id, telefono) VALUES\n"+",\n".join(ctel)+";")
# FURGONES
w("\n-- FURGON (55)")
start=datetime.date(2026,5,1); fur=[]; fdate={}
for i in range(1,56):
    d=start+datetime.timedelta(days=i*2); fdate[i]=d
    est='recibido' if i<=52 else 'en_transito'
    fur.append(f"    ({i}, 'FRG-2026-{i:04d}', '{d}', {q(random.choice(['Puerto Quetzal','Santo Tomás de Castilla','Tecún Umán','Ciudad de Guatemala']))}, {q(random.choice(['Transportes Quetzal','Trans Altense','Carga Express GT','Fletes del Occidente']))}, '{est}')")
w("INSERT INTO furgon (furgon_id, numero_furgon, fecha_llegada, procedencia, transportista, estado) VALUES\n"+",\n".join(fur)+";")
# INGRESOS: 60 ingresos sobre furgones recibidos 1..52; garantizar que toda variante reciba al menos una entrada
w("\n-- INGRESO_MERCADERIA (60) y DETALLE_INGRESO")
ing=[]; det=[]; pend=list(range(1,NV+1)); random.shuffle(pend)
bodeg=[2]+[i for i in range(4,57) if random.random()<0.3]
for i in range(1,61):
    f=((i-1)%52)+1; d=fdate[f]; emp=random.choice(bodeg)
    fecha=f"{d} {random.randint(7,16):02d}:{random.randint(0,59):02d}:00"
    ing.append(f"    ({i}, {f}, {emp}, '{fecha}', {q(random.choice(['Bodega Central Xela','Bodega Norte']))}, 'completado')")
    chosen=set()
    for _ in range(3):
        v = pend.pop() if pend else random.randint(1,NV)
        if v in chosen: continue
        chosen.add(v); cant=random.choice([24,36,48,60])
        costo=round(precio[var[v-1][1]]*0.45,2)
        det.append(f"    ({i}, {v}, {cant}, {costo:.2f})")
        stock[v]+=cant; movs.append((v,emp,'entrada',cant,fecha))
w("INSERT INTO ingreso_mercaderia (ingreso_id, furgon_id, empleado_id, fecha_ingreso, bodega_destino, estado) VALUES\n"+",\n".join(ing)+";")
w("INSERT INTO detalle_ingreso (ingreso_id, variante_id, cantidad, costo_unitario) VALUES\n"+",\n".join(det)+";")
# PEDIDOS
w("\n-- PEDIDO (60) y DETALLE_PEDIDO (precio = precio_venta * pares_presentacion * (1 - descuento))")
ped=[]; dped=[]; totals={}
vend=[3]+[i for i in range(4,57) if i not in bodeg][:15]
pstart=datetime.datetime(2026,8,1,9,0)
for i in range(1,61):
    c=random.randint(1,60); emp=random.choice(vend)
    fecha=pstart+datetime.timedelta(hours=i*13+random.randint(0,5))
    est='completado' if i<=52 else 'pendiente'
    ped.append(f"    ({i}, {c}, {emp}, '{fecha:%Y-%m-%d %H:%M:%S}', 0, '{est}')")
    chosen=set(); tot=0
    for _ in range(random.randint(1,3)):
        v=random.randint(1,NV)
        if v in chosen: continue
        pres=2 if (tipo[c]==2 and stock[v]>=12 and random.random()<0.6) else 1
        pares=12 if pres==2 else 1
        maxq=stock[v]//pares
        if maxq<1: continue
        cant=min(maxq, random.randint(1,2) if pres==2 else random.randint(1,4))
        desc=15 if tipo[c]==2 else 0
        pu=round(precio[var[v-1][1]]*pares*(1-desc/100),2)
        chosen.add(v); dped.append(f"    ({i}, {v}, {pres}, {cant}, {pu:.2f})")
        stock[v]-=cant*pares; tot+=cant*pu
        movs.append((v,emp,'salida',cant*pares,f"{fecha:%Y-%m-%d %H:%M:%S}"))
w("INSERT INTO pedido (pedido_id, cliente_id, empleado_id, fecha_pedido, total_pedido, estado) VALUES\n"+",\n".join(ped)+";")
w("INSERT INTO detalle_pedido (pedido_id, variante_id, presentacion_id, cantidad, precio_unitario) VALUES\n"+",\n".join(dped)+";")
# devoluciones de ejemplo
for k in range(6):
    v=random.choice([m[0] for m in movs if m[2]=='salida']); stock[v]+=1
    movs.append((v,3,'devolucion_cliente',1,f"2026-09-{10+k:02d} 10:00:00"))
w("\n-- MOVIMIENTO_STOCK (kardex histórico consistente con ingresos, pedidos y devoluciones)")
movs.sort(key=lambda m:m[4])
w("INSERT INTO movimiento_stock (variante_id, empleado_id, tipo_movimiento, cantidad, fecha_movimiento) VALUES\n"+
  ",\n".join(f"    ({v}, {e}, '{t}', {c}, '{f}')" for v,e,t,c,f in movs)+";")
w("""
-- Stock actual derivado del kardex (entradas + devoluciones - salidas).
UPDATE variante_producto vp
   SET vp.stock_actual = (
       SELECT COALESCE(SUM(CASE WHEN ms.tipo_movimiento IN ('entrada','devolucion_cliente') THEN ms.cantidad
                                WHEN ms.tipo_movimiento = 'salida' THEN -ms.cantidad ELSE 0 END), 0)
         FROM movimiento_stock ms WHERE ms.variante_id = vp.variante_id);

-- Total de cada pedido = suma de sus subtotales (columna generada).
UPDATE pedido p
   SET p.total_pedido = (SELECT COALESCE(SUM(dp.subtotal), 0)
                           FROM detalle_pedido dp WHERE dp.pedido_id = p.pedido_id);
""")
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '01_datos_prueba.sql'),'w').write("\n".join(out))
print(NV, len(det), len(dped), len(movs), min(stock.values()))

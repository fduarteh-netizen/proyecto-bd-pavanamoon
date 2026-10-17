-- =============================================================================
-- Archivo:      07_ajustes_entrega4.sql
-- Autor:        Equipo Pavanamoon
-- Descripción:  Ajuste de esquema requerido por la Entrega 4 sobre
--               MOVIMIENTO_STOCK. Se ejecuta ANTES del DML (ver INSTALL.md).
--
--   1) Columna pedido_id (FK opcional a pedido).
--      Problema detectado en pruebas de la Entrega 4: el kardex no sabía a
--      qué pedido pertenecía cada movimiento. Por eso sp_registrar_devolucion
--      no podía sumar lo ya devuelto y aceptaba devolver la misma línea
--      varias veces (un pedido de 3 pares admitió 3 devoluciones de 3 pares
--      e infló el stock en 9). Con esta referencia:
--        - lo ya devuelto se CALCULA desde el kardex (S7: no se guarda un
--          contador redundante en detalle_pedido);
--        - la cancelación de pedidos (sp_cancelar_pedido) queda trazable;
--        - el kardex muestra el documento que originó cada salida.
--      Es NULL para entradas por ingreso de mercadería y para los
--      movimientos históricos cargados antes de la Entrega 4.
--      ON DELETE RESTRICT: un pedido con movimientos no puede borrarse;
--      el historial del kardex es auditable (RF16) y nunca se pierde.
--
--   2) Nuevo valor 'cancelacion' en tipo_movimiento.
--      Reintegro de stock al cancelar un pedido pendiente. Se separa de
--      'devolucion_cliente' porque el negocio los reporta distinto: una
--      devolución ocurre después de entregar; una cancelación, antes.
--
--   En el modelo ER esto agrega la relación "origina":
--   PEDIDO (0,N) — MOVIMIENTO_STOCK (0,1).
--
-- Dependencias: 05_tablas_transacciones.sql
-- Estándar:     S1, S2, S3, S4 (FK con ON DELETE / ON UPDATE documentados), S7
-- =============================================================================

USE pavanamoon;

ALTER TABLE movimiento_stock
    MODIFY COLUMN tipo_movimiento
        ENUM('entrada', 'salida', 'devolucion_cliente', 'ajuste', 'cancelacion') NOT NULL,
    ADD COLUMN pedido_id INT NULL
        COMMENT 'Pedido que originó el movimiento (salida, devolución, cancelación). NULL en entradas',
    ADD CONSTRAINT fk_movimiento_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido(pedido_id)
        ON DELETE RESTRICT ON UPDATE CASCADE;

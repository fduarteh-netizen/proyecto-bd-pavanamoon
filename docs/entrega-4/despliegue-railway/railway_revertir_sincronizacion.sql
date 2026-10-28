-- =============================================================================
-- Archivo:      railway_revertir_sincronizacion.sql
-- Autor:        Equipo Pavanamoon (preparado con asistencia de IA, ver bitácora)
-- Descripción:  VUELTA ATRÁS de railway_sincronizar_con_repo.sql.
--               Devuelve los objetos programados de `railway` al estado en que
--               los dejó el paquete pavanamoon_railway_estructura_segura.sql
--               (instalado el 20/10/2026). NO toca tablas ni datos.
--
--   Úselo SOLO si, después de sincronizar, la aplicación falla y se necesita
--   volver de inmediato al estado anterior (con el defecto de RF14 que
--   existía). Recrea, copiados SIN CAMBIOS del paquete instalado:
--     - trg_registrar_entrada_ingreso (y elimina trg_detalle_ingreso_ai)
--     - vw_pedidos_resumen antigua (8 columnas)
--     - sp_crear_pedido antiguo
--     - vw_kardex_movimientos, vw_stock_bajo_minimo, vw_ventas_por_categoria
--     - sp_agregar_variante_ingreso, sp_agregar_variante_pedido,
--       sp_cambiar_estado_pedido, sp_completar_ingreso, sp_registrar_ingreso
--     - fn_calcular_total_pedido
--   Resultado esperado: 19 tablas, 9 vistas, 2 funciones, 9 procedimientos,
--   3 triggers; railway_verificar.sql da "ESTADO ANTERIOR".
--
--   Supuesto: antes de sincronizar, railway_verificar.sql dio el veredicto
--   "ESTADO ANTERIOR (dump local)". Si dio otro veredicto, este archivo NO
--   representa su estado previo: use el respaldo completo.
--   Es repetible (IF EXISTS antes de cada CREATE).
-- =============================================================================

USE railway;
SET NAMES utf8mb4;

-- 1) Trigger de ingresos: quitar el del repositorio y recrear el anterior
DROP TRIGGER IF EXISTS trg_detalle_ingreso_ai;
DROP TRIGGER IF EXISTS trg_registrar_entrada_ingreso;

/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50003 TRIGGER `trg_registrar_entrada_ingreso` AFTER INSERT ON `detalle_ingreso` FOR EACH ROW BEGIN
    DECLARE v_empleado_id INT;

    SELECT empleado_id INTO v_empleado_id
    FROM ingreso_mercaderia WHERE ingreso_id = NEW.ingreso_id;

    UPDATE variante_producto
    SET stock_actual = stock_actual + NEW.cantidad
    WHERE variante_id = NEW.variante_id;

    INSERT INTO movimiento_stock (variante_id, empleado_id, tipo_movimiento, cantidad)
    VALUES (NEW.variante_id, v_empleado_id, 'entrada', NEW.cantidad);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

-- 2) Funciones y procedimientos anteriores
DROP FUNCTION IF EXISTS fn_calcular_total_pedido;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `fn_calcular_total_pedido`(p_pedido_id INT) RETURNS decimal(12,2)
    READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT COALESCE(SUM(subtotal), 0) INTO v_total
    FROM detalle_pedido
    WHERE pedido_id = p_pedido_id;

    RETURN v_total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

DROP PROCEDURE IF EXISTS sp_crear_pedido;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `sp_crear_pedido`(
    IN p_cliente_id INT, IN p_empleado_id INT, OUT p_pedido_id INT
  )
BEGIN
    INSERT INTO pedido (cliente_id, empleado_id, estado, total_pedido)
    VALUES (p_cliente_id, p_empleado_id, 'pendiente', 0);
    SET p_pedido_id = LAST_INSERT_ID();
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

DROP PROCEDURE IF EXISTS sp_agregar_variante_ingreso;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `sp_agregar_variante_ingreso`(
    IN p_ingreso_id     INT,
    IN p_variante_id    INT,
    IN p_cantidad       INT,
    IN p_costo_unitario DECIMAL(10,2)
)
BEGIN
    DECLARE v_estado_ingreso VARCHAR(20);

    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esta variante ya tiene una línea en este ingreso; edita la cantidad en vez de agregarla de nuevo.';
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT estado INTO v_estado_ingreso FROM ingreso_mercaderia WHERE ingreso_id = p_ingreso_id;

    IF v_estado_ingreso IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ingreso indicado no existe.';
    ELSEIF v_estado_ingreso <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden agregar líneas a un ingreso pendiente.';
    END IF;

    START TRANSACTION;
        INSERT INTO detalle_ingreso (ingreso_id, variante_id, cantidad, costo_unitario)
        VALUES (p_ingreso_id, p_variante_id, p_cantidad, p_costo_unitario);
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

DROP PROCEDURE IF EXISTS sp_agregar_variante_pedido;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `sp_agregar_variante_pedido`(
    IN p_pedido_id       INT,
    IN p_variante_id     INT,
    IN p_presentacion_id INT,
    IN p_cantidad        INT
)
BEGIN
    DECLARE v_estado_pedido          VARCHAR(20);
    DECLARE v_precio_par             DECIMAL(10,2);
    DECLARE v_pares_por_presentacion INT;
    DECLARE v_estado_presentacion    VARCHAR(20);
    DECLARE v_precio_unitario        DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR 1062  -- ER_DUP_ENTRY
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esta variante ya fue agregada al pedido; edita la cantidad en vez de agregarla de nuevo.';
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1) El pedido debe existir y estar 'pendiente'
    SELECT estado INTO v_estado_pedido FROM pedido WHERE pedido_id = p_pedido_id;
    IF v_estado_pedido IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido indicado no existe.';
    ELSEIF v_estado_pedido <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden agregar líneas a un pedido pendiente.';
    END IF;

    -- 2) Precio por par vigente en el catálogo: variante_producto -> producto
    SELECT p.precio_venta INTO v_precio_par
    FROM variante_producto vp
    JOIN producto p ON p.producto_id = vp.producto_id
    WHERE vp.variante_id = p_variante_id;

    IF v_precio_par IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La variante de producto indicada no existe.';
    END IF;

    -- 3) Pares que trae la presentación elegida (debe estar activa)
    SELECT cantidad_pares, estado INTO v_pares_por_presentacion, v_estado_presentacion
    FROM presentacion_venta
    WHERE presentacion_id = p_presentacion_id;

    IF v_pares_por_presentacion IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La presentación de venta indicada no existe.';
    ELSEIF v_estado_presentacion <> 'activo' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La presentación de venta indicada está inactiva.';
    END IF;

    -- 4) precio_unitario = precio por par * pares de la presentación
    SET v_precio_unitario = v_precio_par * v_pares_por_presentacion;

    START TRANSACTION;
        -- trg_validar_stock_disponible valida aquí mismo (en pares) y
        -- aborta con SIGNAL si no hay stock suficiente.
        INSERT INTO detalle_pedido (pedido_id, variante_id, presentacion_id, cantidad, precio_unitario)
        VALUES (p_pedido_id, p_variante_id, p_presentacion_id, p_cantidad, v_precio_unitario);

        UPDATE pedido
        SET total_pedido = fn_calcular_total_pedido(p_pedido_id)
        WHERE pedido_id = p_pedido_id;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

DROP PROCEDURE IF EXISTS sp_cambiar_estado_pedido;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `sp_cambiar_estado_pedido`(
    IN p_pedido_id    INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_nuevo_estado NOT IN ('pendiente', 'completado', 'cancelado') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado inválido para un pedido.';
    END IF;

    SELECT estado INTO v_estado_actual FROM pedido WHERE pedido_id = p_pedido_id;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido indicado no existe.';
    ELSEIF v_estado_actual = 'completado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar un pedido ya completado.';
    ELSEIF v_estado_actual = 'cancelado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar un pedido cancelado.';
    END IF;

    START TRANSACTION;
        UPDATE pedido SET estado = p_nuevo_estado WHERE pedido_id = p_pedido_id;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

DROP PROCEDURE IF EXISTS sp_completar_ingreso;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `sp_completar_ingreso`(
    IN p_ingreso_id INT
)
BEGIN
    DECLARE v_cantidad_lineas INT;
    DECLARE v_estado_ingreso VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT estado INTO v_estado_ingreso FROM ingreso_mercaderia WHERE ingreso_id = p_ingreso_id;
    IF v_estado_ingreso IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ingreso indicado no existe.';
    ELSEIF v_estado_ingreso <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este ingreso ya fue completado o cancelado.';
    END IF;

    SELECT COUNT(*) INTO v_cantidad_lineas
    FROM detalle_ingreso WHERE ingreso_id = p_ingreso_id;

    IF v_cantidad_lineas = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede completar un ingreso sin líneas de mercadería registradas.';
    END IF;

    START TRANSACTION;
        UPDATE ingreso_mercaderia SET estado = 'completado' WHERE ingreso_id = p_ingreso_id;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

DROP PROCEDURE IF EXISTS sp_registrar_ingreso;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `sp_registrar_ingreso`(
    IN  p_furgon_id      INT,
    IN  p_empleado_id    INT,
    IN  p_bodega_destino VARCHAR(60),
    OUT p_ingreso_id     INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        INSERT INTO ingreso_mercaderia (furgon_id, empleado_id, bodega_destino, estado)
        VALUES (p_furgon_id, p_empleado_id, p_bodega_destino, 'pendiente');

        SET p_ingreso_id = LAST_INSERT_ID();
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

-- 3) Vistas anteriores

DROP VIEW IF EXISTS vw_pedidos_resumen;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY DEFINER */
/*!50001 VIEW `vw_pedidos_resumen` AS select `pe`.`pedido_id` AS `pedido_id`,`cl`.`nombre_cliente` AS `nombre_cliente`,`tc`.`nombre` AS `tipo_cliente`,`emp`.`nombres_apellidos` AS `atendido_por`,`pe`.`fecha_pedido` AS `fecha_pedido`,`pe`.`estado` AS `estado`,`pe`.`total_pedido` AS `total_pedido`,count(`dp`.`variante_id`) AS `cantidad_lineas` from ((((`pedido` `pe` join `cliente` `cl` on((`cl`.`cliente_id` = `pe`.`cliente_id`))) join `tipo_cliente` `tc` on((`tc`.`tipo_cliente_id` = `cl`.`tipo_cliente_id`))) join `empleado` `emp` on((`emp`.`empleado_id` = `pe`.`empleado_id`))) left join `detalle_pedido` `dp` on((`dp`.`pedido_id` = `pe`.`pedido_id`))) group by `pe`.`pedido_id`,`cl`.`nombre_cliente`,`tc`.`nombre`,`emp`.`nombres_apellidos`,`pe`.`fecha_pedido`,`pe`.`estado`,`pe`.`total_pedido` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

DROP VIEW IF EXISTS vw_kardex_movimientos;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY DEFINER */
/*!50001 VIEW `vw_kardex_movimientos` AS select `ms`.`movimiento_id` AS `movimiento_id`,`vp`.`sku` AS `sku`,`p`.`modelo` AS `modelo`,`ms`.`tipo_movimiento` AS `tipo_movimiento`,`ms`.`cantidad` AS `cantidad`,`emp`.`nombres_apellidos` AS `registrado_por`,`ms`.`fecha_movimiento` AS `fecha_movimiento` from (((`movimiento_stock` `ms` join `variante_producto` `vp` on((`vp`.`variante_id` = `ms`.`variante_id`))) join `producto` `p` on((`p`.`producto_id` = `vp`.`producto_id`))) join `empleado` `emp` on((`emp`.`empleado_id` = `ms`.`empleado_id`))) order by `ms`.`fecha_movimiento` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

DROP VIEW IF EXISTS vw_stock_bajo_minimo;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY DEFINER */
/*!50001 VIEW `vw_stock_bajo_minimo` AS select `vp`.`variante_id` AS `variante_id`,`vp`.`sku` AS `sku`,`p`.`modelo` AS `modelo`,`cat`.`nombre_categoria` AS `nombre_categoria`,`t`.`valor_talla` AS `valor_talla`,`c`.`nombre_color` AS `nombre_color`,`vp`.`stock_actual` AS `stock_actual`,`vp`.`stock_minimo` AS `stock_minimo` from ((((`variante_producto` `vp` join `producto` `p` on((`p`.`producto_id` = `vp`.`producto_id`))) join `categoria` `cat` on((`cat`.`categoria_id` = `p`.`categoria_id`))) join `talla` `t` on((`t`.`talla_id` = `vp`.`talla_id`))) join `color` `c` on((`c`.`color_id` = `vp`.`color_id`))) where (`vp`.`stock_actual` <= `vp`.`stock_minimo`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

DROP VIEW IF EXISTS vw_ventas_por_categoria;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ventas_por_categoria` AS select `cat`.`nombre_categoria` AS `nombre_categoria`,sum(`dp`.`subtotal`) AS `total_vendido`,sum(`dp`.`cantidad`) AS `unidades_de_presentacion_vendidas` from ((((`detalle_pedido` `dp` join `variante_producto` `vp` on((`vp`.`variante_id` = `dp`.`variante_id`))) join `producto` `p` on((`p`.`producto_id` = `vp`.`producto_id`))) join `categoria` `cat` on((`cat`.`categoria_id` = `p`.`categoria_id`))) join `pedido` `pe` on((`pe`.`pedido_id` = `dp`.`pedido_id`))) where (`pe`.`estado` = 'completado') group by `cat`.`nombre_categoria` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

-- 4) Verificación rápida. Esperado: 19 | 9 | 2 | 9 | 3
SELECT
  (SELECT COUNT(*) FROM information_schema.tables   WHERE table_schema = 'railway' AND table_type = 'BASE TABLE') AS tablas,
  (SELECT COUNT(*) FROM information_schema.views    WHERE table_schema = 'railway')                                AS vistas,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_type = 'FUNCTION')  AS funciones,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'railway' AND routine_type = 'PROCEDURE') AS procedimientos,
  (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'railway')                              AS triggers;

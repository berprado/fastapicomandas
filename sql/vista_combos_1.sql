CREATE 
	DEFINER = 'root'@'localhost'
VIEW adminerp_copy.vw_combo_detalle_precios
AS
	SELECT
	        `det`.`id_combo_coctel`  AS `id_combo_coctel`,
	        `combo`.`nombre`         AS `nombre_combo`,
	        `pv`.`precio_venta`      AS `precio_venta`,
	        `pro`.`codigo`           AS `codigoProducto`,
	        `pro`.`nombre`           AS `nombreProdcuto`,
	        `pro`.`medida`           AS `medida`,
	        `pt1`.`nombre`           AS `contenidoProd`,
	        `pro`.`cantidad_detalle` AS `cantidad_detalle`,
	        `pt2`.`nombre`           AS `detalleProd`,
	        `det`.`cantidad`         AS `cantidad`,
	        (CASE
	                WHEN (`det`.`ind_paq_detalle` = '1')
	                  THEN
	                  'Unidad'
	                ELSE
	                'Detalle'
	        END)                     AS `requerido`,
	        `pt3`.`nombre`           AS `tipoRequerimiento`,
	        `pv`.`id_dia`            AS `id_dia`
	FROM
	        ((((((`bar_detalle_combo_bar` `det`
	    JOIN
	      `alm_producto` `pro`
	        ON ((`pro`.`id` = `det`.`id_producto`)))
	    JOIN
	      `bar_combo_coctel` `combo`
	        ON ((`combo`.`id` = `det`.`id_combo_coctel`)))
	    LEFT JOIN
	      `parameter_table` `pt1`
	        ON ((`pt1`.`id` = `pro`.`p_unidad_medida`)))
	    LEFT JOIN
	      `parameter_table` `pt2`
	        ON ((`pt2`.`id` = `pro`.`p_unidad_medida_detalle`)))
	    LEFT JOIN
	      `parameter_table` `pt3`
	        ON ((`pt3`.`id` = `det`.`ind_tipo_producto`)))
	    LEFT JOIN
	      `ope_precio_venta` `pv`
	        ON (((`pv`.`id_combo_coctel` = `det`.`id_combo_coctel`)
	            AND (`pv`.`estado` = 'HAB'))))
	WHERE
	        (       (`det`.`estado` = 'HAB')
	                AND (`combo`.`estado` = 'HAB'));
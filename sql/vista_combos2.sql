CREATE OR REPLACE VIEW adminerp_copy.vw_combo_detalle_precios AS
SELECT
    det.id_combo_coctel,
    combo.nombre AS nombre_combo,
    combo.descripcion AS descripcion_combo,  -- Aquí se incluye la descripción
    pv.precio_venta,
    pro.codigo AS codigoProducto,
    pro.nombre AS nombreProducto,
    pro.medida,
    pt1.nombre AS contenidoProd,
    pro.cantidad_detalle,
    pt2.nombre AS detalleProd,
    det.cantidad,
    (CASE WHEN det.ind_paq_detalle = '1' THEN 'Unidad' ELSE 'Detalle' END) AS requerido,
    pt3.nombre AS tipoRequerimiento,
    pv.id_dia,
    det.id_producto AS id_producto_ingrediente,
    prod_ingrediente.nombre AS nombre_producto_ingrediente
FROM
    bar_detalle_combo_bar det
    JOIN alm_producto pro ON pro.id = det.id_producto
    JOIN bar_combo_coctel combo ON combo.id = det.id_combo_coctel
    LEFT JOIN parameter_table pt1 ON pt1.id = pro.p_unidad_medida
    LEFT JOIN parameter_table pt2 ON pt2.id = pro.p_unidad_medida_detalle
    LEFT JOIN parameter_table pt3 ON pt3.id = det.ind_tipo_producto
    LEFT JOIN ope_precio_venta pv ON pv.id_combo_coctel = det.id_combo_coctel AND pv.estado = 'HAB'
    LEFT JOIN alm_producto prod_ingrediente ON prod_ingrediente.id = det.id_producto
WHERE
    det.estado = 'HAB'
    AND combo.estado = 'HAB';

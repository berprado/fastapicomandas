CREATE OR REPLACE VIEW adminerp_copy.vw_combo_detalle_precios AS
SELECT 
    det.id_combo_coctel,
    combo.nombre AS nombre_combo,
    SUBSTRING_INDEX(combo.descripcion, ' ', 1) AS unidad_venta,
    combo.descripcion AS descripcion_combo,
    cat.nombre AS nombre_categoria,
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
    det.estado AS estado_ingrediente,
    pv.id_dia,
    det.id_producto AS id_producto_ingrediente
FROM adminerp_copy.bar_detalle_combo_bar det
INNER JOIN adminerp_copy.alm_producto pro ON pro.id = det.id_producto
INNER JOIN adminerp_copy.bar_combo_coctel combo ON combo.id = det.id_combo_coctel
LEFT JOIN adminerp_copy.alm_categoria cat ON cat.id = combo.id_categoria
LEFT JOIN adminerp_copy.parameter_table pt1 ON pt1.id = pro.p_unidad_medida
LEFT JOIN adminerp_copy.parameter_table pt2 ON pt2.id = pro.p_unidad_medida_detalle
LEFT JOIN adminerp_copy.parameter_table pt3 ON pt3.id = det.ind_tipo_producto
LEFT JOIN adminerp_copy.ope_precio_venta pv ON pv.id_combo_coctel = det.id_combo_coctel AND pv.estado = 'HAB'
WHERE combo.estado = 'HAB';
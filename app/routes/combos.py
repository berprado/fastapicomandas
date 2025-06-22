import os
from dotenv import load_dotenv
from fastapi import APIRouter, Query, HTTPException
from typing import List, Optional
from app.database import get_connection


load_dotenv()
router = APIRouter()

@router.get("/combos/", summary="Combos con ingredientes, precios por día y categoría")
def get_combos(
    ids: Optional[List[int]] = Query(None, description="IDs de combos separados por coma"),
    id_dia: Optional[int] = Query(None, description="ID del día para filtrar precios"),
    categoria: Optional[str] = Query(None, description="Nombre de la categoría")
):
    conn = None
    rows = []
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            sql = "SELECT * FROM vw_combo_detalle_precios"
            params = []
            filters = []

            if ids:
                placeholders = ",".join(["%s"] * len(ids))
                filters.append(f"id_combo_coctel IN ({placeholders})")
                params.extend(ids)

            if id_dia:
                filters.append("id_dia = %s")
                params.append(id_dia)

            if categoria:
                filters.append("nombre_categoria = %s")
                params.append(categoria)

            if filters:
                sql += " WHERE " + " AND ".join(filters)

            sql += " ORDER BY id_combo_coctel, id_dia"
            cursor.execute(sql, params)
            rows = cursor.fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener los combos: {str(e)}")
    finally:
        if conn:
            conn.close()

    if not rows:
        return {"message": "No se encontraron resultados."}

    combos = {}
    for row in rows:
        combo_id = row["id_combo_coctel"]
        if combo_id not in combos:
            combos[combo_id] = {
                "id_combo_coctel": combo_id,
                "nombre_combo": row.get("nombre_combo", ""),
                "nombre_categoria": row.get("nombre_categoria", ""),
                "unidad_venta": row.get("unidad_venta", "").lower() if row.get("unidad_venta") else "",
                "descripcion_combo": row.get("descripcion_combo", ""),
                "precios": [],
                "ingredientes": []
            }
        ingrediente = {
            "codigoProducto": row.get("codigoProducto", ""),
            "nombreProducto": row.get("nombreProducto", ""),
            "medida": row.get("medida", ""),
            "contenidoProd": row.get("contenidoProd", "").lower() if row.get("contenidoProd") else "",
            "cantidad_detalle": row.get("cantidad_detalle", 0),
            "detalleProd": row.get("detalleProd", "").lower() if row.get("detalleProd") else "",
            "cantidad": row.get("cantidad", 0),
            "requerido": row.get("requerido", "").lower() if row.get("requerido") else "",
            "tipoRequerimiento": row.get("tipoRequerimiento", "").lower() if row.get("tipoRequerimiento") else ""
        }
        if ingrediente not in combos[combo_id]["ingredientes"]:
            combos[combo_id]["ingredientes"].append(ingrediente)
        precio_entry = {"id_dia": row.get("id_dia", 0), "precio_venta": row.get("precio_venta", 0)}
        if precio_entry not in combos[combo_id]["precios"]:
            combos[combo_id]["precios"].append(precio_entry)

    return list(combos.values())

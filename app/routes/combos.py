import os
from dotenv import load_dotenv
from fastapi import APIRouter, Query, HTTPException, Depends, Request, Path
from typing import List, Optional
from app.database import get_connection
from app.auth import get_current_user
from app.bitacora import registrar_bitacora
from app.models import ComboProductoUpdate


load_dotenv()
router = APIRouter()

@router.get("/combos/", summary="Combos con ingredientes, precios por día y categoría")
def get_combos(
    ids: Optional[List[int]] = Query(None, description="IDs de combos separados por coma"),
    id_dia: Optional[int] = Query(None, description="ID del día para filtrar precios"),
    categoria: Optional[str] = Query(None, description="Nombre de la categoría"),
    usuario: dict = Depends(get_current_user)
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
            "tipoRequerimiento": row.get("tipoRequerimiento", "").lower() if row.get("tipoRequerimiento") else "",
            "estado_ingrediente": row.get("estado_ingrediente", "").upper() if row.get("estado_ingrediente") else ""
        }
        if ingrediente not in combos[combo_id]["ingredientes"]:
            combos[combo_id]["ingredientes"].append(ingrediente)
        precio_entry = {"id_dia": row.get("id_dia", 0), "precio_venta": row.get("precio_venta", 0)}
        if precio_entry not in combos[combo_id]["precios"]:
            combos[combo_id]["precios"].append(precio_entry)

    return list(combos.values())

@router.put("/combos/{combo_id}", summary="Actualizar nombre y descripción de un combo")
def actualizar_combo(
    combo_id: int = Path(..., description="ID del combo a actualizar"),
    combo: ComboProductoUpdate = ...,
    request: Request = ...,
    usuario=Depends(get_current_user)
):
    if not combo.nombre and not combo.descripcion:
        raise HTTPException(status_code=400, detail="Debe enviar al menos un campo para actualizar")

    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # Consulta el combo actual
            cursor.execute("SELECT * FROM bar_combo_coctel WHERE id = %s", (combo_id,))
            combo_actual = cursor.fetchone()
            if not combo_actual:
                raise HTTPException(status_code=404, detail="Combo no encontrado")

            # Prepara solo los campos que se actualizarán
            campos = []
            valores = []
            if combo.nombre:
                campos.append("nombre = %s")
                valores.append(combo.nombre)
            if combo.descripcion:
                campos.append("descripcion = %s")
                valores.append(combo.descripcion)
            # Siempre actualiza fecha_mod
            campos.append("fecha_mod = NOW()")

            sql = f"UPDATE bar_combo_coctel SET {', '.join(campos)} WHERE id = %s"
            valores.append(combo_id)
            cursor.execute(sql, valores)
            conn.commit()

            # Bitácora con los cambios
            registrar_bitacora(
                usuario=usuario["sub"],
                accion="UPDATE",
                tabla="bar_combo_coctel",
                registro_id=combo_id,
                descripcion=(
                    f"Actualizó combo. Antes: nombre='{combo_actual['nombre']}', descripcion='{combo_actual['descripcion']}'. "
                    f"Después: nombre='{combo.nombre or combo_actual['nombre']}', descripcion='{combo.descripcion or combo_actual['descripcion']}'"
                ),
                ip=request.client.host
            )
        return {"message": "Combo actualizado exitosamente"}
    finally:
        conn.close()
# app/bitacora.py

from app.database import get_connection

def registrar_bitacora(usuario, accion, tabla, registro_id, descripcion, ip):
    """
    Registra una acción de usuario en la tabla seg_bitacora.

    Args:
        usuario (str): nombre de usuario (de JWT, por ejemplo).
        accion (str): acción realizada (ej: 'CREATE', 'UPDATE', 'DELETE').
        tabla (str): nombre de la tabla afectada.
        registro_id (int): ID del registro afectado.
        descripcion (str): descripción de la acción.
        ip (str): dirección IP del cliente.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "INSERT INTO seg_bitacora (usuario, accion, tabla, registro_id, descripcion, ip) "
                "VALUES (%s, %s, %s, %s, %s, %s)",
                (usuario, accion, tabla, registro_id, descripcion, ip)
            )
            conn.commit()
    finally:
        conn.close()

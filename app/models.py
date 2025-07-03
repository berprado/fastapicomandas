# app/models.py
from pydantic import BaseModel
from typing import Optional

class ComboProductoUpdate(BaseModel):
    nombre: Optional[str]
    descripcion: Optional[str]

import os
from dotenv import load_dotenv
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from app.auth import verify_user, create_access_token

load_dotenv()
router = APIRouter()

@router.post("/login/", summary="Iniciar sesión y obtener token de acceso")
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = verify_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="Credenciales incorrectas"
        )
    token_data = {
        "sub": user["usuario"],
        "id": user["id"],
        "nombre": user["nombres"],
        "rol": user["p_cargo"]
    }
    access_token = create_access_token(token_data)
    return {"access_token": access_token, "token_type": "bearer"}


from fastapi import HTTPException, status, Depends
from jose import jwt, JWTError
from datetime import datetime, timedelta
import os
from app.database import get_connection
from fastapi.security import OAuth2PasswordBearer
import hashlib
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET", "SUPERSECRETA")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def verify_user(username: str, password: str):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM seg_usuario WHERE usuario = %s AND habilitado = 1 AND estado = 'HAB'",
                (username,))

            user = cursor.fetchone()
            # Calcula el hash SHA-256 de la contraseña ingresada
            hashed_input = hashlib.sha256(password.encode('utf-8')).hexdigest()
            if not user or user["contrasena"] != hashed_input:
                return None
            return user
    finally:
        conn.close()

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No autenticado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        return payload
    except JWTError:
        raise credentials_exception

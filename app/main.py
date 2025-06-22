import os
from fastapi import FastAPI
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

app = FastAPI(title="API Combos Bar - Backstage", version="2.0")

# Monta el router
from app.routes.combos import router as combos_router
app.include_router(combos_router)

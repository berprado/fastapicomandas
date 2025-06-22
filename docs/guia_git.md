
---

# 🚀 **Guía paso a paso: API FastAPI profesional con VSCode, entorno virtual, Git y GitHub**

---

## 1. **Pre-requisitos**

* Python 3.12 instalado (verifica con `python --version`)
* MySQL funcionando (tienes 5.6.12, ¡perfecto!)
* Visual Studio Code instalado
* Git instalado (puedes instalarlo desde [git-scm.com](https://git-scm.com/))
* Cuenta en [GitHub](https://github.com/)

---

## 2. **Crea una carpeta para tu proyecto**

En la terminal de VSCode (puedes usar PowerShell):

```powershell
cd C:\ruta\donde\quieres\el\proyecto
mkdir combos_api
cd combos_api
```

---

## 3. **Crea el entorno virtual**

Esto aísla las dependencias solo para este proyecto.

```powershell
python -m venv venv
```

* En **Windows**, activa el entorno así:

```powershell
.\venv\Scripts\activate
```

Verás que el prompt cambia, debería aparecer `(venv)` al principio.

---

## 4. **Crea archivos base del proyecto**

```powershell
echo > main.py
echo > .env
echo > .gitignore
echo > requirements.txt
```

O desde el explorador de VSCode, botón derecho “Nuevo archivo”.

---

## 5. **Crea tu .gitignore**

Esto es FUNDAMENTAL para no subir cosas innecesarias a GitHub.
Agrega este contenido a `.gitignore`:

```
# Entorno virtual
venv/
# Archivos de configuración de entorno
.env
# __pycache__ y archivos temporales de Python
__pycache__/
*.pyc
# Archivos de configuración de VSCode (opcional)
.vscode/
```

---

## 6. **Inicializa el repositorio Git**

```powershell
git init
git add .
git commit -m "Initial commit: estructura base del proyecto FastAPI"
```

---

## 7. **Crea el repositorio en GitHub**

* Ve a [GitHub](https://github.com/), inicia sesión.
* Haz clic en **New repository**.
* Elige nombre (por ejemplo, `combos_api`), público o privado.
* **No** inicialices con README (ya tienes tu proyecto local).

---

## 8. **Vincula tu carpeta local con GitHub**

GitHub te da las instrucciones, normalmente es algo así (ajusta el nombre del repo y tu usuario):

```powershell
git remote add origin https://github.com/TU_USUARIO/combos_api.git
git branch -M main
git push -u origin main
```

---

## 9. **Instala las dependencias principales**

En el entorno virtual:

```powershell
pip install fastapi uvicorn pymysql python-dotenv
```

Guarda tus dependencias:

```powershell
pip freeze > requirements.txt
```

---

## 10. **Estructura básica de tu proyecto**

Quedará algo así:

```
combos_api/
│
├── main.py
├── requirements.txt
├── .env
├── .gitignore
├── venv/
└── __pycache__/
```

---

## 11. **Agrega y sube tus cambios frecuentemente**

Cada vez que avances:

```powershell
git add .
git commit -m "Mensaje explicativo de lo que cambiaste"
git push
```

---

## 12. **Siguiente paso: Código base FastAPI**

(¡Ya lo tienes más arriba!
Cuando lo tengas listo en `main.py`, vuelve a hacer `git add .`, `commit` y `push`).

---

## 13. **¿Cómo ejecutar la API?**

Siempre asegúrate de estar en el entorno virtual:

```powershell
.\venv\Scripts\activate
uvicorn main:app --reload
```

---

## 14. **Notas importantes**

* Usa **.env** para tus contraseñas y cosas privadas, ¡nunca las subas a GitHub!
* El **.gitignore** te protege, pero mejor revisa antes de cada push con `git status`.
* Haz commits pequeños y explicativos.

---

## 15. **Resumen “Cheat Sheet”**

```powershell
# Crear y activar entorno virtual
python -m venv venv
.\venv\Scripts\activate

# Instalar dependencias
pip install fastapi uvicorn pymysql python-dotenv
pip freeze > requirements.txt

# Inicializar git y primer commit
git init
git add .
git commit -m "Initial commit"
# (luego de crear el repo en GitHub)
git remote add origin https://github.com/TU_USUARIO/combos_api.git
git branch -M main
git push -u origin main

# Ejecutar la app
uvicorn main:app --reload
```

---

¿Quieres que te arme un **README.md profesional** para tu proyecto?
¿O te gustaría el ejemplo del **main.py** listo para copiar y pegar?

¡Avísame y te lo dejo como para presumirlo en LinkedIn! 🚀

---

# ✅ **Checklist de Organización de Ramas y PRs (Pull Requests)**

## **1. Nombra tus ramas con claridad**

* Usa nombres que reflejen la funcionalidad o fase.
* Ejemplos:

  * `feature/crud-endpoints`
  * `feature/fase2-crud`
  * `bugfix/fix-endpoint-error`
  * `refactor/api-structure`

---

## **2. Antes de crear una rama nueva**

* **Actualiza tu rama principal (`main` o `master`):**

  ```bash
  git checkout main
  git pull origin main
  ```
* **Crea tu rama basada en la principal:**

  ```bash
  git checkout -b feature/crud-endpoints
  ```

---

## **3. Trabaja y haz commits frecuentemente**

* Haz commits claros y pequeños. Ejemplo:

  ```bash
  git add .
  git commit -m "Agrega endpoint POST para crear combos"
  ```

---

## **4. Sincroniza cambios frecuentemente**

* Si otras personas trabajan contigo, haz regularmente:

  ```bash
  git pull origin main
  ```

  …y resuelve cualquier conflicto.

---

## **5. Sube tu rama al repositorio remoto**

```bash
git push -u origin feature/crud-endpoints
```

---

## **6. Crea un Pull Request (PR)**

* En GitHub, ve a la pestaña “Pull Requests” y crea un nuevo PR.
* Selecciona tu rama (`feature/crud-endpoints`) para comparar contra `main`.
* Escribe una **descripción clara** del cambio. Ejemplo:

  > “Implementa endpoints CRUD para combos, incluyendo validaciones y manejo de errores.”

---

## **7. Revisión y pruebas**

* Revisa el PR tú mismo o pídele feedback a un colega.
* Haz pruebas manuales o usa tests automáticos si tienes.
* Ajusta el PR si es necesario con nuevos commits (se agregan automáticamente al PR).

---

## **8. Merge a main cuando esté aprobado**

* Una vez revisado y aprobado, haz el merge desde GitHub.
* Opcional: elimina la rama desde GitHub para mantener el repo limpio.

---

## **9. Actualiza tu main localmente**

```bash
git checkout main
git pull origin main
```

---

## **10. Comienza la siguiente feature desde main**

* Así mantienes tu historial de cambios ordenado y tu proyecto siempre listo para producción.

---

### **Extra**

* Si tienes varias features, trabaja cada una en su propia rama.
* ¿Muchos cambios? Agrúpalos en ramas de tipo `release` o `hotfix`.

---

## **Plantilla para Pull Requests**

Puedes incluir esto en cada PR:

```markdown
### ¿Qué se hizo?
- [x] Endpoint POST para combos
- [x] Validación de datos de entrada
- [ ] Test unitarios para creación de combos

### ¿Cómo probar?
1. Enviar un POST a /combos/ con datos válidos.
2. Verificar respuesta 201 y que se almacene en la base de datos.
```

---
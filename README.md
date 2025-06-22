
# API Combos Bar - Backstage

API REST para la gestión de combos y cócteles del bar Backstage, desarrollada con FastAPI y MySQL.  
Permite consultar información detallada de combos, incluyendo ingredientes, precios por día, categoría, unidad de venta y descripción.

---

## 🚀 Características principales

- Consulta de combos/cócteles con sus ingredientes.
- Visualización de precios de venta por día.
- Filtrado por categoría, día o por combos específicos.
- Exposición de unidad de venta y descripción del combo.
- Listo para ser consumido por frontends modernos, apps móviles, sistemas POS y más.

---

## 📦 Estructura de respuesta

```json
[
  {
    "id_combo_coctel": 1,
    "nombre_combo": "Gin Tonic Premium",
    "nombre_categoria": "GIN",
    "unidad_venta": "VASO",
    "descripcion_combo": "VASO Gin, tónica y pepino",
    "precios": [
      { "id_dia": 1, "precio_venta": 45.0 },
      { "id_dia": 6, "precio_venta": 55.0 }
    ],
    "ingredientes": [
      {
        "codigoProducto": "641",
        "nombreProdcuto": "DON LUCHO SILVER 750ML",
        "medida": 750,
        "contenidoProd": "ml",
        "cantidad_detalle": 25,
        "detalleProd": "Oz",
        "cantidad": 1.5,
        "requerido": "Detalle",
        "tipoRequerimiento": "PRINCIPAL"
      }
      // ...otros ingredientes
    ]
  }
  // ...otros combos
]
````

---

## 🔗 Endpoints

### `GET /combos/`

Consulta combos y sus ingredientes, con precios por día y filtros opcionales.

#### **Parámetros opcionales:**

| Nombre    | Tipo       | Descripción                                                         |
| --------- | ---------- | ------------------------------------------------------------------- |
| ids       | List\[int] | IDs de combos a consultar (puedes pasar varios, ej: `?ids=1&ids=2`) |
| id\_dia   | int        | ID del día para filtrar precios                                     |
| categoria | str        | Nombre exacto de la categoría (ej: `GIN`)                           |

#### **Ejemplos de uso:**

* **Todos los combos:**

  ```
  GET /combos/
  ```

* **Filtrar por día:**

  ```
  GET /combos/?id_dia=3
  ```

* **Filtrar por categoría:**

  ```
  GET /combos/?categoria=GIN
  ```

* **Por combo, día y categoría:**

  ```
  GET /combos/?ids=1&ids=2&id_dia=3&categoria=GIN
  ```

---

## ⚙️ Requisitos de entorno

* Python 3.12
* FastAPI
* PyMySQL
* dotenv

### **Variables de entorno necesarias (.env):**

```env
MYSQL_HOST=localhost
MYSQL_USER=usuario_mysql
MYSQL_PASSWORD=clave_mysql
MYSQL_DB=adminerp_copy
MYSQL_PORT=3306
```

---

## 🛠️ Ejecución local

1. Instala dependencias:

   ```
   pip install -r requirements.txt
   ```

2. Ejecuta el servidor (modo desarrollo):

   ```
   uvicorn main:app --reload
   ```

3. Accede a la documentación interactiva:

   ```
   http://localhost:8000/docs
   ```

---

## 📝 Notas adicionales

* El campo `unidad_venta` es la **primera palabra de la descripción del combo** (ej: "VASO", "COPA", "JARRA").
* Los precios de combos pueden variar por día según programación interna del bar.
* El endpoint está optimizado para retornar información agrupada, evitando duplicados.


---

## 🙌 Autoría y soporte

Desarrollado y documentado por el team Backstage & ChatGPT.<br>
Para sugerencias, mejoras o problemas:
Crear un issue en el repositorio.

---

¡Salud y buen código! 🍸

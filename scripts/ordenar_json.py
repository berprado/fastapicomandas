import json
from collections import defaultdict

# Leer el archivo original
with open("combos.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# Agrupar por id_combo_coctel
combos = defaultdict(list)
for item in data:
    combo_id = item["id_combo_coctel"]
    combos[combo_id].append(item)

# Preparar la estructura final
resultado = []
for combo_id, ingredientes in combos.items():
    combo = {
        "id_combo_coctel": combo_id,
        "ingredientes": ingredientes
    }
    resultado.append(combo)

# Guardar el resultado en un nuevo archivo JSON
with open("combos_agrupados.json", "w", encoding="utf-8") as f:
    json.dump(resultado, f, indent=2, ensure_ascii=False)

print("Archivo 'combos_agrupados.json' creado exitosamente.")

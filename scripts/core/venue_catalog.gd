class_name VenueCatalog
extends RefCounted

# Escenarios del juego (taberna, armería...) leídos de data/venues.json.
# Cada uno tiene su "gameplay" (qué subclase de Level se juega) y sus niveles.

const PATH := "res://data/venues.json"
const DEFAULT_VENUE := {
	"id": "taberna", "name": "Taberna", "goal": "", "gameplay": "tavern",
	"icon": "mug", "roof": "R", "map_pos": [320, 200], "requires": "",
	"levels": [{
		"name": "Nivel de prueba", "time": 60, "tables": 3,
		"spawn_interval": 6, "queue_patience": 25, "table_patience": 20,
		"stars": [20, 40, 60],
	}],
}


static func load_all() -> Array:
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file != null:
		var data = JSON.parse_string(file.get_as_text())
		if data is Array and not data.is_empty():
			return data
	push_error("No se pudo leer %s, usando escenario por defecto" % PATH)
	return [DEFAULT_VENUE]


# Un escenario está disponible si no pide nada o si el que pide está completo.
static func is_unlocked(venues: Array, index: int, save: SaveData) -> bool:
	var requires := str(venues[index].get("requires", ""))
	if requires == "":
		return true
	for v in venues:
		if v["id"] == requires:
			return save.is_venue_complete(requires, v["levels"].size())
	return false

class_name VenueCatalog
extends RefCounted

# Escenarios del juego (taberna, armería...) leídos de data/venues.json.
# Cada uno tiene su "gameplay" (qué subclase de Level se juega) y sus niveles.
# Se desbloquean en orden: cada escenario pide un 75% de todas las estrellas
# de los anteriores.

const PATH := "res://data/venues.json"
# Parte de las estrellas de los escenarios anteriores que hace falta para abrir uno.
const UNLOCK_RATIO := 0.75
const STARS_PER_LEVEL := 3
const DEFAULT_VENUE := {
	"id": "taberna", "name": "Taberna", "goal": "", "gameplay": "tavern",
	"icon": "mug", "roof": "R", "map_pos": [320, 200],
	"levels": [{
		"name": "Nivel de prueba", "time": 60, "tables": 3,
		"queue_patience": 25, "table_patience": 20,
		"customers": [{"at": 1}, {"at": 8}, {"at": 15}, {"at": 22}],
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


# Estrellas máximas de los escenarios [from, to).
static func max_stars(venues: Array, from: int, to: int) -> int:
	var total := 0
	for i in range(from, to):
		total += venues[i]["levels"].size() * STARS_PER_LEVEL
	return total


# Estrellas conseguidas en los escenarios [from, to).
static func earned_stars(venues: Array, from: int, to: int, save: SaveData) -> int:
	var total := 0
	for i in range(from, to):
		total += save.total_stars(str(venues[i]["id"]))
	return total


# Estrellas necesarias para abrir el escenario "index".
static func stars_needed(venues: Array, index: int) -> int:
	return ceili(max_stars(venues, 0, index) * UNLOCK_RATIO)


static func is_unlocked(venues: Array, index: int, save: SaveData) -> bool:
	return earned_stars(venues, 0, index, save) >= stars_needed(venues, index)

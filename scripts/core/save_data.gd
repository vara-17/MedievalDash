class_name SaveData
extends RefCounted

# Progreso local. Hay un archivo de invitado y otro por cada cuenta de Google.
# El de cada cuenta es la copia local de lo que se sincroniza con Firestore.
# Formato: {"venues": {"taberna": [estrellas del nivel 1, 2, ...], ...}}

const GUEST_PATH := "user://save.json"
const ACCOUNT_PATH := "user://save_%s.json"
# Los guardados antiguos ({"stars": [...]}) eran solo de la taberna.
const LEGACY_VENUE := "taberna"

var path: String = GUEST_PATH
# Mejores estrellas de cada nivel, por id de escenario.
var progress: Dictionary = {}


static func for_account(uid: String) -> SaveData:
	var s := SaveData.new()
	s.path = ACCOUNT_PATH % uid
	return s


func load_from_disk() -> void:
	progress = {}
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if not data is Dictionary:
		return
	if data.get("venues") is Dictionary:
		for venue in data["venues"]:
			progress[venue] = _to_ints(data["venues"][venue])
	if data.get("stars") is Array:
		progress = merge_progress(progress, {LEGACY_VENUE: _to_ints(data["stars"])})


func save_to_disk() -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar el progreso")
		return
	file.store_string(JSON.stringify({"venues": progress}))


func delete_from_disk() -> void:
	progress = {}
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func has_progress() -> bool:
	for venue in progress:
		for v in progress[venue]:
			if int(v) > 0:
				return true
	return false


func get_stars(venue: String, index: int) -> int:
	var stars: Array = progress.get(venue, [])
	if index < stars.size():
		return int(stars[index])
	return 0


# Suma de las mejores estrellas de todos los niveles de un escenario.
func total_stars(venue: String) -> int:
	var total := 0
	for v in progress.get(venue, []):
		total += int(v)
	return total


func record(venue: String, index: int, stars: int) -> void:
	var list: Array = progress.get(venue, [])
	while list.size() <= index:
		list.append(0)
	progress[venue] = list
	if stars > int(list[index]):
		list[index] = stars
		save_to_disk()


# Se queda con el máximo de estrellas de cada nivel entre lo local y "other".
func merge(other: Dictionary) -> void:
	progress = merge_progress(progress, other)
	save_to_disk()


static func merge_progress(a: Dictionary, b: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for venue in a:
		result[venue] = merge_stars(a[venue], b.get(venue, []))
	for venue in b:
		if not result.has(venue):
			result[venue] = merge_stars([], b[venue])
	return result


static func merge_stars(a: Array, b: Array) -> Array:
	var result: Array = []
	for i in maxi(a.size(), b.size()):
		var x := int(a[i]) if i < a.size() else 0
		var y := int(b[i]) if i < b.size() else 0
		result.append(maxi(x, y))
	return result


static func _to_ints(values: Array) -> Array:
	var result: Array = []
	for v in values:
		result.append(int(v))
	return result


func is_unlocked(venue: String, index: int) -> bool:
	return index == 0 or get_stars(venue, index - 1) > 0

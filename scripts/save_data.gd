class_name SaveData
extends RefCounted

# Progreso local. Hay un archivo de invitado y otro por cada cuenta de Google.
# El de cada cuenta es la copia local de lo que se sincroniza con Firestore.

const GUEST_PATH := "user://save.json"
const ACCOUNT_PATH := "user://save_%s.json"

var path: String = GUEST_PATH
var best_stars: Array = []


static func for_account(uid: String) -> SaveData:
	var s := SaveData.new()
	s.path = ACCOUNT_PATH % uid
	return s


func load_from_disk() -> void:
	best_stars = []
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary and data.get("stars") is Array:
		for v in data["stars"]:
			best_stars.append(int(v))


func save_to_disk() -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar el progreso")
		return
	file.store_string(JSON.stringify({"stars": best_stars}))


func delete_from_disk() -> void:
	best_stars = []
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func has_progress() -> bool:
	for v in best_stars:
		if int(v) > 0:
			return true
	return false


func get_stars(index: int) -> int:
	if index < best_stars.size():
		return int(best_stars[index])
	return 0


func record(index: int, stars: int) -> void:
	while best_stars.size() <= index:
		best_stars.append(0)
	if stars > int(best_stars[index]):
		best_stars[index] = stars
		save_to_disk()


# Se queda con el máximo de estrellas de cada nivel entre lo local y "other".
func merge(other: Array) -> void:
	best_stars = merge_stars(best_stars, other)
	save_to_disk()


static func merge_stars(a: Array, b: Array) -> Array:
	var result: Array = []
	for i in maxi(a.size(), b.size()):
		var x := int(a[i]) if i < a.size() else 0
		var y := int(b[i]) if i < b.size() else 0
		result.append(maxi(x, y))
	return result


func is_unlocked(index: int) -> bool:
	return index == 0 or get_stars(index - 1) > 0

class_name SaveData
extends RefCounted

const PATH := "user://save.json"

var best_stars: Array = []


func load_from_disk() -> void:
	best_stars = []
	if not FileAccess.file_exists(PATH):
		return
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary and data.get("stars") is Array:
		for v in data["stars"]:
			best_stars.append(int(v))


func save_to_disk() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar el progreso")
		return
	file.store_string(JSON.stringify({"stars": best_stars}))


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


func is_unlocked(index: int) -> bool:
	return index == 0 or get_stars(index - 1) > 0

class_name FirebaseConfig
extends RefCounted

# Lee data/firebase.json (no está en git; plantilla en data/firebase.example.json).

const PATH := "res://data/firebase.json"

static var _data: Dictionary = {}


static func get_value(key: String) -> String:
	if _data.is_empty():
		var file := FileAccess.open(PATH, FileAccess.READ)
		if file == null:
			push_warning("No existe %s; copia data/firebase.example.json y rellénalo" % PATH)
			return ""
		var data = JSON.parse_string(file.get_as_text())
		if data is Dictionary:
			_data = data
	return str(_data.get(key, ""))

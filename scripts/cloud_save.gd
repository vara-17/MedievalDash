class_name CloudSave
extends Node

# Sincroniza el progreso con Firestore (documento users/{uid}) usando la API REST.
# Se queda con el máximo de estrellas de cada nivel entre lo local y la nube,
# así que da igual en qué orden se sincronicen varios dispositivos.
# El progreso va en el campo "venues" (mapa escenario -> estrellas). El campo
# antiguo "stars" (solo taberna) se lee pero no se toca.

signal synced(uid: String, progress: Dictionary)
signal sync_failed(message: String)

const DOC_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/users/%s"
# Solo se escriben estos campos; el resto del documento se conserva.
const UPDATE_MASK := "?updateMask.fieldPaths=venues&updateMask.fieldPaths=updated_at"


func sync(uid: String, id_token: String, local: Dictionary) -> void:
	var project_id := FirebaseConfig.get_value("project_id")
	if project_id == "":
		sync_failed.emit("Falta project_id en %s" % FirebaseConfig.PATH)
		return
	var url := DOC_URL % [project_id, uid]
	var headers := PackedStringArray(["Authorization: Bearer " + id_token])
	var res := await HttpJson.request(self, url, HTTPClient.METHOD_GET, headers)
	var remote: Dictionary = {}
	var remote_venues: Dictionary = {}
	if res["code"] == 200:
		remote_venues = _read_venues(res["data"])
		remote = SaveData.merge_progress(remote_venues, _read_legacy(res["data"]))
	elif res["code"] != 404:
		sync_failed.emit(HttpJson.error_message(res))
		return
	var merged := SaveData.merge_progress(local, remote)
	if merged != remote_venues:
		headers.append("Content-Type: application/json")
		res = await HttpJson.request(self, url + UPDATE_MASK, HTTPClient.METHOD_PATCH, headers, JSON.stringify(_to_document(merged)))
		if res["code"] != 200:
			sync_failed.emit(HttpJson.error_message(res))
			return
	synced.emit(uid, merged)


func _read_venues(doc: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var fields = doc.get("fields", {}).get("venues", {}).get("mapValue", {}).get("fields", {})
	for venue in fields:
		result[venue] = _read_array(fields[venue])
	return result


func _read_legacy(doc: Dictionary) -> Dictionary:
	var field = doc.get("fields", {}).get("stars")
	if field == null:
		return {}
	return {SaveData.LEGACY_VENUE: _read_array(field)}


func _read_array(field: Dictionary) -> Array:
	var stars: Array = []
	for v in field.get("arrayValue", {}).get("values", []):
		stars.append(int(v.get("integerValue", "0")))
	return stars


func _to_document(progress: Dictionary) -> Dictionary:
	var venues: Dictionary = {}
	for venue in progress:
		var values: Array = []
		for s in progress[venue]:
			values.append({"integerValue": str(s)})
		venues[venue] = {"arrayValue": {"values": values}}
	return {"fields": {
		"venues": {"mapValue": {"fields": venues}},
		"updated_at": {"timestampValue": Time.get_datetime_string_from_system(true) + "Z"},
	}}

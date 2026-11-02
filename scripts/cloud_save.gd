class_name CloudSave
extends Node

# Sincroniza el progreso con Firestore (documento users/{uid}) usando la API REST.
# Se queda con el máximo de estrellas de cada nivel entre lo local y la nube,
# así que da igual en qué orden se sincronicen varios dispositivos.

signal synced(uid: String, stars: Array)
signal sync_failed(message: String)

const DOC_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/users/%s"


func sync(uid: String, id_token: String, local_stars: Array) -> void:
	var project_id := FirebaseConfig.get_value("project_id")
	if project_id == "":
		sync_failed.emit("Falta project_id en %s" % FirebaseConfig.PATH)
		return
	var url := DOC_URL % [project_id, uid]
	var headers := PackedStringArray(["Authorization: Bearer " + id_token])
	var res := await HttpJson.request(self, url, HTTPClient.METHOD_GET, headers)
	var remote: Array = []
	if res["code"] == 200:
		remote = _read_stars(res["data"])
	elif res["code"] != 404:
		sync_failed.emit(HttpJson.error_message(res))
		return
	var merged := SaveData.merge_stars(local_stars, remote)
	if merged != remote:
		headers.append("Content-Type: application/json")
		res = await HttpJson.request(self, url, HTTPClient.METHOD_PATCH, headers, JSON.stringify(_to_document(merged)))
		if res["code"] != 200:
			sync_failed.emit(HttpJson.error_message(res))
			return
	synced.emit(uid, merged)


func _read_stars(doc: Dictionary) -> Array:
	var stars: Array = []
	var values = doc.get("fields", {}).get("stars", {}).get("arrayValue", {}).get("values", [])
	for v in values:
		stars.append(int(v.get("integerValue", "0")))
	return stars


func _to_document(stars: Array) -> Dictionary:
	var values: Array = []
	for s in stars:
		values.append({"integerValue": str(s)})
	return {"fields": {
		"stars": {"arrayValue": {"values": values}},
		"updated_at": {"timestampValue": Time.get_datetime_string_from_system(true) + "Z"},
	}}

class_name HttpJson
extends RefCounted

# Peticiones HTTP que devuelven JSON, para las APIs REST de Firebase.


# Devuelve {"code": código HTTP (0 si no hubo conexión), "data": respuesta JSON}.
# "parent" es el nodo al que se cuelga temporalmente el HTTPRequest.
static func request(parent: Node, url: String, method: HTTPClient.Method, headers: PackedStringArray = [], body: String = "") -> Dictionary:
	var http := HTTPRequest.new()
	parent.add_child(http)
	var err := http.request(url, headers, method, body)
	if err != OK:
		http.queue_free()
		return {"code": 0, "data": {}}
	var result: Array = await http.request_completed
	http.queue_free()
	var data = JSON.parse_string((result[3] as PackedByteArray).get_string_from_utf8())
	return {"code": int(result[1]), "data": data if data is Dictionary else {}}


static func error_message(res: Dictionary) -> String:
	if res["code"] == 0:
		return "Sin conexión"
	var error = res["data"].get("error", {})
	if error is Dictionary and error.has("message"):
		return str(error["message"])
	return "Error %d" % res["code"]

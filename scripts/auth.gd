class_name Auth
extends Node

# Inicio de sesión con Google + Firebase Auth (API REST).
# En Android, el plugin GoogleSignIn devuelve un ID token de Google; aquí se canjea
# por una sesión de Firebase. La sesión (refresh token) se guarda en SESSION_PATH
# para entrar automáticamente al abrir el juego.

signal signed_in(display_name: String)
signal signed_out
signal sign_in_failed(message: String)

const CONFIG_PATH := "res://data/firebase.json"
const SESSION_PATH := "user://auth.json"
const PLUGIN_NAME := "GoogleSignIn"
const SIGN_IN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=%s"
const REFRESH_URL := "https://securetoken.googleapis.com/v1/token?key=%s"

var api_key: String = ""
var web_client_id: String = ""
var uid: String = ""
var email: String = ""
var display_name: String = ""
var refresh_token: String = ""
var id_token: String = ""
var busy: bool = false

var _plugin: Object = null


func _ready() -> void:
	_load_config()
	if Engine.has_singleton(PLUGIN_NAME):
		_plugin = Engine.get_singleton(PLUGIN_NAME)
		_plugin.connect("sign_in_succeeded", _on_google_token)
		_plugin.connect("sign_in_failed", _on_google_failed)
	_restore_session()


func is_signed_in() -> bool:
	return uid != ""


func sign_in() -> void:
	if busy or is_signed_in():
		return
	if _plugin == null:
		sign_in_failed.emit("Solo disponible en Android")
		return
	if api_key == "" or web_client_id == "":
		sign_in_failed.emit("Falta %s" % CONFIG_PATH)
		return
	busy = true
	_plugin.call("signIn", web_client_id)


func sign_out() -> void:
	if _plugin != null:
		_plugin.call("signOut")
	_clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SESSION_PATH))
	signed_out.emit()


func _load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_warning("No existe %s; copia data/firebase.example.json y rellénalo" % CONFIG_PATH)
		return
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		api_key = str(data.get("api_key", ""))
		web_client_id = str(data.get("web_client_id", ""))


func _on_google_token(google_id_token: String) -> void:
	var body := {
		"postBody": "id_token=%s&providerId=google.com" % google_id_token,
		"requestUri": "http://localhost",
		"returnSecureToken": true,
		"returnIdpCredential": true,
	}
	var res := await _post(SIGN_IN_URL % api_key, JSON.stringify(body), "application/json")
	busy = false
	if res["code"] != 200:
		sign_in_failed.emit(_error_message(res))
		return
	var data: Dictionary = res["data"]
	uid = str(data.get("localId", ""))
	email = str(data.get("email", ""))
	display_name = str(data.get("displayName", email))
	refresh_token = str(data.get("refreshToken", ""))
	id_token = str(data.get("idToken", ""))
	_save_session()
	signed_in.emit(display_name)


func _on_google_failed(message: String) -> void:
	busy = false
	if message == "cancelled":
		sign_in_failed.emit("Inicio de sesión cancelado")
	else:
		sign_in_failed.emit(message)


# Comprueba con Firebase que la sesión guardada sigue siendo válida.
# Sin conexión se mantiene la sesión guardada; si Firebase la rechaza, se borra.
func _restore_session() -> void:
	var file := FileAccess.open(SESSION_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if not data is Dictionary or str(data.get("refresh_token", "")) == "":
		return
	uid = str(data.get("uid", ""))
	email = str(data.get("email", ""))
	display_name = str(data.get("display_name", ""))
	refresh_token = str(data["refresh_token"])
	signed_in.emit(display_name)
	if api_key == "":
		return
	var body := "grant_type=refresh_token&refresh_token=%s" % refresh_token.uri_encode()
	var res := await _post(REFRESH_URL % api_key, body, "application/x-www-form-urlencoded")
	if res["code"] == 200:
		refresh_token = str(res["data"].get("refresh_token", refresh_token))
		id_token = str(res["data"].get("id_token", ""))
		_save_session()
	elif res["code"] >= 400 and res["code"] < 500:
		sign_out()


func _save_session() -> void:
	var file := FileAccess.open(SESSION_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar la sesión")
		return
	file.store_string(JSON.stringify({
		"uid": uid, "email": email, "display_name": display_name,
		"refresh_token": refresh_token,
	}))


func _clear() -> void:
	uid = ""
	email = ""
	display_name = ""
	refresh_token = ""
	id_token = ""
	busy = false


# Devuelve {"code": código HTTP (0 si no hubo conexión), "data": respuesta JSON}.
func _post(url: String, body: String, content_type: String) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)
	var err := http.request(url, ["Content-Type: " + content_type], HTTPClient.METHOD_POST, body)
	if err != OK:
		http.queue_free()
		return {"code": 0, "data": {}}
	var result: Array = await http.request_completed
	http.queue_free()
	var data = JSON.parse_string((result[3] as PackedByteArray).get_string_from_utf8())
	return {"code": int(result[1]), "data": data if data is Dictionary else {}}


func _error_message(res: Dictionary) -> String:
	if res["code"] == 0:
		return "Sin conexión"
	var error = res["data"].get("error", {})
	if error is Dictionary and error.has("message"):
		return str(error["message"])
	return "Error %d" % res["code"]

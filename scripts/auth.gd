class_name Auth
extends Node

# Inicio de sesión con Google + Firebase Auth (API REST).
# En Android, el plugin GoogleSignIn devuelve un ID token de Google; aquí se canjea
# por una sesión de Firebase. La sesión (refresh token) se guarda en SESSION_PATH
# para entrar automáticamente al abrir el juego.

signal signed_in(display_name: String)
signal signed_out
signal sign_in_failed(message: String)
signal _refresh_done

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
var id_token_expires_at: float = 0.0
var busy: bool = false

var _plugin: Object = null
var _refreshing: bool = false


func _ready() -> void:
	api_key = FirebaseConfig.get_value("api_key")
	web_client_id = FirebaseConfig.get_value("web_client_id")
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
		sign_in_failed.emit("Falta %s" % FirebaseConfig.PATH)
		return
	busy = true
	_plugin.call("signIn", web_client_id)


func sign_out() -> void:
	if _plugin != null:
		_plugin.call("signOut")
	_clear()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SESSION_PATH))
	signed_out.emit()


# ID token de Firebase para llamar a Firestore. Caduca en 1 hora; si hace falta
# se renueva con el refresh token. Devuelve "" si no hay sesión o no hay conexión.
func get_valid_id_token() -> String:
	if not is_signed_in():
		return ""
	if id_token == "" or Time.get_unix_time_from_system() >= id_token_expires_at:
		await _refresh()
	return id_token


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
		sign_in_failed.emit(HttpJson.error_message(res))
		return
	var data: Dictionary = res["data"]
	uid = str(data.get("localId", ""))
	email = str(data.get("email", ""))
	display_name = str(data.get("displayName", email))
	refresh_token = str(data.get("refreshToken", ""))
	_set_id_token(str(data.get("idToken", "")), data.get("expiresIn", 0))
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
	await _refresh()


# Pide un ID token nuevo. Si Firebase rechaza la sesión, se cierra.
# Si ya hay una renovación en curso, espera a que termine en vez de lanzar otra.
func _refresh() -> void:
	if _refreshing:
		await _refresh_done
		return
	if api_key == "" or refresh_token == "":
		return
	_refreshing = true
	var for_uid := uid
	var body := "grant_type=refresh_token&refresh_token=%s" % refresh_token.uri_encode()
	var res := await _post(REFRESH_URL % api_key, body, "application/x-www-form-urlencoded")
	_refreshing = false
	if uid != for_uid:
		pass  # Se cerró o cambió la sesión mientras tanto: se descarta la respuesta.
	elif res["code"] == 200:
		refresh_token = str(res["data"].get("refresh_token", refresh_token))
		_set_id_token(str(res["data"].get("id_token", "")), res["data"].get("expires_in", 0))
		_save_session()
	elif res["code"] >= 400 and res["code"] < 500:
		sign_out()
	_refresh_done.emit()


# Guarda el token con un minuto de margen antes de que caduque.
func _set_id_token(token: String, expires_in: Variant) -> void:
	id_token = token
	id_token_expires_at = Time.get_unix_time_from_system() + float(expires_in) - 60.0


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
	id_token_expires_at = 0.0
	busy = false


func _post(url: String, body: String, content_type: String) -> Dictionary:
	return await HttpJson.request(self, url, HTTPClient.METHOD_POST, PackedStringArray(["Content-Type: " + content_type]), body)

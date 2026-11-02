class_name LoginScreen
extends Node2D

# Pantalla de inicio: interior de taberna (TitleArt), título y botones para
# entrar con Google o como invitado.

signal google_pressed
signal guest_pressed

const GAME_TITLE := "Medieval Dash"
const BTN_GOOGLE := Rect2(210, 222, 220, 40)
const BTN_GUEST := Rect2(210, 274, 220, 40)

# Conectando con Google: botones bloqueados.
var busy: bool = false:
	set(value):
		busy = value
		queue_redraw()
# Esperando a la primera sincronización de la cuenta: botones bloqueados.
var loading: bool = false:
	set(value):
		loading = value
		queue_redraw()
# Mensaje de error del último intento de inicio de sesión.
var status: String = "":
	set(value):
		status = value
		queue_redraw()


func _ready() -> void:
	add_child(TitleArt.new())


func handle_tap(p: Vector2) -> void:
	if busy or loading:
		return
	if BTN_GOOGLE.has_point(p):
		status = ""
		google_pressed.emit()
	elif BTN_GUEST.has_point(p):
		status = ""
		guest_pressed.emit()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var palette := SpriteFactory.PALETTE
	var board := TitleArt.SIGN_RECT
	var title_pos := Vector2(board.position.x, board.position.y + 50)
	draw_string(font, title_pos + Vector2(2, 2), GAME_TITLE, HORIZONTAL_ALIGNMENT_CENTER, board.size.x, UiDraw.HUGE, palette["K"])
	draw_string(font, title_pos, GAME_TITLE, HORIZONTAL_ALIGNMENT_CENTER, board.size.x, UiDraw.HUGE, palette["Y"])
	var google_label := "Entrar con Google"
	if busy:
		google_label = "Conectando..."
	elif loading:
		google_label = "Cargando progreso..."
	UiDraw.wood_button(self, BTN_GOOGLE, google_label)
	UiDraw.wood_button(self, BTN_GUEST, "Jugar como invitado")
	if status != "":
		var y := BTN_GUEST.end.y + 8
		draw_rect(Rect2(BTN_GUEST.position.x - 40, y, BTN_GUEST.size.x + 80, 22), Color(0, 0, 0, 0.6))
		draw_string(font, Vector2(0, y + 15), status, HORIZONTAL_ALIGNMENT_CENTER, 640, UiDraw.SMALL, Color("e07a5f"))

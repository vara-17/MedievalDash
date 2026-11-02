class_name ResultScreen
extends Node2D

# Panel al terminar un nivel, encima del nivel: puntos, estrellas y botones
# para volver a los niveles, reintentar o pasar al siguiente.

signal menu_pressed
signal retry_pressed
signal next_pressed

const PANEL := Rect2(140, 60, 360, 260)
const BTN_MENU := Rect2(150, 250, 100, 44)
const BTN_RETRY := Rect2(270, 250, 100, 44)
const BTN_NEXT := Rect2(390, 250, 100, 44)

var level_name: String = ""
var score: int = 0
var stars: int = 0
var has_next: bool = false


func _ready() -> void:
	z_index = 1


func show_result(new_level_name: String, new_score: int, new_stars: int, new_has_next: bool) -> void:
	level_name = new_level_name
	score = new_score
	stars = new_stars
	has_next = new_has_next
	queue_redraw()


func handle_tap(p: Vector2) -> void:
	if BTN_MENU.has_point(p):
		menu_pressed.emit()
	elif BTN_RETRY.has_point(p):
		retry_pressed.emit()
	elif has_next and BTN_NEXT.has_point(p):
		next_pressed.emit()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var dark := Color("2b2d42")
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, 0.6))
	draw_rect(PANEL, Color("3d405b"))
	var title := "¡Nivel superado!" if stars > 0 else "Nivel fallido"
	draw_string(font, Vector2(PANEL.position.x, 100), title, HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x, 24)
	draw_string(font, Vector2(PANEL.position.x, 130), level_name, HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x, 14)
	draw_string(font, Vector2(PANEL.position.x, 162), "Puntos: %d" % score, HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x, 18)
	for i in 3:
		var pos := Vector2(250 + i * 70, 205)
		if i < stars:
			draw_circle(pos, 20.0, Color.GOLD)
		else:
			draw_arc(pos, 20.0, 0.0, TAU, 24, Color.GRAY, 2.0)
	draw_rect(BTN_MENU, Color("e07a5f"))
	draw_string(font, BTN_MENU.position + Vector2(0, 28), "Menú", HORIZONTAL_ALIGNMENT_CENTER, BTN_MENU.size.x, 16, dark)
	draw_rect(BTN_RETRY, Color("81b29a"))
	draw_string(font, BTN_RETRY.position + Vector2(0, 28), "Reintentar", HORIZONTAL_ALIGNMENT_CENTER, BTN_RETRY.size.x, 16, dark)
	if has_next:
		draw_rect(BTN_NEXT, Color("f2cc8f"))
		draw_string(font, BTN_NEXT.position + Vector2(0, 28), "Siguiente", HORIZONTAL_ALIGNMENT_CENTER, BTN_NEXT.size.x, 16, dark)

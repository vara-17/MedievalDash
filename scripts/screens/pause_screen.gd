class_name PauseScreen
extends Node2D

# Pergamino de pausa encima del nivel congelado: seguir jugando, empezar de
# nuevo o volver a los niveles.

signal resume_pressed
signal retry_pressed
signal quit_pressed

const PANEL := Rect2(200, 50, 240, 260)
const BTN_RESUME := Rect2(240, 140, 160, 36)
const BTN_RETRY := Rect2(240, 188, 160, 36)
const BTN_QUIT := Rect2(240, 236, 160, 36)

var level_name: String = ""


func _ready() -> void:
	z_index = 1


func show_for(new_level_name: String) -> void:
	level_name = new_level_name
	queue_redraw()


func handle_tap(p: Vector2) -> void:
	if BTN_RESUME.has_point(p):
		resume_pressed.emit()
	elif BTN_RETRY.has_point(p):
		retry_pressed.emit()
	elif BTN_QUIT.has_point(p):
		quit_pressed.emit()


func _draw() -> void:
	var palette := SpriteFactory.PALETTE
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, 0.6))
	UiDraw.parchment(self, PANEL)
	draw_string(font, Vector2(PANEL.position.x, 98), "Pausa", HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x, UiDraw.LARGE, palette["B"])
	draw_string(font, Vector2(PANEL.position.x, 122), level_name, HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x, UiDraw.SMALL, palette["D"])
	UiDraw.wood_button(self, BTN_RESUME, "Continuar")
	UiDraw.wood_button(self, BTN_RETRY, "Repetir")
	UiDraw.wood_button(self, BTN_QUIT, "Salir")

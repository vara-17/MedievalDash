class_name ResultScreen
extends Node2D

# Pergamino al terminar un nivel, encima del nivel: monedas, estrellas (que
# aparecen de una en una) y botones para volver a los niveles, reintentar o
# pasar al siguiente.

signal menu_pressed
signal retry_pressed
signal next_pressed

const PANEL := Rect2(160, 44, 320, 272)
const STAR_Y := 166.0
const STAR_GAP := 56.0
const STAR_DELAY := 0.35
const BTN_MENU := Rect2(176, 256, 88, 36)
const BTN_RETRY := Rect2(276, 256, 88, 36)
const BTN_NEXT := Rect2(376, 256, 88, 36)

var level_name: String = ""
var score: int = 0
var stars: int = 0
var has_next: bool = false
# Estrellas ya mostradas en la animación de entrada.
var shown_stars: int = 0
var star_timer: float = 0.0


func _ready() -> void:
	z_index = 1


func show_result(new_level_name: String, new_score: int, new_stars: int, new_has_next: bool) -> void:
	level_name = new_level_name
	score = new_score
	stars = new_stars
	has_next = new_has_next
	shown_stars = 0
	star_timer = STAR_DELAY
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or shown_stars >= stars:
		return
	star_timer -= delta
	if star_timer <= 0.0:
		shown_stars += 1
		star_timer = STAR_DELAY
		queue_redraw()


func handle_tap(p: Vector2) -> void:
	if BTN_MENU.has_point(p):
		menu_pressed.emit()
	elif BTN_RETRY.has_point(p):
		retry_pressed.emit()
	elif has_next and BTN_NEXT.has_point(p):
		next_pressed.emit()


func _draw() -> void:
	var palette := SpriteFactory.PALETTE
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, 0.6))
	UiDraw.parchment(self, PANEL)
	var title := "¡Nivel superado!" if stars > 0 else "Nivel fallido"
	var x := PANEL.position.x
	var w := PANEL.size.x
	draw_string(font, Vector2(x, 90), title, HORIZONTAL_ALIGNMENT_CENTER, w, 26, palette["B"] if stars > 0 else palette["R"])
	draw_string(font, Vector2(x, 114), level_name, HORIZONTAL_ALIGNMENT_CENTER, w, 14, palette["D"])
	for i in 3:
		UiDraw.star(self, Vector2(PANEL.get_center().x + (i - 1) * STAR_GAP, STAR_Y), i < shown_stars)
	var coin := SpriteFactory.make("coin")
	var score_text := str(score)
	var text_w := font.get_string_size(score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	var start := PANEL.get_center().x - (text_w + 24) / 2.0
	UiDraw.sprite(self, coin, Vector2(start + 8, 213))
	draw_string(font, Vector2(start + 24, 221), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, palette["K"])
	UiDraw.wood_button(self, BTN_MENU, "Menú")
	UiDraw.wood_button(self, BTN_RETRY, "Reintentar")
	if has_next:
		UiDraw.wood_button(self, BTN_NEXT, "Siguiente")

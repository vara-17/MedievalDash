class_name LevelSelectScreen
extends Node2D

# Niveles de un escenario, con las estrellas conseguidas, sobre el fondo del
# local. Cada nivel se desbloquea al sacar al menos una estrella en el anterior.

signal back_pressed
signal level_pressed(index: int)

const BTN_BACK := Rect2(8, 8, 90, 30)
const SIGN := Rect2(110, 16, 420, 90)
const COLUMNS := 3
const BTN_SIZE := Vector2(170, 112)
const GAP := 18.0
const ORIGIN := Vector2(48, 150)
const STAR_GAP := 38.0

var venue: Dictionary = {}
var save: SaveData


# Se llama al entrar en la pantalla, con el escenario elegido y el progreso actual.
func refresh(new_venue: Dictionary, new_save: SaveData) -> void:
	venue = new_venue
	save = new_save
	queue_redraw()


func handle_tap(p: Vector2) -> void:
	if BTN_BACK.has_point(p):
		back_pressed.emit()
		return
	for i in venue["levels"].size():
		if _button_rect(i).has_point(p) and save.is_unlocked(str(venue["id"]), i):
			level_pressed.emit(i)
			return


func _button_rect(i: int) -> Rect2:
	var col := i % COLUMNS
	var row := floori(i / float(COLUMNS))
	var pos := ORIGIN + Vector2(col * (BTN_SIZE.x + GAP), row * (BTN_SIZE.y + GAP))
	return Rect2(pos, BTN_SIZE)


func _draw() -> void:
	if save == null:
		return
	var palette := SpriteFactory.PALETTE
	var venue_id := str(venue["id"])
	var levels: Array = venue["levels"]
	UiDraw.board(self, SIGN)
	UiDraw.text(self, Vector2(SIGN.position.x, 60), str(venue["name"]), 34, palette["Y"], HORIZONTAL_ALIGNMENT_CENTER, SIGN.size.x)
	UiDraw.text(self, Vector2(SIGN.position.x, 88), "%s · Elige un nivel" % venue["goal"], 14, palette["W"], HORIZONTAL_ALIGNMENT_CENTER, SIGN.size.x)
	UiDraw.wood_button(self, BTN_BACK, "‹ Mapa")
	for i in levels.size():
		_draw_level_card(i, levels[i], save.is_unlocked(venue_id, i), save.get_stars(venue_id, i))


func _draw_level_card(index: int, level: Dictionary, unlocked: bool, earned: int) -> void:
	var palette := SpriteFactory.PALETTE
	var r := _button_rect(index)
	UiDraw.board(self, r, not unlocked)
	var text_color: Color = palette["W"] if unlocked else palette["A"]
	UiDraw.text(self, r.position + Vector2(0, 28), "Nivel %d" % (index + 1), 18, text_color, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	UiDraw.text(self, r.position + Vector2(0, 48), str(level["name"]), 12, text_color, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var center := r.position + Vector2(r.size.x / 2.0, 80)
	if unlocked:
		for s in 3:
			UiDraw.star(self, center + Vector2((s - 1) * STAR_GAP, 0), s < earned, "A")
	else:
		UiDraw.sprite(self, SpriteFactory.make("lock"), center)

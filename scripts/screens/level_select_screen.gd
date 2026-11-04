class_name LevelSelectScreen
extends Node2D

# Niveles de un escenario, con las estrellas conseguidas, sobre el fondo del
# local, en filas de hasta 4 centradas. Cada nivel muestra su dificultad
# ("difficulty" en venues.json) y se desbloquea al sacar al menos una estrella
# en el anterior.

signal back_pressed
signal level_pressed(index: int)

const BTN_BACK := Rect2(8, 8, 90, 30)
const SIGN := Rect2(110, 10, 420, 78)
const COLUMNS := 4
const BTN_SIZE := Vector2(134, 106)
const GAP := 12.0
const TOP := 100.0
const SCREEN_WIDTH := 640.0
const STAR_GAP := 38.0
# Nombre y color de cada dificultad.
const DIFFICULTIES := {
	"easy": ["Fácil", "N"],
	"medium": ["Normal", "Y"],
	"hard": ["Difícil", "O"],
	"extreme": ["Extremo", "R"],
}

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
	var in_row := mini(COLUMNS, venue["levels"].size() - row * COLUMNS)
	var row_width := in_row * BTN_SIZE.x + (in_row - 1) * GAP
	var left := (SCREEN_WIDTH - row_width) / 2.0
	return Rect2(Vector2(left + col * (BTN_SIZE.x + GAP), TOP + row * (BTN_SIZE.y + GAP)), BTN_SIZE)


func _draw() -> void:
	if save == null:
		return
	var palette := SpriteFactory.PALETTE
	var venue_id := str(venue["id"])
	var levels: Array = venue["levels"]
	UiDraw.board(self, SIGN)
	UiDraw.text(self, Vector2(SIGN.position.x, 50), str(venue["name"]), UiDraw.HUGE, palette["Y"], HORIZONTAL_ALIGNMENT_CENTER, SIGN.size.x)
	UiDraw.text(self, Vector2(SIGN.position.x, 76), "%s · Elige un nivel" % venue["goal"], UiDraw.SMALL, palette["W"], HORIZONTAL_ALIGNMENT_CENTER, SIGN.size.x)
	UiDraw.wood_button(self, BTN_BACK, "‹ Mapa")
	for i in levels.size():
		_draw_level_card(i, levels[i], save.is_unlocked(venue_id, i), save.get_stars(venue_id, i))


func _draw_level_card(index: int, level: Dictionary, unlocked: bool, earned: int) -> void:
	var palette := SpriteFactory.PALETTE
	var r := _button_rect(index)
	UiDraw.board(self, r, not unlocked)
	var text_color: Color = palette["W"] if unlocked else palette["A"]
	UiDraw.text(self, r.position + Vector2(0, 24), "Nivel %d" % (index + 1), UiDraw.MEDIUM, text_color, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	UiDraw.text(self, r.position + Vector2(0, 42), str(level["name"]), UiDraw.SMALL, text_color, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var difficulty: Array = DIFFICULTIES.get(str(level.get("difficulty", "easy")), DIFFICULTIES["easy"])
	var difficulty_color: Color = palette[difficulty[1]] if unlocked else palette["A"]
	UiDraw.text(self, r.position + Vector2(0, 59), str(difficulty[0]), UiDraw.SMALL, difficulty_color, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	var center := r.position + Vector2(r.size.x / 2.0, 82)
	if unlocked:
		for s in 3:
			UiDraw.star(self, center + Vector2((s - 1) * STAR_GAP, 0), s < earned, "A")
	else:
		UiDraw.sprite(self, SpriteFactory.make("lock"), center)

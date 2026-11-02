class_name LevelSelectScreen
extends Node2D

# Niveles de un escenario, con las estrellas conseguidas. Cada nivel se
# desbloquea al sacar al menos una estrella en el anterior.

signal back_pressed
signal level_pressed(index: int)

const BTN_BACK := Rect2(8, 8, 90, 30)
const COLUMNS := 3
const BTN_SIZE := Vector2(160, 90)
const GAP := 20.0
const ORIGIN := Vector2(60, 110)

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
	var font := ThemeDB.fallback_font
	var dark := Color("2b2d42")
	var venue_id := str(venue["id"])
	var levels: Array = venue["levels"]
	draw_rect(get_viewport_rect(), dark)
	draw_string(font, Vector2(0, 60), str(venue["name"]), HORIZONTAL_ALIGNMENT_CENTER, 640, 36)
	draw_string(font, Vector2(0, 88), "%s · Elige un nivel" % venue["goal"], HORIZONTAL_ALIGNMENT_CENTER, 640, 14)
	UiDraw.wood_button(self, BTN_BACK, "‹ Mapa")
	for i in levels.size():
		var r := _button_rect(i)
		var unlocked := save.is_unlocked(venue_id, i)
		var text_color := dark if unlocked else Color.GRAY
		draw_rect(r, Color("81b29a") if unlocked else Color("555770"))
		draw_string(font, r.position + Vector2(0, 26), "Nivel %d" % (i + 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, text_color)
		draw_string(font, r.position + Vector2(0, 46), str(levels[i]["name"]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, text_color)
		if unlocked:
			var earned := save.get_stars(venue_id, i)
			for s in 3:
				var center := r.position + Vector2(r.size.x / 2.0 - 28.0 + s * 28.0, 70)
				if s < earned:
					draw_circle(center, 9.0, Color.GOLD)
				else:
					draw_arc(center, 9.0, 0.0, TAU, 20, dark, 2.0)
		else:
			draw_string(font, r.position + Vector2(0, 74), "Bloqueado", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, Color.GRAY)

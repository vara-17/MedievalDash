class_name MapScreen
extends Node2D

# Mapa del reino: un edificio por escenario (taberna, armería...), unidos por un
# camino. Cada escenario se desbloquea al completar el que pide en "requires".
# Al tocar un escenario disponible emite venue_pressed con su índice.

signal venue_pressed(index: int)

const TOP_BAR_HEIGHT := 40.0
const CARD_SIZE := Vector2(130, 40)
const CARD_OFFSET := Vector2(-65, 30)
const PLAQUE_SIZE := Vector2(36, 36)
const PLAQUE_OFFSET := Vector2(26, -46)
const HIT_RECT := Rect2(-65, -48, 130, 118)
const LOCKED_TINT := Color(0.45, 0.45, 0.5)
const ROAD_STEP := 12.0
const ROAD_BEND := 50.0
const TREES := [
	Vector2(40, 90), Vector2(80, 300), Vector2(330, 80), Vector2(300, 320),
	Vector2(590, 260), Vector2(560, 90), Vector2(610, 320), Vector2(40, 200),
]
const TUFT_COUNT := 70
const TUFT_SEED := 7

var venues: Array = []
var save: SaveData
# Texturas creadas una vez; si se crean dentro de _draw se liberan antes de pintarse.
var house_texs: Dictionary = {}
var tree_tex: Texture2D
var icon_texs: Dictionary = {}
var tufts: Array[Vector2] = []


func _ready() -> void:
	z_index = -1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tree_tex = SpriteFactory.make("tree")
	var rng := RandomNumberGenerator.new()
	rng.seed = TUFT_SEED
	for i in TUFT_COUNT:
		tufts.append(Vector2(rng.randf_range(0, 640), rng.randf_range(TOP_BAR_HEIGHT + 6, 356)))
	get_viewport().size_changed.connect(queue_redraw)


# Se llama al entrar en el mapa, para reflejar el progreso actual.
func refresh(new_venues: Array, new_save: SaveData) -> void:
	venues = new_venues
	save = new_save
	queue_redraw()


func is_unlocked(index: int) -> bool:
	var requires := str(venues[index].get("requires", ""))
	if requires == "":
		return true
	for v in venues:
		if v["id"] == requires:
			return save.is_venue_complete(requires, v["levels"].size())
	return false


func handle_tap(p: Vector2) -> void:
	for i in venues.size():
		var rect := Rect2(HIT_RECT.position + _venue_pos(i), HIT_RECT.size)
		if rect.has_point(p) and is_unlocked(i) and not venues[i]["levels"].is_empty():
			venue_pressed.emit(i)
			return


func _venue_pos(index: int) -> Vector2:
	var pos: Array = venues[index]["map_pos"]
	return Vector2(pos[0], pos[1])


func _draw() -> void:
	if save == null:
		return
	var palette := SpriteFactory.PALETTE
	var view := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, view), palette["G"])
	for t in tufts:
		draw_rect(Rect2(t, Vector2(2, 2)), palette["N"])
		draw_rect(Rect2(t + Vector2(3, -2), Vector2(2, 4)), palette["N"])
	for i in range(1, venues.size()):
		_draw_road(_venue_pos(i - 1), _venue_pos(i))
	for pos in TREES:
		draw_texture_rect(tree_tex, SpriteFactory.rect_centered(tree_tex, pos), false)
	for i in venues.size():
		_draw_venue(i)
	_draw_top_bar(view.x)


func _draw_top_bar(width: float) -> void:
	var palette := SpriteFactory.PALETTE
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, width, TOP_BAR_HEIGHT), palette["D"])
	draw_rect(Rect2(0, TOP_BAR_HEIGHT - 3, width, 3), palette["K"])
	draw_string(font, Vector2(14, 27), "Mapa del reino", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, palette["Y"])


# Camino de tierra con una curva suave entre dos escenarios.
func _draw_road(from: Vector2, to: Vector2) -> void:
	var palette := SpriteFactory.PALETTE
	var mid := (from + to) / 2.0 + (to - from).orthogonal().normalized() * ROAD_BEND
	var steps := ceili(from.distance_to(to) / ROAD_STEP)
	for s in steps + 1:
		var t := s / float(steps)
		var p := from.lerp(mid, t).lerp(mid.lerp(to, t), t)
		draw_rect(Rect2(p - Vector2(5, 5), Vector2(10, 10)), palette["B"])
		draw_rect(Rect2(p - Vector2(4, 4), Vector2(8, 8)), palette["L"])


func _draw_venue(index: int) -> void:
	var palette := SpriteFactory.PALETTE
	var font := ThemeDB.fallback_font
	var venue: Dictionary = venues[index]
	var pos := _venue_pos(index)
	var unlocked := is_unlocked(index)
	var tint := Color.WHITE if unlocked else LOCKED_TINT
	var roof := str(venue["roof"])
	if not house_texs.has(roof):
		house_texs[roof] = SpriteFactory.make("house", {"X": palette[roof]})
	var house: Texture2D = house_texs[roof]
	draw_texture_rect(house, SpriteFactory.rect_centered(house, pos), false, tint)
	var plaque := Rect2(pos + PLAQUE_OFFSET, PLAQUE_SIZE)
	draw_rect(plaque, palette["K"])
	draw_rect(plaque.grow(-2), palette["W"] * tint)
	var icon := _icon(str(venue["icon"]))
	if icon != null:
		draw_texture_rect(icon, SpriteFactory.rect_centered(icon, plaque.get_center()), false, tint)
	var card := Rect2(pos + CARD_OFFSET, CARD_SIZE)
	draw_rect(card, palette["K"])
	draw_rect(card.grow(-2), palette["L"] * tint)
	draw_string(font, card.position + Vector2(0, 17), str(venue["name"]), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 15, palette["K"])
	var level_count: int = venue["levels"].size()
	var status := ""
	if not unlocked:
		status = "Bloqueado"
	elif level_count == 0:
		status = "Próximamente"
	if status != "":
		draw_string(font, card.position + Vector2(0, 33), status, HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 12, palette["D"])
		return
	var center := card.position + Vector2(card.size.x / 2.0 - 16, 28)
	draw_circle(center, 6.0, palette["Y"])
	draw_arc(center, 6.0, 0.0, TAU, 16, palette["K"], 1.5)
	var stars := "%d/%d" % [save.total_stars(str(venue["id"])), level_count * 3]
	draw_string(font, center + Vector2(10, 5), stars, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, palette["K"])


func _icon(sprite_name: String) -> Texture2D:
	if not icon_texs.has(sprite_name):
		icon_texs[sprite_name] = SpriteFactory.make(sprite_name, {"X": SpriteFactory.PALETTE["Y"]})
	return icon_texs[sprite_name]

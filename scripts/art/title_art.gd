class_name TitleArt
extends Node2D

# Decoración de la pantalla de inicio: interior de taberna sobre el Background
# (con la pared alta), con estandartes, antorchas que parpadean, ventanas,
# el cartel del título y una mesa a cada lado.

const SIGN_RECT := Rect2(170, 26, 300, 70)
const FLICKER_TIME := 0.18
const BANNERS := {Vector2(40, 40): "R", Vector2(600, 40): "U"}
const TORCHES := [Vector2(140, 70), Vector2(500, 70)]
const WINDOWS := [Vector2(240, 150), Vector2(400, 150)]
const LEFT_TABLE := Vector2(110, 300)
const RIGHT_TABLE := Vector2(530, 300)

var torch_frames: Array[Texture2D] = []
var banner_texs: Dictionary = {}
var window_tex: Texture2D
var table_tex: Texture2D
var waiter_tex: Texture2D
var customer_tex: Texture2D
var mug_tex: Texture2D
var frame: int = 0
var flicker_timer: float = 0.0


func _ready() -> void:
	z_index = -1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var palette := SpriteFactory.PALETTE
	torch_frames = [
		SpriteFactory.make("torch", {"X": palette["O"]}),
		SpriteFactory.make("torch", {"X": palette["R"]}),
	]
	for pos in BANNERS:
		banner_texs[pos] = SpriteFactory.make("banner", {"X": palette[BANNERS[pos]]})
	window_tex = SpriteFactory.make("window")
	table_tex = SpriteFactory.make("table")
	waiter_tex = SpriteFactory.make("waiter")
	customer_tex = SpriteFactory.make("customer", {"X": palette["G"]})
	mug_tex = SpriteFactory.make("mug", {"X": palette["Y"]})


func _process(delta: float) -> void:
	if not visible:
		return
	flicker_timer -= delta
	if flicker_timer <= 0.0:
		flicker_timer = FLICKER_TIME * randf_range(0.6, 1.4)
		frame = 1 - frame
		queue_redraw()


func _draw() -> void:
	for pos in banner_texs:
		_sprite(banner_texs[pos], pos)
	for pos in WINDOWS:
		_sprite(window_tex, pos)
	for pos in TORCHES:
		_sprite(torch_frames[frame], pos)
	_draw_sign()
	_sprite(customer_tex, LEFT_TABLE + Vector2(-56, -6))
	_sprite(table_tex, LEFT_TABLE)
	_sprite(mug_tex, LEFT_TABLE + Vector2(8, -24))
	_sprite(table_tex, RIGHT_TABLE)
	_sprite(mug_tex, RIGHT_TABLE + Vector2(-12, -24))
	_sprite(waiter_tex, RIGHT_TABLE + Vector2(56, -6))


func _sprite(tex: Texture2D, center: Vector2) -> void:
	draw_texture_rect(tex, SpriteFactory.rect_centered(tex, center), false)


# Cartel de madera colgado con dos cadenas; el texto lo dibuja la escena principal.
func _draw_sign() -> void:
	var palette := SpriteFactory.PALETTE
	for x in [SIGN_RECT.position.x + 30, SIGN_RECT.end.x - 32]:
		for y in range(0, int(SIGN_RECT.position.y), 6):
			draw_rect(Rect2(x, y, 2, 4), palette["A"])
	draw_rect(SIGN_RECT, palette["K"])
	draw_rect(SIGN_RECT.grow(-2), palette["B"])
	draw_rect(SIGN_RECT.grow(-6), palette["D"])
	for corner in [Vector2(10, 10), Vector2(SIGN_RECT.size.x - 12, 10),
			Vector2(10, SIGN_RECT.size.y - 12), Vector2(SIGN_RECT.size.x - 12, SIGN_RECT.size.y - 12)]:
		draw_rect(Rect2(SIGN_RECT.position + corner, Vector2(2, 2)), palette["Z"])

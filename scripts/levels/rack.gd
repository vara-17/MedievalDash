class_name Rack
extends Node2D

# Estante con un tipo de objeto (espada, poción...). Quien atiende coge de
# aquí lo que piden los clientes. Lo usan la armería y la enfermería.

const RECT := Rect2(-26, -30, 52, 60)

var item: String = ""
var item_name: String = ""
var tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex = SpriteFactory.make(item)


func contains_point(p: Vector2) -> bool:
	return RECT.grow(6).has_point(p - position)


func staff_position() -> Vector2:
	return position + Vector2(-48, 0)


func _draw() -> void:
	var palette := SpriteFactory.PALETTE
	draw_rect(RECT, palette["K"])
	draw_rect(RECT.grow(-2), palette["D"])
	draw_rect(Rect2(RECT.position.x + 2, RECT.end.y - 10, RECT.size.x - 4, 8), palette["B"])
	if tex != null:
		draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2(0, -6)), false)
	UiDraw.text(self, Vector2(RECT.position.x - 10, RECT.end.y + 14), item_name, UiDraw.SMALL, SpriteFactory.PALETTE["W"], HORIZONTAL_ALIGNMENT_CENTER, RECT.size.x + 20)

class_name Table
extends Spot

# Mesa de la taberna: el cliente se sienta a la izquierda y el tabernero
# le atiende desde abajo.

var tex: Texture2D


func _init() -> void:
	size = Vector2(64, 40)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex = SpriteFactory.make("table")


func customer_position() -> Vector2:
	return position + Vector2(-56, 0)


func staff_position() -> Vector2:
	return position + Vector2(-56, 32)


func _draw() -> void:
	if tex != null:
		draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2.ZERO), false)

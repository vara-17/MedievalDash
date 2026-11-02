class_name Table
extends Node2D

const SIZE := Vector2(64, 40)

var customer: Customer = null
var tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex = SpriteFactory.make("table")


func seat_position() -> Vector2:
	return position + Vector2(-56, 0)


func waiter_position() -> Vector2:
	return position + Vector2(-56, 32)


func _draw() -> void:
	if tex != null:
		draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2.ZERO), false)

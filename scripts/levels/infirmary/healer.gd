class_name Healer
extends Staff

# Curandera: lleva una medicina cada vez, cogida de un estante. Al coger otra,
# deja la que llevaba.

var carrying: String = ""


func _init() -> void:
	sprite_name = "healer"


func _drop_all() -> void:
	carrying = ""


func _draw_carried() -> void:
	if carrying == "":
		return
	var tex := SpriteFactory.make(carrying)
	draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2(0, -28)), false)

class_name Waiter
extends Staff

# Tabernero: lleva la bebida de un cliente cada vez.

var carrying: TavernCustomer = null


func _init() -> void:
	sprite_name = "waiter"


func _drop_all() -> void:
	carrying = null


func _draw_carried() -> void:
	if carrying != null and carrying.dish_tex != null:
		draw_texture_rect(carrying.dish_tex, SpriteFactory.rect_centered(carrying.dish_tex, Vector2(0, -26)), false)

class_name FrontDesk
extends Node2D

# Mostrador de la enfermería, junto al primero de la cola. Solo se atiende al
# cliente que está aquí: si viene a comprar, se le entrega la medicina en el
# mostrador; si viene a curarse, se le lleva a una camilla.

const RECT := Rect2(-14, -28, 28, 56)


func contains_point(p: Vector2) -> bool:
	return RECT.grow(10).has_point(p - position)


func staff_position() -> Vector2:
	return position + Vector2(38, 0)


func _draw() -> void:
	var palette := SpriteFactory.PALETTE
	draw_rect(RECT, palette["K"])
	draw_rect(RECT.grow(-2), palette["B"])
	draw_rect(Rect2(RECT.position + Vector2(2, 2), Vector2(RECT.size.x - 4, 6)), palette["L"])
	draw_rect(Rect2(RECT.position + Vector2(2, RECT.size.y - 6), Vector2(RECT.size.x - 4, 4)), palette["D"])
	# Cruz roja de enfermería en el frente.
	draw_rect(Rect2(-3, -8, 6, 18), palette["R"])
	draw_rect(Rect2(-8, -2, 16, 6), palette["R"])

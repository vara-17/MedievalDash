class_name Counter
extends Spot

# Mostrador de la armería: el cliente espera a la izquierda y el herrero
# le atiende desde la derecha.


func _init() -> void:
	size = Vector2(28, 56)


func customer_position() -> Vector2:
	return position + Vector2(-42, 0)


func staff_position() -> Vector2:
	return position + Vector2(40, 0)


func _draw() -> void:
	var palette := SpriteFactory.PALETTE
	var r := Rect2(-size / 2.0, size)
	draw_rect(r, palette["K"])
	draw_rect(r.grow(-2), palette["B"])
	draw_rect(Rect2(r.position + Vector2(2, 2), Vector2(size.x - 4, 6)), palette["L"])
	draw_rect(Rect2(r.position + Vector2(2, size.y - 6), Vector2(size.x - 4, 4)), palette["D"])

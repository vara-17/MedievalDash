class_name Counter
extends Node2D

# Mostrador de la armería: el cliente espera a la izquierda y el herrero
# le atiende desde la derecha.

const SIZE := Vector2(28, 56)

var customer: ArmoryCustomer = null


func customer_position() -> Vector2:
	return position + Vector2(-42, 0)


func smith_position() -> Vector2:
	return position + Vector2(40, 0)


func _draw() -> void:
	var palette := SpriteFactory.PALETTE
	var r := Rect2(-SIZE / 2.0, SIZE)
	draw_rect(r, palette["K"])
	draw_rect(r.grow(-2), palette["B"])
	draw_rect(Rect2(r.position + Vector2(2, 2), Vector2(SIZE.x - 4, 6)), palette["L"])
	draw_rect(Rect2(r.position + Vector2(2, SIZE.y - 6), Vector2(SIZE.x - 4, 4)), palette["D"])

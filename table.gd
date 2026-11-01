class_name Table
extends Node2D

const SIZE := Vector2(64, 40)

var customer: Customer = null


func seat_position() -> Vector2:
	return position + Vector2(-56, 0)


func waiter_position() -> Vector2:
	return position + Vector2(-56, 32)


func _draw() -> void:
	draw_rect(Rect2(-SIZE / 2.0, SIZE), Color("a1887f"))

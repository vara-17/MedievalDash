class_name Waiter
extends Node2D

const SPEED := 180.0

var target: Vector2
var on_arrive: Callable = Callable()
var carrying: Customer = null


func _ready() -> void:
	target = position


func go_to(p: Vector2, callback: Callable) -> void:
	target = p
	on_arrive = callback
	_check_arrival()


func _process(delta: float) -> void:
	position = position.move_toward(target, SPEED * delta)
	_check_arrival()
	queue_redraw()


func _check_arrival() -> void:
	if position.is_equal_approx(target) and on_arrive.is_valid():
		var cb := on_arrive
		on_arrive = Callable()
		cb.call()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 13.0, Color("4fc3f7"))
	if carrying != null:
		draw_circle(Vector2(0, -22), 9.0, carrying.color)

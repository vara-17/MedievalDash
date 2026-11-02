class_name Waiter
extends Node2D

const SPEED := 180.0

var target: Vector2
var on_arrive: Callable = Callable()
var carrying: Customer = null
var tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	target = position
	tex = SpriteFactory.make("waiter")


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
	if tex != null:
		draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2.ZERO), false)
	if carrying != null and carrying.dish_tex != null:
		draw_texture_rect(carrying.dish_tex, SpriteFactory.rect_centered(carrying.dish_tex, Vector2(0, -26)), false)

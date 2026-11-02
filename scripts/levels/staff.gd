class_name Staff
extends Node2D

# Quien atiende (tabernero, herrero...): camina a donde se le manda y, al
# llegar, ejecuta la acción pendiente. Lo que lleva encima lo pinta la subclase.

const SPEED := 180.0

var sprite_name: String = ""
var target: Vector2
var on_arrive: Callable = Callable()
var tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	target = position
	tex = SpriteFactory.make(sprite_name)


func go_to(p: Vector2, callback: Callable) -> void:
	target = p
	on_arrive = callback
	_check_arrival()


# Vuelve a la posición de inicio, sin acción pendiente ni nada en las manos.
func reset(p: Vector2) -> void:
	position = p
	target = p
	on_arrive = Callable()
	_drop_all()


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
	_draw_carried()


# Suelta lo que lleve encima.
func _drop_all() -> void:
	pass


# Dibuja lo que lleva encima, sobre la cabeza.
func _draw_carried() -> void:
	pass

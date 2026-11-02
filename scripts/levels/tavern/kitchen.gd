class_name Kitchen
extends Node2D

const RECT := Rect2(-50, -40, 100, 80)
const COOK_TIME := 4.0

var pending: Array = []
var ready_dishes: Array = []
var cooking: Customer = null
var cook_timer: float = 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _process(delta: float) -> void:
	if cooking == null and not pending.is_empty():
		cooking = pending.pop_front()
		cook_timer = COOK_TIME
	if cooking != null:
		cook_timer -= delta
		if cook_timer <= 0.0:
			ready_dishes.append(cooking)
			cooking = null
	queue_redraw()


func add_order(c: Customer) -> void:
	pending.append(c)


func cancel_orders_of(c: Customer) -> void:
	pending.erase(c)
	ready_dishes.erase(c)
	if cooking == c:
		cooking = null


func take_ready() -> Customer:
	if ready_dishes.is_empty():
		return null
	return ready_dishes.pop_front()


func contains_point(p: Vector2) -> bool:
	return RECT.has_point(p - position)


func waiter_position() -> Vector2:
	return position + Vector2(-70, 0)


func _draw() -> void:
	draw_rect(RECT, SpriteFactory.PALETTE["B"])
	draw_rect(RECT, SpriteFactory.PALETTE["K"], false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(-16, -46), "Barra", HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	if cooking != null:
		var ratio := 1.0 - cook_timer / COOK_TIME
		draw_rect(Rect2(-40, 28, 80, 8), Color.DIM_GRAY)
		draw_rect(Rect2(-40, 28, 80.0 * ratio, 8), cooking.color)
	for i in ready_dishes.size():
		var c: Customer = ready_dishes[i]
		if c.dish_tex != null:
			draw_texture_rect(c.dish_tex, SpriteFactory.rect_centered(c.dish_tex, Vector2(-30 + i * 30, -10)), false)

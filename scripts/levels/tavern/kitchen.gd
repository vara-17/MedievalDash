class_name Kitchen
extends Node2D

# Barra donde se preparan las bebidas, una cada vez. Las listas se quedan
# encima hasta que el tabernero las recoge.

const RECT := Rect2(-50, -40, 100, 80)
const COOK_TIME := 4.0
const BARREL_POS := Vector2(30, -52)
const DISH_POS := Vector2(-30, -42)
const DISH_GAP := 22.0
const PROGRESS_BAR := Rect2(-30, 6, 70, 10)

var pending: Array = []
var ready_dishes: Array = []
var cooking: TavernCustomer = null
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


func add_order(c: TavernCustomer) -> void:
	pending.append(c)


func cancel_orders_of(c: TavernCustomer) -> void:
	pending.erase(c)
	ready_dishes.erase(c)
	if cooking == c:
		cooking = null


func take_ready() -> TavernCustomer:
	if ready_dishes.is_empty():
		return null
	return ready_dishes.pop_front()


func contains_point(p: Vector2) -> bool:
	return RECT.has_point(p - position)


func waiter_position() -> Vector2:
	return position + Vector2(-70, 0)


func _draw() -> void:
	UiDraw.sprite(self, SpriteFactory.make("bar"), Vector2.ZERO)
	UiDraw.sprite(self, SpriteFactory.make("barrel"), BARREL_POS)
	if cooking != null:
		var ratio := 1.0 - cook_timer / COOK_TIME
		UiDraw.progress_bar(self, PROGRESS_BAR, ratio, SpriteFactory.PALETTE["Y"])
		if cooking.dish_tex != null:
			UiDraw.sprite(self, cooking.dish_tex, PROGRESS_BAR.position + Vector2(-12, 3), Color(1, 1, 1, 0.6))
	for i in ready_dishes.size():
		var c: TavernCustomer = ready_dishes[i]
		if c.dish_tex != null:
			UiDraw.sprite(self, c.dish_tex, DISH_POS + Vector2(i * DISH_GAP, 0))

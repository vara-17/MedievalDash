extends Node2D

enum State { WALKING, SEATED, ORDERED, EATING, PAYING }

class Customer:
	var pos: Vector2
	var table_index: int
	var state: int = State.WALKING
	var patience: float = 20.0
	var eat_timer: float = 0.0

const TABLE_SIZE := Vector2(64, 40)
const CUSTOMER_SPEED := 120.0
const DOOR_POS := Vector2(10, 180)
const MAX_PATIENCE := 20.0
const COOK_TIME := 4.0
const EAT_TIME := 3.0
const KITCHEN_RECT := Rect2(520, 140, 100, 80)

var tables: Array[Vector2] = [Vector2(300, 110), Vector2(300, 250)]
var customer: Customer = null
var spawn_timer: float = 1.0
var score: int = 0

var cooking: bool = false
var cook_timer: float = 0.0
var dish_ready: bool = false
var carrying: bool = false


func _process(delta: float) -> void:
	_update_kitchen(delta)
	if customer == null:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_customer()
	else:
		_update_customer(delta)
	queue_redraw()


func _update_kitchen(delta: float) -> void:
	if cooking:
		cook_timer -= delta
		if cook_timer <= 0.0:
			cooking = false
			dish_ready = true


func _spawn_customer() -> void:
	customer = Customer.new()
	customer.pos = DOOR_POS
	customer.table_index = randi() % tables.size()


func _seat_position() -> Vector2:
	return tables[customer.table_index] + Vector2(-56, 0)


func _update_customer(delta: float) -> void:
	match customer.state:
		State.WALKING:
			customer.pos = customer.pos.move_toward(_seat_position(), CUSTOMER_SPEED * delta)
			if customer.pos.is_equal_approx(_seat_position()):
				customer.state = State.SEATED
		State.SEATED, State.ORDERED, State.PAYING:
			customer.patience -= delta
			if customer.patience <= 0.0:
				_customer_leaves(false)
		State.EATING:
			customer.eat_timer -= delta
			if customer.eat_timer <= 0.0:
				customer.state = State.PAYING
				customer.patience = MAX_PATIENCE


func _customer_leaves(paid: bool) -> void:
	if paid:
		score += 10
	else:
		cooking = false
		dish_ready = false
		carrying = false
	customer = null
	spawn_timer = 2.0


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	var p: Vector2 = event.position
	# Recoger plato de la cocina
	if KITCHEN_RECT.has_point(p):
		if dish_ready and not carrying:
			dish_ready = false
			carrying = true
		return
	if customer == null or p.distance_to(customer.pos) > 28.0:
		return
	match customer.state:
		State.SEATED:
			customer.state = State.ORDERED
			customer.patience = MAX_PATIENCE
			cooking = true
			cook_timer = COOK_TIME
		State.ORDERED:
			if carrying:
				carrying = false
				customer.state = State.EATING
				customer.eat_timer = EAT_TIME
		State.PAYING:
			_customer_leaves(true)


func _hint_text() -> String:
	match customer.state:
		State.SEATED:
			return "Toca: tomar nota"
		State.ORDERED:
			if carrying:
				return "Toca: servir"
			if dish_ready:
				return "Recoge el plato"
			return "Cocinando..."
		State.EATING:
			return "Comiendo..."
		State.PAYING:
			return "Toca: cobrar"
	return ""


func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, 640, 360), Color("2b2d42"))
	draw_rect(Rect2(0, 150, 20, 60), Color("8d6e63"))
	for t in tables:
		draw_rect(Rect2(t - TABLE_SIZE / 2.0, TABLE_SIZE), Color("a1887f"))
	# Cocina
	draw_rect(KITCHEN_RECT, Color("546e7a"))
	draw_string(font, KITCHEN_RECT.position + Vector2(24, -6), "Cocina", HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	if cooking:
		var cook_ratio := 1.0 - cook_timer / COOK_TIME
		draw_rect(Rect2(KITCHEN_RECT.position + Vector2(10, 60), Vector2(80, 8)), Color.DIM_GRAY)
		draw_rect(Rect2(KITCHEN_RECT.position + Vector2(10, 60), Vector2(80.0 * cook_ratio, 8)), Color.ORANGE)
	if dish_ready:
		draw_circle(KITCHEN_RECT.position + Vector2(50, 30), 16.0, Color.WHITE)
	# Cliente
	if customer != null:
		draw_circle(customer.pos, 12.0, Color("ffcc80"))
		if customer.state != State.WALKING:
			if customer.state != State.EATING:
				var ratio := customer.patience / MAX_PATIENCE
				var bar_pos := customer.pos + Vector2(-16, -28)
				draw_rect(Rect2(bar_pos, Vector2(32, 4)), Color.DARK_RED)
				draw_rect(Rect2(bar_pos, Vector2(32.0 * ratio, 4)), Color.LIME_GREEN)
			draw_string(font, customer.pos + Vector2(-40, -36), _hint_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	# HUD
	draw_string(font, Vector2(8, 20), "Puntos: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	if carrying:
		draw_circle(Vector2(610, 24), 12.0, Color.WHITE)
		draw_string(font, Vector2(500, 28), "Llevas un plato", HORIZONTAL_ALIGNMENT_LEFT, -1, 12)

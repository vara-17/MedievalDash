extends Node2D

enum State { WALKING, SEATED, ORDERED }

class Customer:
	var pos: Vector2
	var table_index: int
	var state: int = State.WALKING
	var patience: float = 20.0

const TABLE_SIZE := Vector2(64, 40)
const CUSTOMER_SPEED := 120.0
const DOOR_POS := Vector2(10, 180)
const MAX_PATIENCE := 20.0

var tables: Array[Vector2] = [Vector2(300, 110), Vector2(300, 250)]
var customer: Customer = null
var spawn_timer: float = 1.0
var score: int = 0


func _process(delta: float) -> void:
	if customer == null:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_customer()
	else:
		_update_customer(delta)
	queue_redraw()


func _spawn_customer() -> void:
	customer = Customer.new()
	customer.pos = DOOR_POS
	customer.table_index = randi() % tables.size()


func _seat_position() -> Vector2:
	return tables[customer.table_index] + Vector2(-56, 0)


func _update_customer(delta: float) -> void:
	if customer.state == State.WALKING:
		customer.pos = customer.pos.move_toward(_seat_position(), CUSTOMER_SPEED * delta)
		if customer.pos.is_equal_approx(_seat_position()):
			customer.state = State.SEATED
	else:
		customer.patience -= delta
		if customer.patience <= 0.0:
			_customer_leaves(false)


func _customer_leaves(paid: bool) -> void:
	if paid:
		score += 10
	customer = null
	spawn_timer = 2.0


func _input(event: InputEvent) -> void:
	if customer == null:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.position.distance_to(customer.pos) > 28.0:
			return
		if customer.state == State.SEATED:
			customer.state = State.ORDERED
			customer.patience = MAX_PATIENCE
		elif customer.state == State.ORDERED:
			_customer_leaves(true)


func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, 640, 360), Color("2b2d42"))
	draw_rect(Rect2(0, 150, 20, 60), Color("8d6e63"))
	for t in tables:
		draw_rect(Rect2(t - TABLE_SIZE / 2.0, TABLE_SIZE), Color("a1887f"))
	if customer != null:
		draw_circle(customer.pos, 12.0, Color("ffcc80"))
		if customer.state != State.WALKING:
			var ratio := customer.patience / MAX_PATIENCE
			var bar_pos := customer.pos + Vector2(-16, -28)
			draw_rect(Rect2(bar_pos, Vector2(32, 4)), Color.DARK_RED)
			draw_rect(Rect2(bar_pos, Vector2(32.0 * ratio, 4)), Color.LIME_GREEN)
			var hint := "Toca: tomar nota" if customer.state == State.SEATED else "Toca: servir"
			draw_string(font, customer.pos + Vector2(-40, -36), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	draw_string(font, Vector2(8, 20), "Puntos: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

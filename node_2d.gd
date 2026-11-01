extends Node2D

const DOOR_POS := Vector2(10, 180)
const SPAWN_INTERVAL := 5.0
const PAYMENT := 10

var tables: Array[Table] = []
var customers: Array[Customer] = []
var kitchen: Kitchen
var waiter: Waiter
var spawn_timer: float = 1.0
var score: int = 0


func _ready() -> void:
	for y in [80, 180, 280]:
		var t := Table.new()
		t.position = Vector2(260, y)
		add_child(t)
		tables.append(t)
	kitchen = Kitchen.new()
	kitchen.position = Vector2(570, 180)
	add_child(kitchen)
	waiter = Waiter.new()
	waiter.position = Vector2(100, 180)
	add_child(waiter)


func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		var table := _free_table()
		if table != null:
			_spawn_customer(table)
			spawn_timer = SPAWN_INTERVAL
		else:
			spawn_timer = 1.0
	queue_redraw()


func _free_table() -> Table:
	var free: Array[Table] = []
	for t in tables:
		if t.customer == null:
			free.append(t)
	return free.pick_random()


func _spawn_customer(table: Table) -> void:
	var c := Customer.new()
	c.table = table
	c.position = DOOR_POS
	table.customer = c
	c.left.connect(_on_customer_left)
	add_child(c)
	customers.append(c)


func _on_customer_left(c: Customer, paid: bool) -> void:
	if paid:
		score += PAYMENT
	kitchen.cancel_orders_of(c)
	if waiter.carrying == c:
		waiter.carrying = null
	c.table.customer = null
	customers.erase(c)
	c.queue_free()


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	var p: Vector2 = event.position
	if kitchen.contains_point(p):
		waiter.go_to(kitchen.waiter_position(), _pick_up_dish)
		return
	for c in customers:
		if p.distance_to(c.position) <= 30.0:
			waiter.go_to(c.table.waiter_position(), _interact.bind(c))
			return
	waiter.go_to(p, Callable())


func _pick_up_dish() -> void:
	if waiter.carrying == null:
		waiter.carrying = kitchen.take_ready()


func _interact(c: Customer) -> void:
	match c.state:
		Customer.State.SEATED:
			c.take_order()
			kitchen.add_order(c)
		Customer.State.ORDERED:
			if waiter.carrying == c:
				waiter.carrying = null
				c.serve()
		Customer.State.PAYING:
			c.pay()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("2b2d42"))
	draw_rect(Rect2(0, 150, 20, 60), Color("8d6e63"))
	draw_string(ThemeDB.fallback_font, Vector2(8, 20), "Puntos: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

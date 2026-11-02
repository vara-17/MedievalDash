class_name TavernLevel
extends Level

# Nivel de taberna: los clientes entran, esperan en cola, se sientan, piden en
# la barra, comen y pagan. El tabernero va a donde se toca.

const DOOR_POS := Vector2(10, 180)
const DOOR_RECT := Rect2(0, 150, 20, 60)
const QUEUE_SLOTS := [Vector2(60, 110), Vector2(60, 180), Vector2(60, 250)]
const TABLE_ROWS := {2: [120, 240], 3: [80, 180, 280]}
const TABLE_X := 260.0
const KITCHEN_POS := Vector2(570, 180)
const WAITER_START := Vector2(120, 180)
const TAP_RADIUS := 30.0
const PAYMENT := 10

var tables: Array[Table] = []
var queue: Array[Customer] = []
var customers: Array[Customer] = []
var selected: Customer = null
var kitchen: Kitchen
var waiter: Waiter
var spawn_timer: float = 1.0


func _ready() -> void:
	kitchen = Kitchen.new()
	kitchen.position = KITCHEN_POS
	add_child(kitchen)
	waiter = Waiter.new()
	waiter.position = WAITER_START
	add_child(waiter)


func _setup() -> void:
	var rows: Array = TABLE_ROWS.get(int(config["tables"]), TABLE_ROWS[3])
	for y in rows:
		var t := Table.new()
		t.position = Vector2(TABLE_X, y)
		add_child(t)
		tables.append(t)
	spawn_timer = 1.0
	kitchen.visible = true
	waiter.visible = true


func _teardown() -> void:
	for c in customers:
		c.gone = true
		kitchen.cancel_orders_of(c)
		c.queue_free()
	customers.clear()
	queue.clear()
	selected = null
	for t in tables:
		t.queue_free()
	tables.clear()
	waiter.carrying = null
	waiter.position = WAITER_START
	waiter.target = waiter.position
	waiter.on_arrive = Callable()
	kitchen.visible = false
	waiter.visible = false


func _tick(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		if queue.size() < QUEUE_SLOTS.size():
			_spawn_customer()
			spawn_timer = float(config["spawn_interval"])
		else:
			spawn_timer = 1.0
	for i in queue.size():
		queue[i].queue_pos = QUEUE_SLOTS[i]


func _spawn_customer() -> void:
	var c := Customer.new()
	c.position = DOOR_POS
	c.queue_pos = QUEUE_SLOTS[queue.size()]
	var queue_patience := float(config["queue_patience"])
	c.max_patience = queue_patience
	c.patience = queue_patience
	c.table_patience = float(config["table_patience"])
	c.left.connect(_on_customer_left)
	add_child(c)
	queue.append(c)
	customers.append(c)


func _on_customer_left(c: Customer, paid: bool) -> void:
	if paid:
		score += PAYMENT
	kitchen.cancel_orders_of(c)
	if waiter.carrying == c:
		waiter.carrying = null
	if c.table != null:
		c.table.customer = null
	if selected == c:
		selected = null
	queue.erase(c)
	customers.erase(c)
	c.queue_free()


func _on_tap(p: Vector2) -> void:
	if kitchen.contains_point(p):
		waiter.go_to(kitchen.waiter_position(), _pick_up_dish)
		return
	for c in queue:
		if p.distance_to(c.position) <= TAP_RADIUS:
			_select(c)
			return
	if selected != null:
		for t in tables:
			if t.customer == null and _table_rect(t).has_point(p):
				_seat_selected(t)
				return
		_deselect()
	for c in customers:
		if c.state == Customer.State.QUEUED:
			continue
		if p.distance_to(c.position) <= TAP_RADIUS:
			waiter.go_to(c.table.waiter_position(), _interact.bind(c))
			return
	waiter.go_to(p, Callable())


func _table_rect(t: Table) -> Rect2:
	return Rect2(t.position - Table.SIZE / 2.0 - Vector2(12, 12), Table.SIZE + Vector2(24, 24))


func _select(c: Customer) -> void:
	if selected == c:
		_deselect()
		return
	if selected != null:
		selected.selected = false
	selected = c
	c.selected = true


func _deselect() -> void:
	if selected != null:
		selected.selected = false
	selected = null


func _seat_selected(t: Table) -> void:
	var c := selected
	queue.erase(c)
	t.customer = c
	c.table = t
	c.seat_at(t)
	selected = null


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


func _draw_scene() -> void:
	draw_rect(DOOR_RECT, Color("8d6e63"))
	if running and selected != null:
		for t in tables:
			if t.customer == null:
				draw_rect(_table_rect(t), Color.LIME_GREEN, false, 2.0)

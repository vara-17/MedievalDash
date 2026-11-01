extends Node2D

enum Phase { PLAYING, RESULT }

const LEVELS_PATH := "res://data/levels.json"
const DEFAULT_LEVEL := {
	"name": "Nivel de prueba", "time": 60, "tables": 3,
	"spawn_interval": 6, "queue_patience": 25, "table_patience": 20,
	"stars": [20, 40, 60],
}
const DOOR_POS := Vector2(10, 180)
const QUEUE_SLOTS := [Vector2(60, 110), Vector2(60, 180), Vector2(60, 250)]
const TABLE_ROWS := {2: [120, 240], 3: [80, 180, 280]}
const PAYMENT := 10
const BTN_RETRY := Rect2(180, 250, 130, 44)
const BTN_NEXT := Rect2(330, 250, 130, 44)

var levels: Array = []
var level_index: int = 0
var level: Dictionary = {}
var phase: int = Phase.PLAYING
var time_left: float = 0.0
var passed: bool = false
var stars_earned: int = 0

var tables: Array[Table] = []
var queue: Array[Customer] = []
var customers: Array[Customer] = []
var selected: Customer = null
var kitchen: Kitchen
var waiter: Waiter
var spawn_timer: float = 1.0
var score: int = 0


func _ready() -> void:
	_load_levels()
	kitchen = Kitchen.new()
	kitchen.position = Vector2(570, 180)
	add_child(kitchen)
	waiter = Waiter.new()
	add_child(waiter)
	_start_level(0)


func _load_levels() -> void:
	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	if file != null:
		var data = JSON.parse_string(file.get_as_text())
		if data is Array and not data.is_empty():
			levels = data
			return
	push_error("No se pudo leer %s, usando nivel por defecto" % LEVELS_PATH)
	levels = [DEFAULT_LEVEL]


func _start_level(index: int) -> void:
	_clear_level()
	level_index = index
	level = levels[index]
	_build_tables(int(level["tables"]))
	score = 0
	time_left = float(level["time"])
	spawn_timer = 1.0
	kitchen.visible = true
	waiter.visible = true
	phase = Phase.PLAYING


func _clear_level() -> void:
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
	waiter.position = Vector2(120, 180)
	waiter.target = waiter.position
	waiter.on_arrive = Callable()


func _build_tables(count: int) -> void:
	var rows: Array = TABLE_ROWS.get(count, TABLE_ROWS[3])
	for y in rows:
		var t := Table.new()
		t.position = Vector2(260, y)
		add_child(t)
		tables.append(t)


func _finish_level() -> void:
	var thresholds: Array = level["stars"]
	stars_earned = 0
	for t in thresholds:
		if score >= int(t):
			stars_earned += 1
	passed = stars_earned > 0
	_clear_level()
	kitchen.visible = false
	waiter.visible = false
	phase = Phase.RESULT


func _process(delta: float) -> void:
	if phase == Phase.PLAYING:
		time_left -= delta
		if time_left <= 0.0:
			time_left = 0.0
			_finish_level()
			queue_redraw()
			return
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			if queue.size() < QUEUE_SLOTS.size():
				_spawn_customer()
				spawn_timer = float(level["spawn_interval"])
			else:
				spawn_timer = 1.0
		for i in queue.size():
			queue[i].queue_pos = QUEUE_SLOTS[i]
	queue_redraw()


func _spawn_customer() -> void:
	var c := Customer.new()
	c.position = DOOR_POS
	c.queue_pos = QUEUE_SLOTS[queue.size()]
	var queue_patience := float(level["queue_patience"])
	c.max_patience = queue_patience
	c.patience = queue_patience
	c.table_patience = float(level["table_patience"])
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


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	var p: Vector2 = event.position
	if phase == Phase.RESULT:
		_handle_result_tap(p)
		return
	if kitchen.contains_point(p):
		waiter.go_to(kitchen.waiter_position(), _pick_up_dish)
		return
	for c in queue:
		if p.distance_to(c.position) <= 30.0:
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
		if p.distance_to(c.position) <= 30.0:
			waiter.go_to(c.table.waiter_position(), _interact.bind(c))
			return
	waiter.go_to(p, Callable())


func _handle_result_tap(p: Vector2) -> void:
	if BTN_RETRY.has_point(p):
		_start_level(level_index)
	elif passed and BTN_NEXT.has_point(p):
		_start_level((level_index + 1) % levels.size())


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
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, 640, 360), Color("2b2d42"))
	draw_rect(Rect2(0, 150, 20, 60), Color("8d6e63"))
	if phase == Phase.PLAYING and selected != null:
		for t in tables:
			if t.customer == null:
				draw_rect(_table_rect(t), Color.LIME_GREEN, false, 2.0)
	var stars_cfg: Array = level["stars"]
	draw_string(font, Vector2(8, 20), "Nivel %d   Puntos: %d/%d" % [level_index + 1, score, int(stars_cfg[0])], HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(font, Vector2(540, 20), "Tiempo: %d" % ceili(time_left), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	if phase == Phase.RESULT:
		_draw_result(font)


func _draw_result(font: Font) -> void:
	var dark := Color("2b2d42")
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(140, 60, 360, 260), Color("3d405b"))
	var title := "¡Nivel superado!" if passed else "Nivel fallido"
	draw_string(font, Vector2(140, 100), title, HORIZONTAL_ALIGNMENT_CENTER, 360, 24)
	draw_string(font, Vector2(140, 130), str(level["name"]), HORIZONTAL_ALIGNMENT_CENTER, 360, 14)
	draw_string(font, Vector2(140, 162), "Puntos: %d" % score, HORIZONTAL_ALIGNMENT_CENTER, 360, 18)
	for i in 3:
		var pos := Vector2(250 + i * 70, 205)
		if i < stars_earned:
			draw_circle(pos, 20.0, Color.GOLD)
		else:
			draw_arc(pos, 20.0, 0.0, TAU, 24, Color.GRAY, 2.0)
	draw_rect(BTN_RETRY, Color("81b29a"))
	draw_string(font, BTN_RETRY.position + Vector2(0, 28), "Reintentar", HORIZONTAL_ALIGNMENT_CENTER, BTN_RETRY.size.x, 16, dark)
	if passed:
		draw_rect(BTN_NEXT, Color("f2cc8f"))
		var label := "Siguiente" if level_index + 1 < levels.size() else "Al inicio"
		draw_string(font, BTN_NEXT.position + Vector2(0, 28), label, HORIZONTAL_ALIGNMENT_CENTER, BTN_NEXT.size.x, 16, dark)

class_name ArmoryLevel
extends Level

# Nivel de armería: los clientes esperan en cola y se les lleva a un mostrador.
# Si quieren comprar, el herrero coge el objeto del estante y se lo da.
# Si quieren reparar, el herrero recoge el objeto roto, lo lleva al yunque,
# lo recoge arreglado y se lo devuelve. Cobra según los precios del escenario.

const DOOR_POS := Vector2(10, 180)
const DOOR_RECT := Rect2(0, 150, 20, 60)
const QUEUE_SLOTS := [Vector2(60, 110), Vector2(60, 180), Vector2(60, 250)]
const COUNTER_ROWS := {2: [140, 260], 3: [110, 200, 290]}
const COUNTER_X := 252.0
const RACK_X := 590.0
const RACK_ROWS := [95, 185, 275]
const ANVIL_POS := Vector2(430, 120)
const SMITH_START := Vector2(330, 200)
const TAP_RADIUS := 30.0

var counters: Array[Counter] = []
var racks: Array[Rack] = []
var queue: Array[ArmoryCustomer] = []
var customers: Array[ArmoryCustomer] = []
var selected: ArmoryCustomer = null
var anvil: Anvil
var smith: Smith
var spawn_timer: float = 1.0


func _ready() -> void:
	anvil = Anvil.new()
	anvil.position = ANVIL_POS
	add_child(anvil)
	smith = Smith.new()
	smith.position = SMITH_START
	add_child(smith)


func _setup() -> void:
	var rows: Array = COUNTER_ROWS.get(int(config["counters"]), COUNTER_ROWS[3])
	for y in rows:
		var c := Counter.new()
		c.position = Vector2(COUNTER_X, y)
		add_child(c)
		counters.append(c)
	var items: Array = config["items"]
	for i in mini(items.size(), RACK_ROWS.size()):
		var r := Rack.new()
		r.item = str(items[i])
		r.item_name = str(venue["items"][r.item]["name"])
		r.position = Vector2(RACK_X, RACK_ROWS[i])
		add_child(r)
		racks.append(r)
	anvil.repair_time = float(config["repair_time"])
	spawn_timer = 1.0
	anvil.visible = true
	smith.visible = true


func _teardown() -> void:
	for c in customers:
		c.gone = true
		anvil.cancel_repairs_of(c)
		c.queue_free()
	customers.clear()
	queue.clear()
	selected = null
	for c in counters:
		c.queue_free()
	for r in racks:
		r.queue_free()
	counters.clear()
	racks.clear()
	smith.drop()
	smith.position = SMITH_START
	smith.target = smith.position
	smith.on_arrive = Callable()
	anvil.visible = false
	smith.visible = false


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
	var c := ArmoryCustomer.new()
	var items: Array = config["items"]
	c.item = str(items.pick_random())
	c.repair = randf() < float(config["repair_chance"])
	c.position = DOOR_POS
	c.queue_pos = QUEUE_SLOTS[queue.size()]
	var queue_patience := float(config["queue_patience"])
	c.max_patience = queue_patience
	c.patience = queue_patience
	c.counter_patience = float(config["counter_patience"])
	c.left.connect(_on_customer_left)
	add_child(c)
	queue.append(c)
	customers.append(c)


func _on_customer_left(c: ArmoryCustomer) -> void:
	anvil.cancel_repairs_of(c)
	if smith.carry_owner == c:
		smith.drop()
	if c.counter != null:
		c.counter.customer = null
	if selected == c:
		selected = null
	queue.erase(c)
	customers.erase(c)
	c.queue_free()


func _price(c: ArmoryCustomer) -> int:
	return int(venue["items"][c.item]["repair" if c.repair else "buy"])


func _on_tap(p: Vector2) -> void:
	for r in racks:
		if r.contains_point(p):
			smith.go_to(r.smith_position(), _take_from_rack.bind(r))
			return
	if anvil.contains_point(p):
		smith.go_to(anvil.smith_position(), _use_anvil)
		return
	for c in queue:
		if p.distance_to(c.position) <= TAP_RADIUS:
			_select(c)
			return
	if selected != null:
		for counter in counters:
			if counter.customer == null and _counter_rect(counter).has_point(p):
				_send_to_counter(counter)
				return
		_deselect()
	for c in customers:
		if c.state == ArmoryCustomer.State.QUEUED:
			continue
		if p.distance_to(c.position) <= TAP_RADIUS or _counter_rect(c.counter).has_point(p):
			smith.go_to(c.counter.smith_position(), _serve.bind(c))
			return
	smith.go_to(p, Callable())


func _counter_rect(c: Counter) -> Rect2:
	return Rect2(c.position - Counter.SIZE / 2.0 - Vector2(12, 12), Counter.SIZE + Vector2(24, 24))


func _select(c: ArmoryCustomer) -> void:
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


func _send_to_counter(counter: Counter) -> void:
	var c := selected
	queue.erase(c)
	counter.customer = c
	c.go_to_counter(counter)
	selected = null


# Coge un objeto nuevo del estante. Si ya llevaba otro nuevo, lo cambia;
# si lleva el de un cliente, no lo suelta.
func _take_from_rack(r: Rack) -> void:
	if smith.carry_owner == null:
		smith.carry(r.item, null, false)


# Deja en el yunque el objeto roto que lleva, o recoge uno ya arreglado.
func _use_anvil() -> void:
	if smith.carry_owner != null and smith.carry_broken:
		anvil.add_repair(smith.carry_owner)
		smith.drop()
	elif smith.is_empty_handed():
		var c := anvil.take_ready()
		if c != null:
			smith.carry(c.item, c, false)


func _serve(c: ArmoryCustomer) -> void:
	if c.gone:
		return
	match c.state:
		ArmoryCustomer.State.WAITING:
			if c.repair:
				if smith.is_empty_handed():
					smith.carry(c.item, c, true)
					c.hand_over()
			elif smith.carry_owner == null and smith.carry_item == c.item:
				_pay(c)
		ArmoryCustomer.State.REPAIRING:
			if smith.carry_owner == c and not smith.carry_broken:
				_pay(c)


func _pay(c: ArmoryCustomer) -> void:
	smith.drop()
	score += _price(c)
	c.receive()


func _draw_scene() -> void:
	draw_rect(DOOR_RECT, Color("8d6e63"))
	if running and selected != null:
		for c in counters:
			if c.customer == null:
				draw_rect(_counter_rect(c), Color.LIME_GREEN, false, 2.0)

class_name ServiceLevel
extends Level

# Nivel de atender clientes: llegan por la puerta, esperan en cola, se les
# lleva a un sitio libre (Spot) y quien atiende (Staff) va a servirles.
# Los clientes de cada nivel son fijos: "customers" en venues.json dice cuándo
# llega cada uno ("at", en segundos), qué pide y cuántos son ("party", 1 por
# defecto). Si la cola está llena, el
# siguiente espera a que haya hueco. El nivel acaba cuando se han ido todos.
# Aquí va lo común a la taberna, la armería...; cada subclase crea sus sitios,
# sus clientes y sus puestos (barra, estantes, yunque) y decide cómo se sirve.

const DOOR_POS := Vector2(10, 180)
const DOOR_CENTER := Vector2(16, 180)
const QUEUE_SLOTS := [Vector2(60, 110), Vector2(60, 180), Vector2(60, 250)]
const STAFF_START := Vector2(120, 180)
const TAP_RADIUS := 30.0
# Botón del marcador para cancelar todas las acciones pendientes.
const BTN_CANCEL := Rect2(375, 6, 110, 28)
# Separación de tono entre clientes seguidos, para que cada uno tenga su color.
const HUE_STEP := 0.618

var spots: Array[Spot] = []
var queue: Array[ServiceCustomer] = []
var customers: Array[ServiceCustomer] = []
var selected: ServiceCustomer = null
var staff: Staff
# Clientes del nivel que aún no han entrado, en orden de llegada.
var pending: Array = []
var spawned: int = 0
var elapsed: float = 0.0


func _ready() -> void:
	staff = _create_staff()
	staff.position = _staff_start()
	add_child(staff)
	_create_stations()


func _setup() -> void:
	for s in _create_spots():
		add_child(s)
		spots.append(s)
	pending = config["customers"].duplicate()
	pending.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["at"]) < float(b["at"]))
	spawned = 0
	elapsed = 0.0
	_setup_stations()


func _teardown() -> void:
	for c in customers:
		c.gone = true
		_forget_customer(c)
		c.queue_free()
	customers.clear()
	queue.clear()
	selected = null
	for s in spots:
		s.queue_free()
	spots.clear()
	staff.reset(_staff_start())
	_teardown_stations()


func _tick(delta: float) -> void:
	elapsed += delta
	while not pending.is_empty() and float(pending[0]["at"]) <= elapsed and queue.size() < QUEUE_SLOTS.size():
		_spawn_customer(pending.pop_front())
	for i in queue.size():
		queue[i].queue_pos = QUEUE_SLOTS[i]


func _spawn_customer(data: Dictionary) -> void:
	var c := _create_customer(data)
	c.party = int(data.get("party", 1))
	c.color = Color.from_hsv(fmod(spawned * HUE_STEP, 1.0), 0.5, 1.0)
	spawned += 1
	c.position = DOOR_POS
	c.queue_pos = QUEUE_SLOTS[queue.size()]
	var queue_patience := float(config["queue_patience"])
	c.max_patience = queue_patience
	c.patience = queue_patience
	c.left.connect(_on_customer_left)
	add_child(c)
	queue.append(c)
	customers.append(c)


func _on_customer_left(c: ServiceCustomer, paid: bool) -> void:
	staff.cancel_actions_about(c)
	_forget_customer(c)
	_on_customer_gone(c, paid)
	if c.spot != null:
		c.spot.customer = null
	if selected == c:
		selected = null
	queue.erase(c)
	customers.erase(c)
	c.queue_free()
	if pending.is_empty() and customers.is_empty():
		end_level.call_deferred()


func _on_tap(p: Vector2) -> void:
	if BTN_CANCEL.has_point(p):
		staff.clear_actions()
		_deselect()
		return
	if _tap_station(p):
		return
	for c in queue:
		if p.distance_to(c.position) <= TAP_RADIUS:
			if _can_select(c):
				_select(c)
			return
	if selected != null:
		for s in spots:
			if s.accepts(selected) and s.tap_rect().has_point(p):
				_send_selected_to(s)
				return
		_deselect()
	for c in customers:
		if c.state == ServiceCustomer.State.QUEUED:
			continue
		if p.distance_to(c.position) <= TAP_RADIUS or c.spot.tap_rect().has_point(p):
			staff.add_action(c.spot.staff_position(), _try_serve.bind(c), c)
			return
	staff.add_action(p)


# Al llegar al sitio del cliente: si sigue ahí, la subclase decide qué hacer.
func _try_serve(c: ServiceCustomer) -> void:
	if is_instance_valid(c) and not c.gone:
		_serve(c)


func _select(c: ServiceCustomer) -> void:
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


func _send_selected_to(s: Spot) -> void:
	var c := selected
	queue.erase(c)
	s.customer = c
	c.go_to_spot(s)
	selected = null


func _draw_scene() -> void:
	UiDraw.sprite(self, SpriteFactory.make("door"), DOOR_CENTER)
	if running:
		UiDraw.wood_button(self, BTN_CANCEL, "Cancelar")
	if running and selected != null:
		for s in spots:
			if s.accepts(selected):
				draw_rect(s.tap_rect(), SpriteFactory.PALETTE["N"], false, 2.0)


# --- Para las subclases ---

func _create_staff() -> Staff:
	return Staff.new()


func _staff_start() -> Vector2:
	return STAFF_START


# Puestos fijos del local (barra, yunque...), creados una vez.
func _create_stations() -> void:
	pass


# Sitios (mesas, mostradores...) para este nivel, según config.
func _create_spots() -> Array[Spot]:
	return []


# Ajusta los puestos al nivel, al empezar.
func _setup_stations() -> void:
	pass


# Quita lo que _setup_stations haya creado, al acabar.
func _teardown_stations() -> void:
	pass


# Cliente nuevo a partir de su entrada en "customers" (qué pide, etc.).
func _create_customer(_data: Dictionary) -> ServiceCustomer:
	return ServiceCustomer.new()


# Si se puede elegir a este cliente de la cola para llevarlo a un sitio.
func _can_select(_c: ServiceCustomer) -> bool:
	return true


# Si el toque es sobre un puesto, añade la acción de ir allí y devuelve true.
func _tap_station(_p: Vector2) -> bool:
	return false


# Quien atiende ha llegado al sitio del cliente; si no hay nada que hacer, no hace nada.
func _serve(_c: ServiceCustomer) -> void:
	pass


# El cliente se va (o se acaba el nivel): borra sus pedidos y lo que se lleve para él.
func _forget_customer(_c: ServiceCustomer) -> void:
	pass


# El cliente se ha ido; "paid" indica si pagó.
func _on_customer_gone(_c: ServiceCustomer, _paid: bool) -> void:
	pass

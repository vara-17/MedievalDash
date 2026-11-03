class_name InfirmaryLevel
extends ServiceLevel

# Nivel de enfermería: la cola acaba en un mostrador y solo se atiende al
# primero. Si viene a comprar, la curandera coge su medicina del estante y se
# la entrega en el mostrador (paga y se va). Si viene a curarse, se le lleva a
# una camilla libre; allí se le da su medicina, se recupera y se le cobra.
# Precios por medicina ("buy" al comprar, "treat" al curarse) en el escenario.

const DESK_POS := Vector2(110, 110)
const HEALER_START := Vector2(200, 200)
const SHELF_X := 580.0
const SHELF_ROWS := [95, 185, 275]
# Posición de las camillas según cuántas hay.
const STRETCHER_LAYOUTS := {
	1: [Vector2(320, 200)],
	2: [Vector2(300, 140), Vector2(300, 270)],
	3: [Vector2(270, 140), Vector2(270, 270), Vector2(420, 200)],
	4: [Vector2(270, 140), Vector2(270, 270), Vector2(420, 140), Vector2(420, 270)],
}

var desk: FrontDesk
var shelves: Array[Rack] = []


func _create_staff() -> Staff:
	return Healer.new()


func _staff_start() -> Vector2:
	return HEALER_START


func _create_stations() -> void:
	desk = FrontDesk.new()
	desk.position = DESK_POS
	add_child(desk)


func _create_spots() -> Array[Spot]:
	var result: Array[Spot] = []
	var count := clampi(int(config["stretchers"]), 1, STRETCHER_LAYOUTS.size())
	for pos in STRETCHER_LAYOUTS[count]:
		var s := Stretcher.new()
		s.position = pos
		result.append(s)
	return result


# Medicinas del nivel: las que pide algún cliente, en orden de aparición.
func _medicines() -> Array:
	var items: Array = []
	for data in config["customers"]:
		var item := str(data["item"])
		if not items.has(item):
			items.append(item)
	return items


func _setup_stations() -> void:
	var items := _medicines()
	for i in mini(items.size(), SHELF_ROWS.size()):
		var r := Rack.new()
		r.item = str(items[i])
		r.item_name = str(venue["items"][r.item]["name"])
		r.position = Vector2(SHELF_X, SHELF_ROWS[i])
		add_child(r)
		shelves.append(r)


func _teardown_stations() -> void:
	for r in shelves:
		r.queue_free()
	shelves.clear()


func _create_customer(data: Dictionary) -> ServiceCustomer:
	var c := InfirmaryCustomer.new()
	c.item = str(data["item"])
	c.treat = bool(data.get("treat", false))
	c.recover_time = float(config["recover_time"])
	c.spot_patience = float(config["stretcher_patience"])
	return c


func _tick(delta: float) -> void:
	super(delta)
	if queue.is_empty():
		return
	var front := queue[0] as InfirmaryCustomer
	if not front.at_desk and front.position.is_equal_approx(front.queue_pos):
		front.reach_desk(float(config["desk_patience"]))


# El que está en el mostrador, si ya ha llegado.
func _at_desk() -> InfirmaryCustomer:
	if queue.is_empty():
		return null
	var front := queue[0] as InfirmaryCustomer
	return front if front.at_desk else null


# Solo se puede llevar a una camilla al que está en el mostrador y viene a curarse.
func _can_select(c: ServiceCustomer) -> bool:
	return c == _at_desk() and (c as InfirmaryCustomer).treat


func _tap_station(p: Vector2) -> bool:
	for r in shelves:
		if r.contains_point(p):
			staff.add_action(r.staff_position(), _take_from_shelf.bind(r))
			return true
	var front := _at_desk()
	var on_buyer := front != null and not front.treat and p.distance_to(front.position) <= TAP_RADIUS
	if desk.contains_point(p) or on_buyer:
		staff.add_action(desk.staff_position(), _serve_desk)
		return true
	return false


func _take_from_shelf(r: Rack) -> void:
	(staff as Healer).carrying = r.item


# En el mostrador: si el primero viene a comprar y se lleva su medicina, paga y se va.
func _serve_desk() -> void:
	var front := _at_desk()
	var healer := staff as Healer
	if front != null and not front.treat and healer.carrying == front.item:
		healer.carrying = ""
		front.pay()


# En la camilla: darle su medicina o cobrarle.
func _serve(c: ServiceCustomer) -> void:
	var ic := c as InfirmaryCustomer
	var healer := staff as Healer
	if ic.is_waiting_medicine() and healer.carrying == ic.item:
		healer.carrying = ""
		ic.give_medicine()
	elif ic.is_paying():
		ic.pay()


func _on_customer_gone(c: ServiceCustomer, paid: bool) -> void:
	if paid:
		var ic := c as InfirmaryCustomer
		score += int(venue["items"][ic.item]["treat" if ic.treat else "buy"])

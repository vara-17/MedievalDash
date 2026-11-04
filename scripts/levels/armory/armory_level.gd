class_name ArmoryLevel
extends ServiceLevel

# Nivel de armería: los clientes van a un mostrador.
# Si quieren comprar, el herrero coge el objeto del estante y se lo da.
# Si quieren reparar, el herrero recoge el objeto roto, lo lleva al yunque,
# lo recoge arreglado y se lo devuelve. Cobra según los precios del escenario.

const COUNTER_ROWS := {2: [140, 260], 3: [110, 200, 290], 4: [75, 155, 235, 315]}
const COUNTER_X := 252.0
const RACK_X := 590.0
const RACK_ROWS := [95, 185, 275]
const ANVIL_POS := Vector2(430, 120)
const SMITH_START := Vector2(330, 200)

var racks: Array[Rack] = []
var anvil: Anvil


func _create_staff() -> Staff:
	return Smith.new()


func _staff_start() -> Vector2:
	return SMITH_START


func _create_stations() -> void:
	anvil = Anvil.new()
	anvil.position = ANVIL_POS
	add_child(anvil)


func _create_spots() -> Array[Spot]:
	var result: Array[Spot] = []
	for y in COUNTER_ROWS.get(int(config["counters"]), COUNTER_ROWS[3]):
		var c := Counter.new()
		c.position = Vector2(COUNTER_X, y)
		result.append(c)
	return result


# Objetos a la venta en este nivel: los que algún cliente viene a comprar,
# en orden de aparición.
func _items_for_sale() -> Array:
	var items: Array = []
	for data in config["customers"]:
		var item := str(data["item"])
		if not data.get("repair", false) and not items.has(item):
			items.append(item)
	return items


func _setup_stations() -> void:
	var items := _items_for_sale()
	for i in mini(items.size(), RACK_ROWS.size()):
		var r := Rack.new()
		r.item = str(items[i])
		r.item_name = str(venue["items"][r.item]["name"])
		r.position = Vector2(RACK_X, RACK_ROWS[i])
		add_child(r)
		racks.append(r)
	anvil.repair_time = float(config["repair_time"])


func _teardown_stations() -> void:
	for r in racks:
		r.queue_free()
	racks.clear()


func _create_customer(data: Dictionary) -> ServiceCustomer:
	var c := ArmoryCustomer.new()
	c.item = str(data["item"])
	c.repair = bool(data.get("repair", false))
	c.spot_patience = float(config["counter_patience"])
	return c


func _tap_station(p: Vector2) -> bool:
	for r in racks:
		if r.contains_point(p):
			staff.add_action(r.staff_position(), _take_from_rack.bind(r))
			return true
	if anvil.contains_point(p):
		staff.add_action(anvil.smith_position(), _use_anvil)
		return true
	return false


# Coge un objeto nuevo del estante. Si ya llevaba otro nuevo, lo cambia;
# si lleva el de un cliente, no lo suelta.
func _take_from_rack(r: Rack) -> void:
	var smith := staff as Smith
	if smith.carry_owner == null:
		smith.carry(r.item, null, false)


# Deja en el yunque el objeto roto que lleva, o recoge uno ya arreglado.
# Un objeto nuevo del estante se desecha aquí siempre.
func _use_anvil() -> void:
	var smith := staff as Smith
	if smith.carry_owner != null and smith.carry_broken:
		anvil.add_repair(smith.carry_owner)
		smith.carry("", null, false)
	elif _free_hands() and not anvil.ready_items.is_empty():
		var c := anvil.take_ready()
		smith.carry(c.item, c, false)


# Deja las manos libres si hace falta: un objeto nuevo del estante se devuelve
# solo; el de un cliente (roto o arreglado) no se suelta nunca.
func _free_hands() -> bool:
	var smith := staff as Smith
	if smith.carry_owner == null:
		smith.carry("", null, false)
	return smith.is_empty_handed()


func _serve(c: ServiceCustomer) -> void:
	var ac := c as ArmoryCustomer
	var smith := staff as Smith
	match ac.step:
		ArmoryCustomer.Step.WAITING:
			if ac.repair:
				if _free_hands():
					smith.carry(ac.item, ac, true)
					ac.hand_over()
			elif smith.carry_owner == null and smith.carry_item == ac.item:
				_charge(ac)
		ArmoryCustomer.Step.REPAIRING:
			if smith.carry_owner == ac and not smith.carry_broken:
				_charge(ac)


func _charge(c: ArmoryCustomer) -> void:
	(staff as Smith).carry("", null, false)
	score += int(venue["items"][c.item]["repair" if c.repair else "buy"])
	c.receive()


func _forget_customer(c: ServiceCustomer) -> void:
	var ac := c as ArmoryCustomer
	anvil.cancel_repairs_of(ac)
	var smith := staff as Smith
	if smith.carry_owner == ac:
		smith.carry("", null, false)

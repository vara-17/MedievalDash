class_name TavernLevel
extends ServiceLevel

# Nivel de taberna: los clientes se sientan a una mesa, el tabernero les toma
# nota, recoge la bebida en la barra, se la sirve y les cobra.

# Posición de las mesas según cuántas hay.
const TABLE_LAYOUTS := {
	2: [Vector2(260, 120), Vector2(260, 240)],
	3: [Vector2(260, 80), Vector2(260, 180), Vector2(260, 280)],
	4: [Vector2(230, 110), Vector2(230, 250), Vector2(400, 110), Vector2(400, 250)],
}
const KITCHEN_POS := Vector2(570, 180)
const PAYMENT := 10

var kitchen: Kitchen


func _create_staff() -> Staff:
	return Waiter.new()


func _create_stations() -> void:
	kitchen = Kitchen.new()
	kitchen.position = KITCHEN_POS
	add_child(kitchen)


func _create_spots() -> Array[Spot]:
	var result: Array[Spot] = []
	for pos in TABLE_LAYOUTS.get(int(config["tables"]), TABLE_LAYOUTS[3]):
		var t := Table.new()
		t.position = pos
		result.append(t)
	return result


func _create_customer(_data: Dictionary) -> ServiceCustomer:
	var c := TavernCustomer.new()
	c.spot_patience = float(config["table_patience"])
	return c


func _tap_station(p: Vector2) -> bool:
	if kitchen.contains_point(p):
		staff.add_action(kitchen.waiter_position(), _pick_up_dish)
		return true
	return false


func _pick_up_dish() -> void:
	var waiter := staff as Waiter
	if waiter.carrying == null:
		waiter.carrying = kitchen.take_ready()


func _serve(c: ServiceCustomer) -> void:
	var tc := c as TavernCustomer
	var waiter := staff as Waiter
	match tc.step:
		TavernCustomer.Step.SEATED:
			tc.take_order()
			kitchen.add_order(tc)
		TavernCustomer.Step.ORDERED:
			if waiter.carrying == tc:
				waiter.carrying = null
				tc.serve()
		TavernCustomer.Step.PAYING:
			tc.pay()


func _forget_customer(c: ServiceCustomer) -> void:
	var tc := c as TavernCustomer
	kitchen.cancel_orders_of(tc)
	var waiter := staff as Waiter
	if waiter.carrying == tc:
		waiter.carrying = null


func _on_customer_gone(_c: ServiceCustomer, paid: bool) -> void:
	if paid:
		score += PAYMENT

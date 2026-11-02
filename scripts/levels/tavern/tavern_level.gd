class_name TavernLevel
extends ServiceLevel

# Nivel de taberna: los clientes se sientan a una mesa, el tabernero les toma
# nota, recoge la bebida en la barra, se la sirve y les cobra.

const TABLE_ROWS := {2: [120, 240], 3: [80, 180, 280]}
const TABLE_X := 260.0
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
	for y in TABLE_ROWS.get(int(config["tables"]), TABLE_ROWS[3]):
		var t := Table.new()
		t.position = Vector2(TABLE_X, y)
		result.append(t)
	return result


func _create_customer() -> ServiceCustomer:
	var c := TavernCustomer.new()
	c.spot_patience = float(config["table_patience"])
	return c


func _tap_station(p: Vector2) -> bool:
	if kitchen.contains_point(p):
		staff.go_to(kitchen.waiter_position(), _pick_up_dish)
		return true
	return false


func _pick_up_dish() -> void:
	var waiter := staff as Waiter
	if waiter.carrying == null:
		waiter.carrying = kitchen.take_ready()


func _serve(c: ServiceCustomer) -> void:
	var tc := c as TavernCustomer
	var waiter := staff as Waiter
	if tc.gone:
		return
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

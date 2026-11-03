class_name InnLevel
extends ServiceLevel

# Nivel de posada: se lleva a cada huésped a una cama libre y hecha, duerme,
# al despertarse hay que cobrarle y después hacer la cama para el siguiente.
# "beds" en el nivel es la capacidad de cada cama (1 individual, 2 doble).

# Posición de las camas según cuántas hay.
const BED_LAYOUTS := {
	1: [Vector2(260, 190)],
	2: [Vector2(260, 130), Vector2(260, 250)],
	3: [Vector2(260, 100), Vector2(260, 190), Vector2(260, 280)],
	4: [Vector2(240, 130), Vector2(240, 250), Vector2(440, 130), Vector2(440, 250)],
	5: [Vector2(240, 100), Vector2(240, 190), Vector2(240, 280), Vector2(440, 130), Vector2(440, 250)],
	6: [Vector2(240, 100), Vector2(240, 190), Vector2(240, 280), Vector2(440, 100), Vector2(440, 190), Vector2(440, 280)],
}


func _create_staff() -> Staff:
	return Innkeeper.new()


func _create_spots() -> Array[Spot]:
	var result: Array[Spot] = []
	var capacities: Array = config["beds"]
	var layout: Array = BED_LAYOUTS[clampi(capacities.size(), 1, BED_LAYOUTS.size())]
	for i in mini(capacities.size(), layout.size()):
		var b := Bed.new(int(capacities[i]))
		b.position = layout[i]
		result.append(b)
	return result


func _create_customer(data: Dictionary) -> ServiceCustomer:
	var g := InnGuest.new()
	g.sleep_time = float(data.get("sleep", config["sleep_time"]))
	g.spot_patience = float(config["pay_patience"])
	return g


# Tocar una cama encola "cobrar o hacer la cama", salvo si se está eligiendo
# cama para un huésped y esa le vale.
func _tap_station(p: Vector2) -> bool:
	for s in spots:
		if not s.tap_rect().has_point(p):
			continue
		if selected != null and s.accepts(selected):
			return false
		staff.add_action(s.staff_position(), _use_bed.bind(s))
		return true
	return false


func _serve(c: ServiceCustomer) -> void:
	_use_bed(c.spot as Bed)


# Al llegar a la cama: cobra si el huésped está despierto; si se ha ido y está
# deshecha, la hace.
func _use_bed(b: Bed) -> void:
	var g := b.customer as InnGuest
	if g != null:
		if g.is_paying():
			g.pay()
	elif not b.made:
		staff.work(float(config["make_time"]), b.make)


func _on_customer_gone(c: ServiceCustomer, paid: bool) -> void:
	if paid:
		score += int(venue["price"]) * c.party

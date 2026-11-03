extends SceneTree

# Mide la dificultad de los niveles de data/venues.json con un jugador
# automático sencillo: sienta en cuanto hay sitio y da una orden cada vez,
# solo cuando el personaje está quieto (no encadena acciones como una persona).
# Juega todos los niveles dos veces: reaccionando al instante y con 0,9 s de
# reacción (jugador lento). Si el lento saca 3 estrellas, el nivel es fácil.
#
# Uso (desde la carpeta del proyecto, con ventana; tarda un par de minutos):
#   /Applications/Godot.app/Contents/MacOS/Godot --path . -s tools/balance_levels.gd
var main
# Segundos de reacción tras quedarse quieto el personaje (0 = inmediato).
var reaction := 0.0
var idle_since := -1.0

func _initialize() -> void:
	_run()

func _tap(p: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.pressed = true
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = p
	main._input(ev)

func _run() -> void:
	main = load("res://scenes/node_2d.tscn").instantiate()
	root.add_child(main)
	for i in 3:
		await process_frame
	var s := SaveData.new()
	s.path = "user://balance_save.json"
	s.progress = {}
	main.save = s
	Engine.time_scale = 6.0
	for r in [0.0, 0.9]:
		reaction = r
		print("--- reacción %.1fs ---" % r)
		await _play_all()
	quit()

func _play_all() -> void:
	for v in main.venues.size():
		var venue: Dictionary = main.venues[v]
		for li in venue["levels"].size():
			main.venue = venue
			main._start_level(li)
			idle_since = -1.0
			var possible := 0
			for d in venue["levels"][li]["customers"]:
				if venue["id"] == "taberna":
					possible += 10
				elif venue.has("price"):
					possible += int(venue["price"]) * int(d.get("party", 1))
				else:
					possible += int(venue["items"][d["item"]]["repair" if d.get("repair", false) else "buy"])
			while main.phase == main.Phase.PLAYING:
				_bot_step(main.level)
				await process_frame
			var lv = main.level
			var cfg: Dictionary = venue["levels"][li]
			print("%s %d '%s': monedas %d/%d  estrellas %d  umbrales %s  tiempo sobrante %.1fs de %d" % [
				venue["id"], li + 1, cfg["name"], lv.score, possible, Level.count_stars(cfg, lv.score),
				str(cfg["stars"]), lv.time_left, int(cfg["time"])])

func _bot_step(lv) -> void:
	# Sentar: en cuanto hay sitio libre
	if not lv.queue.is_empty():
		for sp in lv.spots:
			if sp.accepts(lv.queue[0]):
				_tap(lv.queue[0].position)
				_tap(sp.position)
				break
	if not lv.staff.actions.is_empty() or lv.staff.work_left > 0.0:
		idle_since = -1.0
		return
	if idle_since < 0.0:
		idle_since = lv.elapsed
	if lv.elapsed - idle_since < reaction:
		return
	idle_since = -1.0
	if lv is TavernLevel:
		_tavern(lv)
	elif lv is InnLevel:
		_inn(lv)
	else:
		_armory(lv)

func _at_spot(lv) -> Array:
	return lv.customers.filter(func(c): return c.state == ServiceCustomer.State.AT_SPOT)

func _tavern(lv) -> void:
	var w = lv.staff
	if w.carrying != null and is_instance_valid(w.carrying):
		_tap(w.carrying.spot.position); return
	for c in _at_spot(lv):
		if c.step == TavernCustomer.Step.PAYING:
			_tap(c.spot.position); return
	for c in _at_spot(lv):
		if c.step == TavernCustomer.Step.SEATED:
			_tap(c.spot.position); return
	if not lv.kitchen.ready_dishes.is_empty():
		_tap(lv.kitchen.position)

func _armory(lv) -> void:
	var sm = lv.staff
	if sm.carry_owner != null and is_instance_valid(sm.carry_owner):
		_tap(sm.carry_owner.spot.position if not sm.carry_broken else lv.anvil.position); return
	var waiting := _at_spot(lv).filter(func(c): return c.step == ArmoryCustomer.Step.WAITING)
	if sm.carry_item != "":
		for c in waiting:
			if not c.repair and c.item == sm.carry_item:
				_tap(c.spot.position); return
		_tap(lv.anvil.position); return
	if not lv.anvil.ready_items.is_empty():
		_tap(lv.anvil.position); return
	for c in waiting:
		if c.repair:
			_tap(c.spot.position); return
	for c in waiting:
		for r in lv.racks:
			if r.item == c.item:
				_tap(r.position); return

func _inn(lv) -> void:
	for c in _at_spot(lv):
		if c.is_paying():
			_tap(c.spot.position); return
	for sp in lv.spots:
		if sp.customer == null and not sp.made:
			_tap(sp.position); return

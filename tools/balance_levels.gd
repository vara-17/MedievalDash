extends SceneTree

# Mide la dificultad de los niveles de data/venues.json con un jugador
# automático sencillo: sienta en cuanto hay sitio y da una orden cada vez,
# solo cuando el personaje está quieto (no encadena acciones como una persona).
# Juega cada nivel dos veces: reaccionando al instante ("perfecto") y con 0,9 s
# de reacción (jugador lento).
#
# Objetivo por dificultad ("difficulty" del nivel): tiempo que debe sobrar al
# jugador perfecto y duración del nivel.
#   easy 25% (1-2 min), medium 15% (1-3 min), hard 10% (2-4 min), extreme 5% (3-5 min)
#
# Uso (desde la carpeta del proyecto, sin ventana; --fixed-fps hace que cada
# fotograma cuente 1/60 s aunque se calcule más rápido):
#   /Applications/Godot.app/Contents/MacOS/Godot --headless --fixed-fps 60 --path . -s tools/balance_levels.gd
# Opciones (después de "--"):
#   --venue=taberna   solo ese escenario
#   --level=4         solo ese nivel (1, 2...)
#   --fast            solo el jugador perfecto
#   --open            sin límite de tiempo, para medir cuánto tarda el perfecto
const TARGETS := {
	"easy": [0.25, 60, 120],
	"medium": [0.15, 60, 180],
	"hard": [0.10, 120, 240],
	"extreme": [0.05, 180, 300],
}
const OPEN_TIME := 999

var main
# Segundos de reacción tras quedarse quieto el personaje (0 = inmediato).
var reaction := 0.0
var idle_since := -1.0
var only_venue := ""
var only_level := 0
var open_time := false

func _initialize() -> void:
	_run()

func _tap(p: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.pressed = true
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = p
	main._input(ev)

func _run() -> void:
	var reactions := [0.0, 0.9]
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--venue="):
			only_venue = arg.get_slice("=", 1)
		elif arg.begins_with("--level="):
			only_level = int(arg.get_slice("=", 1))
		elif arg == "--fast":
			reactions = [0.0]
		elif arg == "--open":
			open_time = true
	main = load("res://scenes/node_2d.tscn").instantiate()
	root.add_child(main)
	for i in 3:
		await process_frame
	var s := SaveData.new()
	s.path = "user://balance_save.json"
	s.progress = {}
	main.save = s
	for r in reactions:
		reaction = r
		print("--- reacción %.1fs ---" % r)
		await _play_all()
	quit()

func _possible(venue: Dictionary, cfg: Dictionary) -> int:
	var possible := 0
	for d in cfg["customers"]:
		if venue["id"] == "taberna":
			possible += 10
		elif venue["id"] == "enfermeria":
			possible += int(venue["items"][d["item"]]["treat" if d.get("treat", false) else "buy"])
		elif venue.has("price"):
			possible += int(venue["price"]) * int(d.get("party", 1))
		else:
			possible += int(venue["items"][d["item"]]["repair" if d.get("repair", false) else "buy"])
	return possible

func _play_all() -> void:
	for v in main.venues.size():
		var venue: Dictionary = main.venues[v]
		if only_venue != "" and venue["id"] != only_venue:
			continue
		for li in venue["levels"].size():
			if only_level > 0 and li + 1 != only_level:
				continue
			var cfg: Dictionary = venue["levels"][li]
			var time_limit := int(cfg["time"])
			if open_time:
				cfg["time"] = OPEN_TIME
			main.venue = venue
			main._start_level(li)
			idle_since = -1.0
			var possible := _possible(venue, cfg)
			while main.phase == main.Phase.PLAYING:
				_bot_step(main.level)
				await process_frame
			var lv = main.level
			cfg["time"] = time_limit
			var used: float = (OPEN_TIME if open_time else time_limit) - lv.time_left
			var target: Array = TARGETS[str(cfg.get("difficulty", "easy"))]
			print("%s %d '%s' [%s]: monedas %d/%d  estrellas %d %s  dura %.1fs de %ds  sobra %.0f%% (objetivo %.0f%%)" % [
				venue["id"], li + 1, cfg["name"], cfg.get("difficulty", "easy"), lv.score, possible,
				Level.count_stars(cfg, lv.score), str(cfg["stars"]), used, time_limit,
				100.0 * (time_limit - used) / time_limit, 100.0 * float(target[0])])

func _bot_step(lv) -> void:
	# Sentar: en cuanto hay sitio libre (en la enfermería, solo el del mostrador
	# que viene a curarse)
	if lv is InfirmaryLevel:
		var front = lv._at_desk()
		if front != null and front.treat:
			for sp in lv.spots:
				if sp.accepts(front):
					_tap(front.position)
					_tap(sp.position)
					break
	elif not lv.queue.is_empty():
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
	elif lv is InfirmaryLevel:
		_infirmary(lv)
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

func _infirmary(lv) -> void:
	var h = lv.staff
	var patients := _at_spot(lv)
	for c in patients:
		if c.is_paying():
			_tap(c.spot.position); return
	var front = lv._at_desk()
	var buyer = front if front != null and not front.treat else null
	if h.carrying != "":
		for c in patients:
			if c.is_waiting_medicine() and c.item == h.carrying:
				_tap(c.spot.position); return
		if buyer != null and buyer.item == h.carrying:
			_tap(lv.desk.position); return
	var wanted := []
	for c in patients:
		if c.is_waiting_medicine():
			wanted.append(c.item)
	if buyer != null:
		wanted.append(buyer.item)
	for item in wanted:
		for r in lv.shelves:
			if r.item == item:
				_tap(r.position); return

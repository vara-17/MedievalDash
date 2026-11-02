extends Node2D

enum Phase { LOGIN, MAP, LEVELS, PLAYING, RESULT }

const VENUES_PATH := "res://data/venues.json"
const DEFAULT_VENUE := {
	"id": "taberna", "name": "Taberna", "goal": "", "icon": "mug", "roof": "R",
	"map_pos": [320, 200], "requires": "",
	"levels": [{
		"name": "Nivel de prueba", "time": 60, "tables": 3,
		"spawn_interval": 6, "queue_patience": 25, "table_patience": 20,
		"stars": [20, 40, 60],
	}],
}
const DOOR_POS := Vector2(10, 180)
const QUEUE_SLOTS := [Vector2(60, 110), Vector2(60, 180), Vector2(60, 250)]
const TABLE_ROWS := {2: [120, 240], 3: [80, 180, 280]}
const PAYMENT := 10
const BTN_MENU := Rect2(150, 250, 100, 44)
const BTN_RETRY := Rect2(270, 250, 100, 44)
const BTN_NEXT := Rect2(390, 250, 100, 44)
const BTN_QUIT := Rect2(290, 4, 60, 24)
const MENU_COLUMNS := 3
const MENU_BTN_SIZE := Vector2(160, 90)
const MENU_GAP := 20.0
const MENU_ORIGIN := Vector2(60, 110)
const BTN_ACCOUNT := Rect2(470, 6, 160, 28)
const BTN_BACK := Rect2(8, 8, 90, 30)
const BTN_GOOGLE := Rect2(210, 222, 220, 40)
const BTN_GUEST := Rect2(210, 274, 220, 40)
const LOGIN_WALL_ROWS := 6
const GAME_TITLE := "Medieval Dash"

var save := SaveData.new()
var venues: Array = []
var venue_index: int = 0
var venue: Dictionary = {}
var levels: Array = []
var level_index: int = 0
var level: Dictionary = {}
var phase: int = Phase.LOGIN
var time_left: float = 0.0
var passed: bool = false
var stars_earned: int = 0

var tables: Array[Table] = []
var queue: Array[Customer] = []
var customers: Array[Customer] = []
var selected: Customer = null
var auth: Auth
var auth_status: String = ""
var cloud: CloudSave
var sync_status: String = ""
var loading_account: bool = false
var background: Background
var title_art: TitleArt
var map_screen: MapScreen
var kitchen: Kitchen
var waiter: Waiter
var spawn_timer: float = 1.0
var score: int = 0


func _ready() -> void:
	_load_venues()
	save.load_from_disk()
	cloud = CloudSave.new()
	cloud.synced.connect(_on_synced)
	cloud.sync_failed.connect(_on_sync_failed)
	add_child(cloud)
	background = Background.new()
	add_child(background)
	title_art = TitleArt.new()
	add_child(title_art)
	map_screen = MapScreen.new()
	map_screen.venue_pressed.connect(_open_venue)
	add_child(map_screen)
	kitchen = Kitchen.new()
	kitchen.position = Vector2(570, 180)
	add_child(kitchen)
	waiter = Waiter.new()
	add_child(waiter)
	_set_phase(Phase.LOGIN)
	# Al final: si hay una sesión guardada, Auth emite signed_in al entrar en el árbol.
	auth = Auth.new()
	auth.signed_in.connect(_on_signed_in)
	auth.signed_out.connect(_on_signed_out)
	auth.sign_in_failed.connect(_on_sign_in_failed)
	add_child(auth)


# Cambia de pantalla y muestra solo los nodos que le tocan.
func _set_phase(new_phase: int) -> void:
	phase = new_phase
	background.visible = phase != Phase.LEVELS and phase != Phase.MAP
	background.wall_rows = LOGIN_WALL_ROWS if phase == Phase.LOGIN else 1
	title_art.visible = phase == Phase.LOGIN
	map_screen.visible = phase == Phase.MAP
	if phase == Phase.MAP:
		map_screen.refresh(venues, save)
	kitchen.visible = phase == Phase.PLAYING
	waiter.visible = phase == Phase.PLAYING


func _load_venues() -> void:
	var file := FileAccess.open(VENUES_PATH, FileAccess.READ)
	if file != null:
		var data = JSON.parse_string(file.get_as_text())
		if data is Array and not data.is_empty():
			venues = data
			_open_venue(0, false)
			return
	push_error("No se pudo leer %s, usando escenario por defecto" % VENUES_PATH)
	venues = [DEFAULT_VENUE]
	_open_venue(0, false)


# Elige el escenario cuyos niveles se van a jugar y, si show, abre su selector.
func _open_venue(index: int, show: bool = true) -> void:
	venue_index = index
	venue = venues[index]
	levels = venue["levels"]
	if show:
		_set_phase(Phase.LEVELS)


func _start_level(index: int) -> void:
	_clear_level()
	level_index = index
	level = levels[index]
	_build_tables(int(level["tables"]))
	score = 0
	time_left = float(level["time"])
	spawn_timer = 1.0
	_set_phase(Phase.PLAYING)


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


func _go_to_menu() -> void:
	_clear_level()
	_set_phase(Phase.LEVELS)


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
	save.record(str(venue["id"]), level_index, stars_earned)
	_sync()
	_clear_level()
	_set_phase(Phase.RESULT)


func _has_next() -> bool:
	return passed and level_index + 1 < levels.size()


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


func _level_button_rect(i: int) -> Rect2:
	var col := i % MENU_COLUMNS
	var row := floori(i / float(MENU_COLUMNS))
	var pos := MENU_ORIGIN + Vector2(
		col * (MENU_BTN_SIZE.x + MENU_GAP),
		row * (MENU_BTN_SIZE.y + MENU_GAP))
	return Rect2(pos, MENU_BTN_SIZE)


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
	match phase:
		Phase.LOGIN:
			_handle_login_tap(p)
			return
		Phase.MAP:
			_handle_map_tap(p)
			return
		Phase.LEVELS:
			_handle_menu_tap(p)
			return
		Phase.RESULT:
			_handle_result_tap(p)
			return
	if BTN_QUIT.has_point(p):
		_go_to_menu()
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


# Al iniciar sesión se espera a la primera sincronización (o a que falle, p. ej.
# sin conexión) antes de pasar al menú, para mostrar ya el progreso de la cuenta.
func _on_signed_in(_display_name: String) -> void:
	auth_status = ""
	_use_account_save(auth.uid)
	if phase == Phase.LOGIN:
		loading_account = true
	_sync()


func _on_signed_out() -> void:
	auth_status = ""
	sync_status = ""
	loading_account = false
	save = SaveData.new()
	save.load_from_disk()
	if phase == Phase.MAP or phase == Phase.LEVELS:
		_set_phase(Phase.LOGIN)


# Pasa al progreso de la cuenta. Si hay progreso de invitado, se suma a esta
# cuenta y se borra, para que no acabe también en otra cuenta.
func _use_account_save(uid: String) -> void:
	var account := SaveData.for_account(uid)
	account.load_from_disk()
	var guest := SaveData.new()
	guest.load_from_disk()
	if guest.has_progress():
		account.merge(guest.progress)
		guest.delete_from_disk()
	save = account


func _sync() -> void:
	if not auth.is_signed_in():
		return
	var uid := auth.uid
	var token: String = await auth.get_valid_id_token()
	if uid != auth.uid:
		return
	if token == "":
		_on_sync_failed("Sin conexión")
		return
	cloud.sync(uid, token, save.progress.duplicate(true))


func _on_synced(uid: String, progress: Dictionary) -> void:
	if uid == auth.uid:
		save.merge(progress)
		sync_status = ""
		if phase == Phase.MAP:
			map_screen.refresh(venues, save)
		_finish_loading_account()


func _on_sync_failed(message: String) -> void:
	sync_status = "Sin sincronizar: %s" % message
	_finish_loading_account()


func _finish_loading_account() -> void:
	if loading_account:
		loading_account = false
		if phase == Phase.LOGIN:
			_set_phase(Phase.MAP)


func _on_sign_in_failed(message: String) -> void:
	auth_status = message


func _handle_login_tap(p: Vector2) -> void:
	if auth.busy or loading_account:
		return
	if BTN_GOOGLE.has_point(p):
		auth_status = ""
		auth.sign_in()
	elif BTN_GUEST.has_point(p):
		auth_status = ""
		_set_phase(Phase.MAP)


func _handle_map_tap(p: Vector2) -> void:
	if BTN_ACCOUNT.has_point(p):
		if auth.is_signed_in():
			auth.sign_out()
		_set_phase(Phase.LOGIN)
		return
	map_screen.handle_tap(p)


func _handle_menu_tap(p: Vector2) -> void:
	if BTN_BACK.has_point(p):
		_set_phase(Phase.MAP)
		return
	for i in levels.size():
		if _level_button_rect(i).has_point(p) and save.is_unlocked(str(venue["id"]), i):
			_start_level(i)
			return


func _handle_result_tap(p: Vector2) -> void:
	if BTN_MENU.has_point(p):
		_set_phase(Phase.LEVELS)
	elif BTN_RETRY.has_point(p):
		_start_level(level_index)
	elif _has_next() and BTN_NEXT.has_point(p):
		_start_level(level_index + 1)


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
	if phase == Phase.LOGIN:
		_draw_login_screen(font)
		return
	if phase == Phase.MAP:
		_draw_account(font)
		return
	if phase == Phase.LEVELS:
		draw_rect(get_viewport_rect(), Color("2b2d42"))
		_draw_menu(font)
		return
	draw_rect(Rect2(0, 150, 20, 60), Color("8d6e63"))
	if phase == Phase.PLAYING and selected != null:
		for t in tables:
			if t.customer == null:
				draw_rect(_table_rect(t), Color.LIME_GREEN, false, 2.0)
	var stars_cfg: Array = level["stars"]
	draw_string(font, Vector2(8, 20), "Nivel %d   Puntos: %d/%d" % [level_index + 1, score, int(stars_cfg[0])], HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(font, Vector2(540, 20), "Tiempo: %d" % ceili(time_left), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	if phase == Phase.PLAYING:
		draw_rect(BTN_QUIT, Color("555770"))
		draw_string(font, BTN_QUIT.position + Vector2(0, 17), "Menú", HORIZONTAL_ALIGNMENT_CENTER, BTN_QUIT.size.x, 13)
	if phase == Phase.RESULT:
		_draw_result(font)


func _draw_menu(font: Font) -> void:
	var dark := Color("2b2d42")
	var venue_id := str(venue["id"])
	draw_string(font, Vector2(0, 60), str(venue["name"]), HORIZONTAL_ALIGNMENT_CENTER, 640, 36)
	draw_string(font, Vector2(0, 88), "%s · Elige un nivel" % venue["goal"], HORIZONTAL_ALIGNMENT_CENTER, 640, 14)
	_draw_wood_button(font, BTN_BACK, "‹ Mapa")
	for i in levels.size():
		var r := _level_button_rect(i)
		var unlocked := save.is_unlocked(venue_id, i)
		var text_color := dark if unlocked else Color.GRAY
		draw_rect(r, Color("81b29a") if unlocked else Color("555770"))
		draw_string(font, r.position + Vector2(0, 26), "Nivel %d" % (i + 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, text_color)
		draw_string(font, r.position + Vector2(0, 46), str(levels[i]["name"]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, text_color)
		if unlocked:
			var earned := save.get_stars(venue_id, i)
			for s in 3:
				var center := r.position + Vector2(r.size.x / 2.0 - 28.0 + s * 28.0, 70)
				if s < earned:
					draw_circle(center, 9.0, Color.GOLD)
				else:
					draw_arc(center, 9.0, 0.0, TAU, 20, dark, 2.0)
		else:
			draw_string(font, r.position + Vector2(0, 74), "Bloqueado", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, Color.GRAY)


# Pantalla de inicio: el arte lo pone TitleArt; aquí van el título y los botones.
func _draw_login_screen(font: Font) -> void:
	var palette := SpriteFactory.PALETTE
	var board := TitleArt.SIGN_RECT
	var title_pos := Vector2(board.position.x, board.position.y + 47)
	draw_string(font, title_pos + Vector2(2, 2), GAME_TITLE, HORIZONTAL_ALIGNMENT_CENTER, board.size.x, 34, palette["K"])
	draw_string(font, title_pos, GAME_TITLE, HORIZONTAL_ALIGNMENT_CENTER, board.size.x, 34, palette["Y"])
	var google_label := "Entrar con Google"
	if auth.busy:
		google_label = "Conectando..."
	elif loading_account:
		google_label = "Cargando progreso..."
	_draw_wood_button(font, BTN_GOOGLE, google_label)
	_draw_wood_button(font, BTN_GUEST, "Jugar como invitado")
	if auth_status != "":
		var y := BTN_GUEST.end.y + 8
		draw_rect(Rect2(BTN_GUEST.position.x - 40, y, BTN_GUEST.size.x + 80, 22), Color(0, 0, 0, 0.6))
		draw_string(font, Vector2(0, y + 16), auth_status, HORIZONTAL_ALIGNMENT_CENTER, 640, 13, Color("e07a5f"))


func _draw_wood_button(font: Font, r: Rect2, label: String) -> void:
	var palette := SpriteFactory.PALETTE
	draw_rect(r, palette["K"])
	draw_rect(r.grow(-2), palette["L"])
	draw_rect(Rect2(r.position + Vector2(2, r.size.y - 6), Vector2(r.size.x - 4, 4)), palette["B"])
	draw_string(font, r.position + Vector2(0, r.size.y / 2.0 + 5), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 15, palette["K"])


# Esquina del menú: quién juega y botón para volver a la pantalla de inicio.
func _draw_account(font: Font) -> void:
	var who := auth.display_name if auth.is_signed_in() else "Invitado"
	var label := "Cerrar sesión" if auth.is_signed_in() else "Iniciar sesión"
	draw_string(font, Vector2(BTN_ACCOUNT.position.x - 300, BTN_ACCOUNT.position.y + 19), who, HORIZONTAL_ALIGNMENT_RIGHT, 292, 13)
	draw_rect(BTN_ACCOUNT, Color("555770"))
	draw_string(font, BTN_ACCOUNT.position + Vector2(0, 19), label, HORIZONTAL_ALIGNMENT_CENTER, BTN_ACCOUNT.size.x, 13)
	if sync_status != "":
		draw_string(font, BTN_ACCOUNT.end + Vector2(-300, 14), sync_status, HORIZONTAL_ALIGNMENT_RIGHT, 300, 11, Color("e07a5f"))


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
	draw_rect(BTN_MENU, Color("e07a5f"))
	draw_string(font, BTN_MENU.position + Vector2(0, 28), "Menú", HORIZONTAL_ALIGNMENT_CENTER, BTN_MENU.size.x, 16, dark)
	draw_rect(BTN_RETRY, Color("81b29a"))
	draw_string(font, BTN_RETRY.position + Vector2(0, 28), "Reintentar", HORIZONTAL_ALIGNMENT_CENTER, BTN_RETRY.size.x, 16, dark)
	if _has_next():
		draw_rect(BTN_NEXT, Color("f2cc8f"))
		draw_string(font, BTN_NEXT.position + Vector2(0, 28), "Siguiente", HORIZONTAL_ALIGNMENT_CENTER, BTN_NEXT.size.x, 16, dark)

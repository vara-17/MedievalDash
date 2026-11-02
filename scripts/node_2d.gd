extends Node2D

# Escena principal. Crea las pantallas y el nivel, decide cuál se ve y las
# comunica por señales. También lleva la cuenta (Auth), el progreso (SaveData)
# y su sincronización con la nube (CloudSave).
# Flujo: inicio > mapa > niveles del escenario > nivel > resultado.

enum Phase { LOGIN, MAP, LEVELS, PLAYING, RESULT }

const LOGIN_WALL_ROWS := 6
const LEVELS_WALL_ROWS := 4

# Subclase de Level que se juega según el "gameplay" de cada escenario.
var gameplays: Dictionary = {"tavern": TavernLevel, "armory": ArmoryLevel}

var save := SaveData.new()
var venues: Array = []
var venue: Dictionary = {}
var level_index: int = 0
var phase: int = Phase.LOGIN
var loading_account: bool = false

var auth: Auth
var cloud: CloudSave
var background: Background
var login_screen: LoginScreen
var map_screen: MapScreen
var level_select: LevelSelectScreen
var level: Level = null
var result_screen: ResultScreen


func _ready() -> void:
	venues = VenueCatalog.load_all()
	venue = venues[0]
	save.load_from_disk()
	cloud = CloudSave.new()
	cloud.synced.connect(_on_synced)
	cloud.sync_failed.connect(_on_sync_failed)
	add_child(cloud)
	background = Background.new()
	add_child(background)
	login_screen = LoginScreen.new()
	login_screen.google_pressed.connect(_on_google_pressed)
	login_screen.guest_pressed.connect(_set_phase.bind(Phase.MAP))
	add_child(login_screen)
	map_screen = MapScreen.new()
	map_screen.venue_pressed.connect(_open_venue)
	map_screen.account_pressed.connect(_on_account_pressed)
	add_child(map_screen)
	level_select = LevelSelectScreen.new()
	level_select.back_pressed.connect(_set_phase.bind(Phase.MAP))
	level_select.level_pressed.connect(_start_level)
	add_child(level_select)
	result_screen = ResultScreen.new()
	result_screen.menu_pressed.connect(_set_phase.bind(Phase.LEVELS))
	result_screen.retry_pressed.connect(func() -> void: _start_level(level_index))
	result_screen.next_pressed.connect(func() -> void: _start_level(level_index + 1))
	add_child(result_screen)
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
	if phase != Phase.PLAYING and phase != Phase.RESULT:
		_free_level()
	background.visible = phase != Phase.MAP
	match phase:
		Phase.LOGIN:
			background.wall_rows = LOGIN_WALL_ROWS
		Phase.LEVELS:
			background.wall_rows = LEVELS_WALL_ROWS
		_:
			background.wall_rows = 1
	background.floor_sprite = Background.DEFAULT_FLOOR if phase == Phase.LOGIN else str(venue.get("floor", Background.DEFAULT_FLOOR))
	login_screen.visible = phase == Phase.LOGIN
	map_screen.visible = phase == Phase.MAP
	level_select.visible = phase == Phase.LEVELS
	result_screen.visible = phase == Phase.RESULT
	if phase == Phase.MAP:
		map_screen.refresh(venues, save)
	elif phase == Phase.LEVELS:
		level_select.refresh(venue, save)


func _open_venue(index: int) -> void:
	venue = venues[index]
	_set_phase(Phase.LEVELS)


func _start_level(index: int) -> void:
	var gameplay := str(venue.get("gameplay", ""))
	if not gameplays.has(gameplay):
		push_error("Escenario '%s' sin jugabilidad: '%s'" % [venue["id"], gameplay])
		return
	_free_level()
	level_index = index
	level = gameplays[gameplay].new()
	level.finished.connect(_on_level_finished)
	level.quit_pressed.connect(_set_phase.bind(Phase.LEVELS))
	add_child(level)
	level.start(venue, venue["levels"][index], index + 1)
	_set_phase(Phase.PLAYING)


func _free_level() -> void:
	if level != null:
		level.queue_free()
		level = null


func _on_level_finished(score: int) -> void:
	var levels: Array = venue["levels"]
	var config: Dictionary = levels[level_index]
	var stars := Level.count_stars(config, score)
	save.record(str(venue["id"]), level_index, stars)
	_sync()
	var has_next := stars > 0 and level_index + 1 < levels.size()
	result_screen.show_result(str(config["name"]), score, stars, has_next)
	_set_phase(Phase.RESULT)


func _process(_delta: float) -> void:
	if auth != null and login_screen.busy != auth.busy:
		login_screen.busy = auth.busy


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	var p: Vector2 = event.position
	match phase:
		Phase.LOGIN:
			login_screen.handle_tap(p)
		Phase.MAP:
			map_screen.handle_tap(p)
		Phase.LEVELS:
			level_select.handle_tap(p)
		Phase.PLAYING:
			level.handle_tap(p)
		Phase.RESULT:
			result_screen.handle_tap(p)


func _on_google_pressed() -> void:
	auth.sign_in()


func _on_account_pressed() -> void:
	if auth.is_signed_in():
		auth.sign_out()
	_set_phase(Phase.LOGIN)


# Al iniciar sesión se espera a la primera sincronización (o a que falle, p. ej.
# sin conexión) antes de pasar al mapa, para mostrar ya el progreso de la cuenta.
func _on_signed_in(display_name: String) -> void:
	login_screen.status = ""
	map_screen.player_name = display_name
	_use_account_save(auth.uid)
	if phase == Phase.LOGIN:
		_set_loading_account(true)
	_sync()


func _on_signed_out() -> void:
	login_screen.status = ""
	map_screen.player_name = ""
	map_screen.sync_status = ""
	_set_loading_account(false)
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
		map_screen.sync_status = ""
		if phase == Phase.MAP:
			map_screen.refresh(venues, save)
		_finish_loading_account()


func _on_sync_failed(message: String) -> void:
	map_screen.sync_status = "Sin sincronizar: %s" % message
	_finish_loading_account()


func _set_loading_account(value: bool) -> void:
	loading_account = value
	login_screen.loading = value


func _finish_loading_account() -> void:
	if loading_account:
		_set_loading_account(false)
		if phase == Phase.LOGIN:
			_set_phase(Phase.MAP)


func _on_sign_in_failed(message: String) -> void:
	login_screen.status = message

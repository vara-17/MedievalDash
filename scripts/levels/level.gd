class_name Level
extends Node2D

# Base de la jugabilidad de un nivel. Cada tipo de escenario (taberna, armería...)
# es una subclase que rellena _setup, _teardown, _tick, _on_tap y _draw_scene.
# Aquí va lo común: cuenta atrás, puntos, marcador y botón para salir.

signal finished(score: int)
signal quit_pressed

const BTN_QUIT := Rect2(290, 4, 60, 24)

# Escenario al que pertenece el nivel (datos comunes, como los objetos y precios).
var venue: Dictionary = {}
var config: Dictionary = {}
var number: int = 0
var running: bool = false
var time_left: float = 0.0
var score: int = 0


# Estrellas conseguidas con "score" según los umbrales "stars" del nivel.
static func count_stars(level_config: Dictionary, final_score: int) -> int:
	var stars := 0
	for t in level_config["stars"]:
		if final_score >= int(t):
			stars += 1
	return stars


func start(level_venue: Dictionary, level_config: Dictionary, level_number: int) -> void:
	venue = level_venue
	config = level_config
	number = level_number
	score = 0
	time_left = float(config["time"])
	running = true
	_setup()


func _process(delta: float) -> void:
	if not running:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		running = false
		_teardown()
		queue_redraw()
		finished.emit(score)
		return
	_tick(delta)
	queue_redraw()


func handle_tap(p: Vector2) -> void:
	if not running:
		return
	if BTN_QUIT.has_point(p):
		running = false
		_teardown()
		quit_pressed.emit()
		return
	_on_tap(p)


func _draw() -> void:
	_draw_scene()
	var font := ThemeDB.fallback_font
	var stars_cfg: Array = config["stars"]
	draw_string(font, Vector2(8, 20), "Nivel %d   Puntos: %d/%d" % [number, score, int(stars_cfg[0])], HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(font, Vector2(540, 20), "Tiempo: %d" % ceili(time_left), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	if running:
		draw_rect(BTN_QUIT, Color("555770"))
		draw_string(font, BTN_QUIT.position + Vector2(0, 17), "Menú", HORIZONTAL_ALIGNMENT_CENTER, BTN_QUIT.size.x, 13)


# Prepara el nivel (mesas, personajes...) a partir de config.
func _setup() -> void:
	pass


# Quita todo lo que haya creado _setup. Se llama al acabar o al salir.
func _teardown() -> void:
	pass


func _tick(_delta: float) -> void:
	pass


func _on_tap(_p: Vector2) -> void:
	pass


# Dibujo propio del nivel, debajo del marcador.
func _draw_scene() -> void:
	pass

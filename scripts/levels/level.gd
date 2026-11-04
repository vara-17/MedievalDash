class_name Level
extends Node2D

# Base de la jugabilidad de un nivel. Cada tipo de escenario (taberna, armería...)
# es una subclase que rellena _setup, _teardown, _tick, _on_tap y _draw_scene.
# Aquí va lo común: cuenta atrás, puntos, marcador y botón de pausa.

signal finished(score: int)
signal pause_pressed

const BTN_PAUSE := Rect2(285, 6, 70, 28)
const HUD_SCORE := Rect2(4, 3, 266, 34)
const HUD_BAR := Rect2(152, 13, 106, 14)
const HUD_TIME := Rect2(530, 3, 106, 34)
# Segundos finales en los que el tiempo se pinta en rojo.
const LOW_TIME := 10

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
		end_level()
		return
	_tick(delta)
	queue_redraw()


# Termina el nivel: al acabarse el tiempo o antes, si la subclase lo decide.
func end_level() -> void:
	if not running:
		return
	running = false
	_teardown()
	queue_redraw()
	finished.emit(score)


# Congela el nivel (tiempo, clientes, personaje) o lo reanuda. Se sigue viendo.
func set_paused(paused: bool) -> void:
	process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT


func handle_tap(p: Vector2) -> void:
	if not running:
		return
	if BTN_PAUSE.has_point(p):
		pause_pressed.emit()
		return
	_on_tap(p)


func _draw() -> void:
	_draw_scene()
	_draw_hud()


# Marcador: tablón con nivel, monedas y barra hacia las estrellas; botón de
# pausa; tablón con el tiempo.
func _draw_hud() -> void:
	var palette := SpriteFactory.PALETTE
	var thresholds: Array = config["stars"]
	var top := float(thresholds[thresholds.size() - 1])
	UiDraw.board(self, HUD_SCORE)
	UiDraw.text(self, HUD_SCORE.position + Vector2(8, 24), "Nivel %d" % number, UiDraw.MEDIUM)
	UiDraw.sprite(self, SpriteFactory.make("coin"), HUD_SCORE.position + Vector2(92, 17))
	UiDraw.text(self, HUD_SCORE.position + Vector2(104, 24), str(score), UiDraw.MEDIUM, palette["Y"])
	UiDraw.progress_bar(self, HUD_BAR, score / top, palette["Y"])
	for t in thresholds:
		var x := HUD_BAR.position.x + HUD_BAR.size.x * float(t) / top
		UiDraw.small_star(self, Vector2(x, HUD_BAR.get_center().y), score >= int(t))
	if running:
		UiDraw.wood_button(self, BTN_PAUSE, "Pausa")
	UiDraw.board(self, HUD_TIME)
	UiDraw.sprite(self, SpriteFactory.make("hourglass"), HUD_TIME.position + Vector2(18, 17))
	var seconds := ceili(time_left)
	var time_color: Color = palette["R"] if seconds <= LOW_TIME else palette["W"]
	UiDraw.text(self, HUD_TIME.position + Vector2(32, 24), "%d:%02d" % [floori(seconds / 60.0), seconds % 60], UiDraw.MEDIUM, time_color)


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

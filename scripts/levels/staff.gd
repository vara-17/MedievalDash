class_name Staff
extends Node2D

# Quien atiende (tabernero, herrero...). Cada toque añade una acción a una cola
# (FIFO): ir a un punto y, al llegar, intentar hacer algo allí. Si al llegar no
# hay nada que hacer, la acción no hace nada y pasa a la siguiente.
# Algunas acciones llevan un rato (hacer una cama): work() lo deja quieto con
# una barra de progreso y al terminar llama a "on_done".
# Lo que lleva encima lo pinta la subclase.

const SPEED := 180.0
const MAX_ACTIONS := 6
const MARKER_RADIUS := 7.0
# Separación entre marcadores que caen en el mismo punto.
const MARKER_SHIFT := Vector2(15, 0)
const WORK_BAR := Rect2(-17, -40, 34, 7)

var sprite_name: String = ""
# Acciones pendientes: {"pos": Vector2, "callback": Callable, "about": Object}.
# "about" es a quién se refiere (un cliente), para poder cancelarla si se va.
var actions: Array[Dictionary] = []
var tex: Texture2D
var work_time: float = 0.0
var work_left: float = 0.0
var work_done: Callable = Callable()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex = SpriteFactory.make(sprite_name)


func add_action(p: Vector2, callback: Callable = Callable(), about: Object = null) -> void:
	if actions.size() >= MAX_ACTIONS:
		return
	actions.append({"pos": p, "callback": callback, "about": about})


# Se queda trabajando "seconds" segundos antes de seguir con la cola.
func work(seconds: float, on_done: Callable) -> void:
	work_time = seconds
	work_left = seconds
	work_done = on_done


# Quita todas las acciones pendientes; se queda donde está. Lo que esté
# haciendo en el sitio (hacer una cama) lo termina.
func clear_actions() -> void:
	actions.clear()


# Quita las acciones que se refieren a "about" (p. ej. un cliente que se ha ido).
func cancel_actions_about(about: Object) -> void:
	actions = actions.filter(func(a: Dictionary) -> bool: return a["about"] != about)


# Vuelve a la posición de inicio, sin acciones pendientes ni nada en las manos.
func reset(p: Vector2) -> void:
	position = p
	actions.clear()
	work_left = 0.0
	work_done = Callable()
	_drop_all()


func _process(delta: float) -> void:
	if work_left > 0.0:
		work_left -= delta
		if work_left <= 0.0:
			var done := work_done
			work_done = Callable()
			if done.is_valid():
				done.call()
	elif not actions.is_empty():
		var action: Dictionary = actions[0]
		position = position.move_toward(action["pos"], SPEED * delta)
		if position.is_equal_approx(action["pos"]):
			actions.pop_front()
			var cb: Callable = action["callback"]
			if cb.is_valid():
				cb.call()
	queue_redraw()


func _draw() -> void:
	var seen: Dictionary = {}
	for i in actions.size():
		var pos: Vector2 = actions[i]["pos"]
		var repeats: int = seen.get(pos, 0)
		seen[pos] = repeats + 1
		_draw_marker(pos - position + MARKER_SHIFT * repeats, i + 1)
	if tex != null:
		draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2.ZERO), false)
	_draw_carried()
	if work_left > 0.0:
		UiDraw.progress_bar(self, WORK_BAR, 1.0 - work_left / work_time, SpriteFactory.PALETTE["C"])


# Círculo numerado en el punto de cada acción pendiente.
func _draw_marker(at: Vector2, number: int) -> void:
	var palette := SpriteFactory.PALETTE
	draw_circle(at, MARKER_RADIUS + 1.0, palette["K"])
	draw_circle(at, MARKER_RADIUS, palette["Y"])
	draw_string(ThemeDB.fallback_font, at + Vector2(-MARKER_RADIUS, 4), str(number), HORIZONTAL_ALIGNMENT_CENTER, MARKER_RADIUS * 2.0, UiDraw.TINY, palette["K"])


# Suelta lo que lleve encima.
func _drop_all() -> void:
	pass


# Dibuja lo que lleva encima, sobre la cabeza.
func _draw_carried() -> void:
	pass

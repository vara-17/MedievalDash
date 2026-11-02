class_name ServiceCustomer
extends Node2D

# Cliente que espera en cola, camina a un sitio (Spot) y allí le atienden.
# Aquí va lo común: caminar, paciencia y dibujo del cuerpo, la barra y el aviso.
# Lo que pasa en el sitio (pedir, comer, reparar...) lo decide la subclase.

signal left(who: ServiceCustomer, paid: bool)

enum State { QUEUED, WALKING, AT_SPOT }

const SPEED := 120.0
const HINT_POS := Vector2(-50, 30)
const HINT_WIDTH := 100.0
const PATIENCE_BAR := Rect2(-17, -31, 34, 7)

var state: int = State.QUEUED
var spot: Spot = null
var queue_pos: Vector2
var selected: bool = false
var color: Color = Color.from_hsv(randf(), 0.5, 1.0)
var max_patience: float = 25.0
var patience: float = 25.0
# Paciencia al llegar al sitio (la de la cola es la inicial).
var spot_patience: float = 20.0
var gone: bool = false
var body_tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_tex = SpriteFactory.make("customer", {"X": color})


func _process(delta: float) -> void:
	match state:
		State.QUEUED:
			position = position.move_toward(queue_pos, SPEED * delta)
			lose_patience(delta)
		State.WALKING:
			var target := spot.customer_position()
			position = position.move_toward(target, SPEED * delta)
			if position.is_equal_approx(target):
				state = State.AT_SPOT
				_on_arrived()
		State.AT_SPOT:
			_tick_at_spot(delta)
	queue_redraw()


func go_to_spot(s: Spot) -> void:
	spot = s
	state = State.WALKING
	selected = false
	max_patience = spot_patience
	patience = spot_patience


func reset_patience() -> void:
	patience = max_patience


func lose_patience(delta: float) -> void:
	patience -= delta
	if patience <= 0.0:
		leave(false)


func leave(paid: bool) -> void:
	if gone:
		return
	gone = true
	left.emit(self, paid)


func _draw() -> void:
	if selected:
		draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 24, SpriteFactory.PALETTE["N"], 2.0)
	if body_tex != null:
		draw_texture_rect(body_tex, SpriteFactory.rect_centered(body_tex, Vector2.ZERO), false)
	if state == State.WALKING:
		return
	if _shows_patience():
		var ratio := patience / max_patience
		UiDraw.progress_bar(self, PATIENCE_BAR, ratio, _patience_color(ratio))
	_draw_extra()
	UiDraw.text(self, HINT_POS, _hint_text(), 11, SpriteFactory.PALETTE["W"], HORIZONTAL_ALIGNMENT_CENTER, HINT_WIDTH)


# Verde con paciencia, amarillo a medias, rojo a punto de irse.
static func _patience_color(ratio: float) -> Color:
	var palette := SpriteFactory.PALETTE
	if ratio > 0.5:
		return palette["N"]
	if ratio > 0.25:
		return palette["Y"]
	return palette["R"]


# Al llegar al sitio.
func _on_arrived() -> void:
	pass


# Cada fotograma en el sitio. Por defecto, la paciencia baja.
func _tick_at_spot(delta: float) -> void:
	lose_patience(delta)


func _shows_patience() -> bool:
	return true


# Texto de ayuda bajo el cliente.
func _hint_text() -> String:
	return ""


# Dibujo propio (bocadillo, plato...), encima del cuerpo.
func _draw_extra() -> void:
	pass

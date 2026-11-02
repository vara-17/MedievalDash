class_name ArmoryCustomer
extends Node2D

# Cliente de la armería. Quiere comprar un objeto o que le reparen el suyo.
# Ciclo: cola > camina al mostrador > espera (que le traigan el objeto, o que
# le recojan el roto) > si es reparación, espera el arreglo > paga y se va.

signal left(who)

enum State { QUEUED, WALKING, WAITING, REPAIRING }

const SPEED := 120.0
const BUBBLE := Rect2(-19, -68, 38, 36)

var state: int = State.QUEUED
var counter: Counter = null
var queue_pos: Vector2
var selected: bool = false
var color: Color = Color.from_hsv(randf(), 0.5, 1.0)
# Objeto que quiere ("sword", "shield"...) y si es para reparar.
var item: String = ""
var repair: bool = false
var max_patience: float = 25.0
var patience: float = 25.0
var counter_patience: float = 20.0
var gone: bool = false
var body_tex: Texture2D
var item_tex: Texture2D


# Grieta roja sobre un objeto, para marcarlo como roto.
static func draw_crack(canvas: CanvasItem, r: Rect2) -> void:
	var red: Color = SpriteFactory.PALETTE["R"]
	var a := r.position + r.size * Vector2(0.65, 0.15)
	var b := r.position + r.size * Vector2(0.45, 0.45)
	var c := r.position + r.size * Vector2(0.6, 0.6)
	var d := r.position + r.size * Vector2(0.35, 0.9)
	canvas.draw_polyline(PackedVector2Array([a, b, c, d]), red, 2.0)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_tex = SpriteFactory.make("customer", {"X": color})
	item_tex = SpriteFactory.make(item)


func _process(delta: float) -> void:
	match state:
		State.QUEUED:
			position = position.move_toward(queue_pos, SPEED * delta)
			_lose_patience(delta)
		State.WALKING:
			var spot := counter.customer_position()
			position = position.move_toward(spot, SPEED * delta)
			if position.is_equal_approx(spot):
				state = State.WAITING
		State.WAITING, State.REPAIRING:
			_lose_patience(delta)
	queue_redraw()


func _lose_patience(delta: float) -> void:
	patience -= delta
	if patience <= 0.0:
		_leave()


func go_to_counter(c: Counter) -> void:
	counter = c
	state = State.WALKING
	selected = false
	max_patience = counter_patience
	patience = counter_patience


# Entrega su objeto roto al herrero y espera el arreglo.
func hand_over() -> void:
	state = State.REPAIRING
	patience = max_patience


# Recibe lo que pidió: paga y se va.
func receive() -> void:
	_leave()


func _leave() -> void:
	if gone:
		return
	gone = true
	left.emit(self)


func _hint_text() -> String:
	match state:
		State.QUEUED:
			return "Elige mostrador" if selected else "Toca: atender"
		State.WAITING:
			return "Toca: recoger" if repair else "Quiere comprar"
		State.REPAIRING:
			return "Esperando arreglo"
	return ""


func _draw() -> void:
	if selected:
		draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 24, Color.WHITE, 2.0)
	if body_tex != null:
		draw_texture_rect(body_tex, SpriteFactory.rect_centered(body_tex, Vector2.ZERO), false)
	if state == State.WALKING:
		return
	var ratio := patience / max_patience
	draw_rect(Rect2(-16, -28, 32, 4), Color.DARK_RED)
	draw_rect(Rect2(-16, -28, 32.0 * ratio, 4), Color.LIME_GREEN)
	if state != State.QUEUED:
		_draw_bubble()
	draw_string(ThemeDB.fallback_font, Vector2(-50, 30), _hint_text(), HORIZONTAL_ALIGNMENT_CENTER, 100, 11)


# Bocadillo con lo que quiere; si es reparación, el objeto sale roto.
func _draw_bubble() -> void:
	var palette := SpriteFactory.PALETTE
	draw_rect(BUBBLE, palette["K"])
	draw_rect(BUBBLE.grow(-2), palette["W"])
	if item_tex == null:
		return
	var r := SpriteFactory.rect_centered(item_tex, BUBBLE.get_center())
	draw_texture_rect(item_tex, r, false)
	if repair:
		draw_crack(self, r)

class_name Customer
extends Node2D

signal left(who, paid: bool)

enum State { QUEUED, WALKING, SEATED, ORDERED, EATING, PAYING }

const SPEED := 120.0
const QUEUE_PATIENCE := 25.0
const TABLE_PATIENCE := 20.0
const EAT_TIME := 3.0

var state: int = State.QUEUED
var table: Table = null
var queue_pos: Vector2
var selected: bool = false
var color: Color = Color.from_hsv(randf(), 0.5, 1.0)
var max_patience: float = QUEUE_PATIENCE
var patience: float = QUEUE_PATIENCE
var table_patience: float = TABLE_PATIENCE
var eat_timer: float = 0.0
var gone: bool = false
var body_tex: Texture2D
var dish_tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_tex = SpriteFactory.make("customer", {"X": color})
	dish_tex = SpriteFactory.make("mug", {"X": color})


func _process(delta: float) -> void:
	match state:
		State.QUEUED:
			position = position.move_toward(queue_pos, SPEED * delta)
			patience -= delta
			if patience <= 0.0:
				_leave(false)
		State.WALKING:
			var seat := table.seat_position()
			position = position.move_toward(seat, SPEED * delta)
			if position.is_equal_approx(seat):
				state = State.SEATED
		State.SEATED, State.ORDERED, State.PAYING:
			patience -= delta
			if patience <= 0.0:
				_leave(false)
		State.EATING:
			eat_timer -= delta
			if eat_timer <= 0.0:
				state = State.PAYING
				patience = max_patience
	queue_redraw()


func seat_at(t: Table) -> void:
	table = t
	state = State.WALKING
	selected = false
	max_patience = table_patience
	patience = table_patience


func take_order() -> void:
	state = State.ORDERED
	patience = max_patience


func serve() -> void:
	state = State.EATING
	eat_timer = EAT_TIME


func pay() -> void:
	_leave(true)


func _leave(paid: bool) -> void:
	if gone:
		return
	gone = true
	left.emit(self, paid)


func _hint_text() -> String:
	match state:
		State.QUEUED:
			return "Elige una mesa" if selected else "Toca: sentar"
		State.SEATED:
			return "Toca: tomar nota"
		State.ORDERED:
			return "Esperando bebida"
		State.EATING:
			return "Bebiendo..."
		State.PAYING:
			return "Toca: cobrar"
	return ""


func _draw() -> void:
	if selected:
		draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 24, Color.WHITE, 2.0)
	if body_tex != null:
		draw_texture_rect(body_tex, SpriteFactory.rect_centered(body_tex, Vector2.ZERO), false)
	if state == State.WALKING:
		return
	if state != State.EATING:
		var ratio := patience / max_patience
		draw_rect(Rect2(-16, -28, 32, 4), Color.DARK_RED)
		draw_rect(Rect2(-16, -28, 32.0 * ratio, 4), Color.LIME_GREEN)
	draw_string(ThemeDB.fallback_font, Vector2(-40, -36), _hint_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12)

class_name InfirmaryCustomer
extends ServiceCustomer

# Cliente de la enfermería. Solo se le atiende cuando llega al mostrador
# (primero de la cola):
# - Si viene a comprar, se le entrega la medicina allí, paga y se va.
# - Si viene a curarse ("treat"), se le lleva a una camilla. Tumbado, espera su
#   medicina; al dársela se recupera (sin perder paciencia), se levanta y
#   espera a que le cobren.

enum Step { WAITING, RECOVERING, PAYING }

# Bocadillo con la medicina, encima de la cabeza (o de la camilla).
const BUBBLE := Rect2(-19, -74, 38, 38)
const LYING_PATIENCE_BAR := Rect2(-17, -40, 34, 7)
const LYING_BUBBLE := Rect2(-19, -82, 38, 38)

var step: int = Step.WAITING
# Medicina que quiere ("potion", "herbs"...) y si viene a curarse.
var item: String = ""
var treat: bool = false
var recover_time: float = 5.0
var recover_timer: float = 0.0
# Si es el primero de la cola y ya está en el mostrador.
var at_desk: bool = false
var item_tex: Texture2D


func _ready() -> void:
	super()
	item_tex = SpriteFactory.make(item)


# Llega al mostrador: desde aquí cuenta su paciencia de mostrador.
func reach_desk(desk_patience: float) -> void:
	at_desk = true
	max_patience = desk_patience
	patience = desk_patience


func _on_arrived() -> void:
	step = Step.WAITING


func _tick_at_spot(delta: float) -> void:
	if step == Step.RECOVERING:
		recover_timer -= delta
		if recover_timer <= 0.0:
			step = Step.PAYING
			position = (spot as Stretcher).stand_position()
			reset_patience()
	else:
		lose_patience(delta)


func give_medicine() -> void:
	step = Step.RECOVERING
	recover_timer = recover_time


func pay() -> void:
	leave(true)


func is_lying() -> bool:
	return state == State.AT_SPOT and step != Step.PAYING


func is_waiting_medicine() -> bool:
	return state == State.AT_SPOT and step == Step.WAITING


func is_paying() -> bool:
	return state == State.AT_SPOT and step == Step.PAYING


# Tumbado lo pinta la camilla; aquí solo la paciencia y la medicina que espera.
func _draw() -> void:
	if not is_lying():
		super()
		return
	if step == Step.WAITING:
		var ratio := patience / max_patience
		UiDraw.progress_bar(self, LYING_PATIENCE_BAR, ratio, _patience_color(ratio))
		_draw_bubble(LYING_BUBBLE)


func _hint_text() -> String:
	if state == State.QUEUED:
		if not at_desk:
			return ""
		if treat:
			return "Elige camilla" if selected else "Toca: atender"
		return "Comprar"
	return "Toca: cobrar" if step == Step.PAYING else ""


func _draw_extra() -> void:
	if state == State.QUEUED and at_desk and not treat:
		_draw_bubble(BUBBLE)


func _draw_bubble(r: Rect2) -> void:
	if item_tex == null:
		return
	var palette := SpriteFactory.PALETTE
	draw_rect(r, palette["K"])
	draw_rect(r.grow(-2), palette["W"])
	draw_texture_rect(item_tex, SpriteFactory.rect_centered(item_tex, r.get_center()), false)

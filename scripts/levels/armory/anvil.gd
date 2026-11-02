class_name Anvil
extends Node2D

# Yunque: arregla de uno en uno los objetos rotos que trae el herrero.
# Los arreglados se quedan al lado hasta que el herrero los recoge.

const RECT := Rect2(-32, -32, 64, 64)
const READY_OFFSET := Vector2(44, -8)
const READY_GAP := 30.0

var repair_time: float = 4.0
var pending: Array[ArmoryCustomer] = []
var ready_items: Array[ArmoryCustomer] = []
var working: ArmoryCustomer = null
var timer: float = 0.0
var tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex = SpriteFactory.make("anvil")


func _process(delta: float) -> void:
	if working == null and not pending.is_empty():
		working = pending.pop_front()
		timer = repair_time
	if working != null:
		timer -= delta
		if timer <= 0.0:
			ready_items.append(working)
			working = null
	queue_redraw()


func add_repair(c: ArmoryCustomer) -> void:
	pending.append(c)


func cancel_repairs_of(c: ArmoryCustomer) -> void:
	pending.erase(c)
	ready_items.erase(c)
	if working == c:
		working = null


func take_ready() -> ArmoryCustomer:
	if ready_items.is_empty():
		return null
	return ready_items.pop_front()


func contains_point(p: Vector2) -> bool:
	return RECT.has_point(p - position)


func smith_position() -> Vector2:
	return position + Vector2(0, 44)


func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(-30, -30), "Yunque", HORIZONTAL_ALIGNMENT_CENTER, 60, 13)
	if tex != null:
		draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2.ZERO), false)
	if working != null:
		var ratio := 1.0 - timer / repair_time
		draw_rect(Rect2(-28, 20, 56, 6), Color.DIM_GRAY)
		draw_rect(Rect2(-28, 20, 56.0 * ratio, 6), SpriteFactory.PALETTE["O"])
		if working.item_tex != null:
			draw_texture_rect(working.item_tex, SpriteFactory.rect_centered(working.item_tex, Vector2(0, -6)), false, Color(1, 0.75, 0.6))
	for i in ready_items.size():
		var c := ready_items[i]
		if c.item_tex != null:
			draw_texture_rect(c.item_tex, SpriteFactory.rect_centered(c.item_tex, READY_OFFSET + Vector2(i * READY_GAP, 0)), false)

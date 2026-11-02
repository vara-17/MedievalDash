class_name Smith
extends Node2D

# Herrero: va a donde se le manda y lleva un objeto cada vez. Puede ser uno
# nuevo del estante (owner = null) o el de un cliente, roto o ya arreglado.

const SPEED := 180.0

var target: Vector2
var on_arrive: Callable = Callable()
var carry_item: String = ""
var carry_owner: ArmoryCustomer = null
var carry_broken: bool = false
var tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	target = position
	tex = SpriteFactory.make("smith")


func go_to(p: Vector2, callback: Callable) -> void:
	target = p
	on_arrive = callback
	_check_arrival()


func is_empty_handed() -> bool:
	return carry_item == ""


func carry(item: String, item_owner: ArmoryCustomer, broken: bool) -> void:
	carry_item = item
	carry_owner = item_owner
	carry_broken = broken


func drop() -> void:
	carry("", null, false)


func _process(delta: float) -> void:
	position = position.move_toward(target, SPEED * delta)
	_check_arrival()
	queue_redraw()


func _check_arrival() -> void:
	if position.is_equal_approx(target) and on_arrive.is_valid():
		var cb := on_arrive
		on_arrive = Callable()
		cb.call()


func _draw() -> void:
	if tex != null:
		draw_texture_rect(tex, SpriteFactory.rect_centered(tex, Vector2.ZERO), false)
	if carry_item != "":
		var item_tex := SpriteFactory.make(carry_item)
		var r := SpriteFactory.rect_centered(item_tex, Vector2(0, -28))
		draw_texture_rect(item_tex, r, false)
		if carry_broken:
			ArmoryCustomer.draw_crack(self, r)

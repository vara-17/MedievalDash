class_name Smith
extends Staff

# Herrero: lleva un objeto cada vez. Puede ser uno nuevo del estante
# (carry_owner = null) o el de un cliente, roto o ya arreglado.

var carry_item: String = ""
var carry_owner: ArmoryCustomer = null
var carry_broken: bool = false


func _init() -> void:
	sprite_name = "smith"


func is_empty_handed() -> bool:
	return carry_item == ""


func carry(item: String, item_owner: ArmoryCustomer, broken: bool) -> void:
	carry_item = item
	carry_owner = item_owner
	carry_broken = broken


func _drop_all() -> void:
	carry("", null, false)


func _draw_carried() -> void:
	if carry_item == "":
		return
	var item_tex := SpriteFactory.make(carry_item)
	var r := SpriteFactory.rect_centered(item_tex, Vector2(0, -28))
	draw_texture_rect(item_tex, r, false)
	if carry_broken:
		ArmoryCustomer.draw_crack(self, r)

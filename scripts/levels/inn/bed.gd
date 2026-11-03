class_name Bed
extends Spot

# Cama de la posada: individual (capacity 1) o doble (capacity 2, para 1 o 2
# personas). Hecha, con alguien durmiendo o deshecha. El huésped espera a la
# izquierda y el posadero atiende desde la derecha. Una cama deshecha no admite
# a nadie hasta que se hace.

# Color de la manta cuando no hay nadie.
const BLANKET := "U"
const SIDE_GAP := 20.0
const HINT_POS := Vector2(-50, 40)
const HINT_WIDTH := 100.0
const SLEEP_BAR := Rect2(-17, -36, 34, 7)

var made: bool = true
# Cama con el huésped dormido (cabeza y manta de su color), creada al llegar.
var sleeper_tex: Texture2D


func _init(bed_capacity: int = 1) -> void:
	capacity = bed_capacity
	size = Vector2(52, 48) if capacity > 1 else Vector2(32, 48)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func accepts(c: ServiceCustomer) -> bool:
	return made and super(c)


func make() -> void:
	made = true


func customer_position() -> Vector2:
	return position + Vector2(-size.x / 2.0 - SIDE_GAP, 0)


func staff_position() -> Vector2:
	return position + Vector2(size.x / 2.0 + SIDE_GAP, 0)


func _sprite_base() -> String:
	return "bed_double" if capacity > 1 else "bed"


func _sleeper() -> InnGuest:
	var g := customer as InnGuest
	if g != null and g.is_sleeping():
		return g
	return null


# Al acostarse alguien, la cama deja de estar hecha y se crea su dibujo.
func _check_sleeper() -> InnGuest:
	var g := _sleeper()
	if g != null and made:
		made = false
		var sprite_name := "bed_sleep" if capacity == 1 else "bed_double_sleep%d" % g.party
		sleeper_tex = SpriteFactory.make(sprite_name, {"X": g.color})
	return g


func _process(_delta: float) -> void:
	_check_sleeper()
	queue_redraw()


func _draw() -> void:
	var g := _check_sleeper()
	if g != null:
		UiDraw.sprite(self, sleeper_tex, Vector2.ZERO)
		UiDraw.progress_bar(self, SLEEP_BAR, 1.0 - g.sleep_timer / g.sleep_time, SpriteFactory.PALETTE["C"])
		UiDraw.text(self, SLEEP_BAR.end + Vector2(4, 0), "Zzz", UiDraw.SMALL)
		return
	if made:
		UiDraw.sprite(self, UiDraw.tinted(_sprite_base(), BLANKET), Vector2.ZERO)
		return
	UiDraw.sprite(self, UiDraw.tinted(_sprite_base() + "_unmade", BLANKET), Vector2.ZERO)
	if customer == null:
		UiDraw.text(self, HINT_POS, "Toca: hacer", UiDraw.SMALL, SpriteFactory.PALETTE["W"], HORIZONTAL_ALIGNMENT_CENTER, HINT_WIDTH)

class_name ArmoryCustomer
extends ServiceCustomer

# Cliente de la armería. Quiere comprar un objeto o que le reparen el suyo.
# En el mostrador: espera (a que le traigan el objeto, o a que le recojan el
# roto) y, si es reparación, espera el arreglo. Al recibirlo paga y se va.

enum Step { WAITING, REPAIRING }

# A la izquierda del cliente, para no tapar al del mostrador de arriba.
const BUBBLE := Rect2(-64, -26, 38, 36)

var step: int = Step.WAITING
# Objeto que quiere ("sword", "shield"...) y si es para reparar.
var item: String = ""
var repair: bool = false
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
	super()
	item_tex = SpriteFactory.make(item)


func _on_arrived() -> void:
	step = Step.WAITING


# Entrega su objeto roto al herrero y espera el arreglo.
func hand_over() -> void:
	step = Step.REPAIRING
	reset_patience()


# Recibe lo que pidió: paga y se va.
func receive() -> void:
	leave(true)


func _hint_text() -> String:
	if state == State.QUEUED:
		return "Elige mostrador" if selected else "Toca: atender"
	if step == Step.REPAIRING:
		return "Esperando arreglo"
	return "Toca: recoger" if repair else "Quiere comprar"


# Bocadillo con lo que quiere; si es reparación, el objeto sale roto.
func _draw_extra() -> void:
	if state != State.AT_SPOT or item_tex == null:
		return
	var palette := SpriteFactory.PALETTE
	draw_rect(BUBBLE, palette["K"])
	draw_rect(BUBBLE.grow(-2), palette["W"])
	var r := SpriteFactory.rect_centered(item_tex, BUBBLE.get_center())
	draw_texture_rect(item_tex, r, false)
	if repair:
		draw_crack(self, r)

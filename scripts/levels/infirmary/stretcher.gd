class_name Stretcher
extends Spot

# Camilla de la enfermería. El paciente se tumba encima (la camilla lo pinta,
# con la manta de su color) y, curado, se levanta a la izquierda para pagar.
# La curandera atiende desde la derecha.

const SIDE_GAP := 20.0
const RECOVER_BAR := Rect2(-17, -40, 34, 7)

# Camilla con el paciente tumbado, creada al llegar.
var patient_tex: Texture2D
var patient_for: ServiceCustomer = null


func _init() -> void:
	size = Vector2(32, 52)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


# Donde espera de pie el paciente ya curado.
func stand_position() -> Vector2:
	return position + Vector2(-size.x / 2.0 - SIDE_GAP, 0)


func staff_position() -> Vector2:
	return position + Vector2(size.x / 2.0 + SIDE_GAP, 0)


func _lying() -> InfirmaryCustomer:
	var c := customer as InfirmaryCustomer
	if c != null and c.is_lying():
		return c
	return null


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var c := _lying()
	if c == null:
		UiDraw.sprite(self, SpriteFactory.make("stretcher"), Vector2.ZERO)
		return
	if patient_for != c:
		patient_for = c
		patient_tex = SpriteFactory.make("stretcher_patient", {"X": c.color})
	UiDraw.sprite(self, patient_tex, Vector2.ZERO)
	if c.step == InfirmaryCustomer.Step.RECOVERING:
		UiDraw.progress_bar(self, RECOVER_BAR, 1.0 - c.recover_timer / c.recover_time, SpriteFactory.PALETTE["N"])

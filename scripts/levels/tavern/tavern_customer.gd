class_name TavernCustomer
extends ServiceCustomer

# Cliente de la taberna. En la mesa: espera a que le tomen nota, espera la
# bebida, bebe y espera a que le cobren.

enum Step { SEATED, ORDERED, EATING, PAYING }

const EAT_TIME := 3.0

var step: int = Step.SEATED
var eat_timer: float = 0.0
var dish_tex: Texture2D


func _ready() -> void:
	super()
	dish_tex = SpriteFactory.make("mug", {"X": color})


func _on_arrived() -> void:
	step = Step.SEATED


func _tick_at_spot(delta: float) -> void:
	if step == Step.EATING:
		eat_timer -= delta
		if eat_timer <= 0.0:
			step = Step.PAYING
			reset_patience()
	else:
		lose_patience(delta)


func take_order() -> void:
	step = Step.ORDERED
	reset_patience()


func serve() -> void:
	step = Step.EATING
	eat_timer = EAT_TIME


func pay() -> void:
	leave(true)


func _shows_patience() -> bool:
	return not (state == State.AT_SPOT and step == Step.EATING)


func _hint_text() -> String:
	if state == State.QUEUED:
		return "Elige una mesa" if selected else "Toca: sentar"
	match step:
		Step.SEATED:
			return "Toca: tomar nota"
		Step.ORDERED:
			return "Esperando bebida"
		Step.EATING:
			return "Bebiendo..."
		Step.PAYING:
			return "Toca: cobrar"
	return ""

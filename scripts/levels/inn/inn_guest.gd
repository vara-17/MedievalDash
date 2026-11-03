class_name InnGuest
extends ServiceCustomer

# Huésped de la posada. En la cama duerme (sin perder paciencia); al
# despertarse se levanta, deja la cama deshecha y espera a que le cobren.

enum Step { SLEEPING, PAYING }

var step: int = Step.SLEEPING
var sleep_time: float = 6.0
var sleep_timer: float = 0.0


func _on_arrived() -> void:
	step = Step.SLEEPING
	sleep_timer = sleep_time


func _tick_at_spot(delta: float) -> void:
	if step == Step.SLEEPING:
		sleep_timer -= delta
		if sleep_timer <= 0.0:
			step = Step.PAYING
			reset_patience()
	else:
		lose_patience(delta)


func is_sleeping() -> bool:
	return state == State.AT_SPOT and step == Step.SLEEPING


func is_paying() -> bool:
	return state == State.AT_SPOT and step == Step.PAYING


func pay() -> void:
	leave(true)


# Mientras duerme lo pinta la cama.
func _draw() -> void:
	if not is_sleeping():
		super()


func _hint_text() -> String:
	if state == State.QUEUED:
		return "Elige cama" if selected else "Toca: alojar"
	if step == Step.PAYING:
		return "Toca: cobrar"
	return ""

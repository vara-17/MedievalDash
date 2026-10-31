extends Node2D

var pos := Vector2(200, 200)
var target := Vector2(200, 200)

func _process(delta):
	pos = pos.lerp(target, 5.0 * delta)
	queue_redraw()

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target = event.position
	elif event is InputEventMouseButton and event.pressed:
		target = event.position

func _draw():
	draw_circle(pos, 24, Color.ORANGE)

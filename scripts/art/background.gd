class_name Background
extends Node2D

# Fondo del local: pared de piedra arriba, zócalo y suelo (madera por defecto).
# Se dibuja una sola vez (y al cambiar el tamaño de la ventana), detrás del resto.

const DEFAULT_FLOOR := "floor_wood"

# Filas de pared de piedra (32 px cada una): 1 en los niveles, más en la portada.
var wall_rows: int = 1:
	set(value):
		wall_rows = value
		queue_redraw()

# Sprite del suelo; cada escenario puede tener el suyo ("floor" en venues.json).
var floor_sprite: String = DEFAULT_FLOOR:
	set(value):
		floor_sprite = value
		floor_tex = SpriteFactory.make(value)
		queue_redraw()

var floor_tex: Texture2D
var wall_tex: Texture2D
var base_tex: Texture2D


func _ready() -> void:
	z_index = -1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	floor_tex = SpriteFactory.make(floor_sprite)
	wall_tex = SpriteFactory.make("wall_stone")
	base_tex = SpriteFactory.make("wall_base")
	get_viewport().size_changed.connect(queue_redraw)


func _draw() -> void:
	var view := get_viewport_rect().size
	var y := 0.0
	for i in wall_rows:
		y = _draw_row(wall_tex, y, view.x)
	y = _draw_row(base_tex, y, view.x)
	while y < view.y:
		y = _draw_row(floor_tex, y, view.x)


# Repite la textura a lo ancho y devuelve la y donde empieza la siguiente fila.
func _draw_row(tex: Texture2D, y: float, width: float) -> float:
	var size := tex.get_size() * SpriteFactory.SCALE
	var x := 0.0
	while x < width:
		draw_texture_rect(tex, Rect2(Vector2(x, y), size), false)
		x += size.x
	return y + size.y

class_name UiDraw
extends RefCounted

# Elementos de interfaz comunes a varias pantallas. Se llaman desde el _draw
# del nodo que los pinta ("canvas").

const TEXT_SHADOW := Vector2(1, 1)

# Texturas con tinte; se guardan aquí porque si se crean dentro de _draw se
# liberan antes de pintarse.
static var _tinted: Dictionary = {}


static func tinted(sprite_name: String, letter: String) -> Texture2D:
	var key := sprite_name + ":" + letter
	if not _tinted.has(key):
		_tinted[key] = SpriteFactory.make(sprite_name, {"X": SpriteFactory.PALETTE[letter]})
	return _tinted[key]


static func sprite(canvas: CanvasItem, tex: Texture2D, center: Vector2, modulate: Color = Color.WHITE) -> void:
	canvas.draw_texture_rect(tex, SpriteFactory.rect_centered(tex, center), false, modulate)


# Texto con sombra oscura, para que se lea sobre cualquier fondo.
static func text(canvas: CanvasItem, pos: Vector2, value: String, size: int, color: Color = Color.WHITE,
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0) -> void:
	var font := ThemeDB.fallback_font
	canvas.draw_string(font, pos + TEXT_SHADOW, value, align, width, size, SpriteFactory.PALETTE["K"])
	canvas.draw_string(font, pos, value, align, width, size, color)


static func wood_button(canvas: CanvasItem, r: Rect2, label: String, font_size: int = 15) -> void:
	var palette := SpriteFactory.PALETTE
	canvas.draw_rect(r, palette["K"])
	canvas.draw_rect(r.grow(-2), palette["L"])
	canvas.draw_rect(Rect2(r.position + Vector2(2, r.size.y - 6), Vector2(r.size.x - 4, 4)), palette["B"])
	canvas.draw_string(ThemeDB.fallback_font, r.position + Vector2(0, r.size.y / 2.0 + 5), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, font_size, palette["K"])


# Tablón de madera oscura con borde claro arriba (marcadores, tarjetas).
static func board(canvas: CanvasItem, r: Rect2, dimmed: bool = false) -> void:
	var palette := SpriteFactory.PALETTE
	var tint := Color(0.55, 0.55, 0.6) if dimmed else Color.WHITE
	canvas.draw_rect(r, palette["K"])
	canvas.draw_rect(r.grow(-2), palette["B"] * tint)
	canvas.draw_rect(Rect2(r.position + Vector2(2, 2), Vector2(r.size.x - 4, 2)), palette["L"] * tint)
	canvas.draw_rect(Rect2(r.position + Vector2(2, r.size.y - 4), Vector2(r.size.x - 4, 2)), palette["D"] * tint)


# Pergamino con marco de madera (paneles de resultado).
static func parchment(canvas: CanvasItem, r: Rect2) -> void:
	var palette := SpriteFactory.PALETTE
	canvas.draw_rect(r, palette["K"])
	canvas.draw_rect(r.grow(-2), palette["B"])
	canvas.draw_rect(r.grow(-6), palette["K"])
	canvas.draw_rect(r.grow(-8), palette["S"])
	canvas.draw_rect(r.grow(-12), palette["W"])


# Estrella grande (16x16 a x2): dorada si está conseguida; si no, del color
# "empty" (oscura sobre pergamino, gris sobre madera).
static func star(canvas: CanvasItem, center: Vector2, earned: bool, empty: String = "D") -> void:
	sprite(canvas, tinted("star", "Y" if earned else empty), center)


# Estrella pequeña (8x8 a x2), para el marcador.
static func small_star(canvas: CanvasItem, center: Vector2, earned: bool) -> void:
	sprite(canvas, tinted("star_small", "Y" if earned else "A"), center)


# Barra de progreso con marco; "ratio" entre 0 y 1.
static func progress_bar(canvas: CanvasItem, r: Rect2, ratio: float, fill: Color) -> void:
	var palette := SpriteFactory.PALETTE
	canvas.draw_rect(r, palette["K"])
	var inner := r.grow(-2)
	canvas.draw_rect(inner, palette["D"])
	canvas.draw_rect(Rect2(inner.position, Vector2(inner.size.x * clampf(ratio, 0.0, 1.0), inner.size.y)), fill)

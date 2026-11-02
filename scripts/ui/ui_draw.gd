class_name UiDraw
extends RefCounted

# Elementos de interfaz comunes a varias pantallas. Se llaman desde el _draw
# del nodo que los pinta ("canvas").


static func wood_button(canvas: CanvasItem, r: Rect2, label: String, font_size: int = 15) -> void:
	var palette := SpriteFactory.PALETTE
	canvas.draw_rect(r, palette["K"])
	canvas.draw_rect(r.grow(-2), palette["L"])
	canvas.draw_rect(Rect2(r.position + Vector2(2, r.size.y - 6), Vector2(r.size.x - 4, 4)), palette["B"])
	canvas.draw_string(ThemeDB.fallback_font, r.position + Vector2(0, r.size.y / 2.0 + 5), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, font_size, palette["K"])

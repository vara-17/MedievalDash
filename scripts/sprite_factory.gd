class_name SpriteFactory
extends RefCounted

# Paleta fija de 16 colores. "." = transparente. "X" = color de tinte (se pasa al crear el sprite).
const PALETTE := {
	"K": Color("1b1722"),
	"D": Color("3b2a2a"),
	"B": Color("6b4226"),
	"L": Color("a8703a"),
	"S": Color("e8b98a"),
	"R": Color("b8352f"),
	"O": Color("e07a2f"),
	"Y": Color("f2cc4e"),
	"G": Color("4a7a3a"),
	"N": Color("8fb55a"),
	"U": Color("2f4f8f"),
	"C": Color("5fa3d8"),
	"P": Color("6a4c93"),
	"W": Color("f1ead8"),
	"A": Color("8a8d99"),
	"Z": Color("c9ccd6"),
}
const SCALE := 2.0

static var _cache: Dictionary = {}


static func make(sprite_name: String, tints: Dictionary = {}) -> ImageTexture:
	if tints.is_empty() and _cache.has(sprite_name):
		return _cache[sprite_name]
	var rows: Array = SpriteData.rows(sprite_name)
	if rows.is_empty():
		push_error("Sprite no encontrado: %s" % sprite_name)
		return null
	var w := 0
	for r in rows:
		w = maxi(w, String(r).length())
	var img := Image.create(w, rows.size(), false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in rows.size():
		var row: String = rows[y]
		if row.length() != w:
			push_warning("Sprite '%s' fila %d: mide %d y deberia medir %d" % [sprite_name, y, row.length(), w])
		for x in row.length():
			var ch := row[x]
			if ch == ".":
				continue
			if tints.has(ch):
				img.set_pixel(x, y, tints[ch])
			elif PALETTE.has(ch):
				img.set_pixel(x, y, PALETTE[ch])
			else:
				push_warning("Sprite '%s': letra desconocida '%s'" % [sprite_name, ch])
	var tex := ImageTexture.create_from_image(img)
	if tints.is_empty():
		_cache[sprite_name] = tex
	return tex


static func rect_centered(tex: Texture2D, center: Vector2) -> Rect2:
	var size := tex.get_size() * SCALE
	return Rect2(center - size / 2.0, size)

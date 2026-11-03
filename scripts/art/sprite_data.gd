class_name SpriteData
extends RefCounted

# Cada letra es un color de SpriteFactory.PALETTE. "." = transparente. "X" = tinte.

static func rows(sprite_name: String) -> Array:
	match sprite_name:
		"waiter":
			return [
				"................",
				"....KKKKKKKK....",
				"...KDDDDDDDDK...",
				"...KDSSSSSSDK...",
				"...KSKSSSSKSK...",
				"...KSSSSSSSSK...",
				"...KSDDDDDDSK...",
				"....KSSSSSSK....",
				"...KUUUUUUUUK...",
				"..KUUWWWWWWUUK..",
				"..KUUWWWWWWUUK..",
				"..KSUWWWWWWUSK..",
				"...KKWWWWWWKK...",
				"....KWWWWWWK....",
				"....KBBKKBBK....",
				"....KKKKKKKK....",
			]
		"customer":
			return [
				"................",
				"....KKKKKKKK....",
				"...KYYYYYYYYK...",
				"...KYSSSSSSYK...",
				"...KSKSSSSKSK...",
				"...KSSSSSSSSK...",
				"...KSSSRRSSSK...",
				"....KSSSSSSK....",
				"...KXXXXXXXXK...",
				"..KXXXXXXXXXXK..",
				"..KXXXXXXXXXXK..",
				"..KSXXXXXXXXSK..",
				"...KKXXXXXXKK...",
				"....KXXXXXXK....",
				"....KBBKKBBK....",
				"....KKKKKKKK....",
			]
		"mug":
			return [
				"KKKKKK..",
				"KWWWWK..",
				"KXXXXKKK",
				"KXXXXK.K",
				"KXXXXK.K",
				"KXXXXKKK",
				"KXXXXK..",
				"KKKKKK..",
			]
		"table":
			return _table()
		"potion":
			return [
				"................",
				"......KKKK......",
				"......KLLK......",
				"......KKKK......",
				"......KZZK......",
				"......KZZK......",
				".....KKZZKK.....",
				"....KZZZZZZK....",
				"...KRRRRRRRRK...",
				"...KRWRRRRRRK...",
				"...KRWRRRRRRK...",
				"...KRRRRRRRRK...",
				"...KRRRRRRRRK...",
				"....KRRRRRRK....",
				".....KKKKKK.....",
				"................",
			]
		"herbs":
			return [
				"................",
				"....K.....K.....",
				"...KNK...KNK....",
				"...KNGK.KGNK..K.",
				"....KNGKGNK..KNK",
				".K...KNGNK..KNGK",
				"KNK..KGNGK.KGNK.",
				"KGNKKNGNGNKGNK..",
				".KGNNGNGNGNNK...",
				"..KKGNGNGNKK....",
				"....KYYYYK......",
				".....KBBK.......",
				".....KBBK.......",
				".....KBBK.......",
				".....KKKK.......",
				"................",
			]
		"bandage":
			return [
				"................",
				"................",
				"................",
				"....KKKKKKK.....",
				"...KWWWWWWWK....",
				"..KWZWWWWWWWK...",
				"..KWZWWKKWWWK...",
				"..KWZWKAAKWWK...",
				"..KWZWKAAKWWK...",
				"..KWZWWKKWWWKKKK",
				"..KWZWWWWWWWWWWK",
				"...KWWWWWWWKKKKK",
				"....KKKKKKK.....",
				"................",
				"................",
				"................",
			]
		"healer":
			return _recolor(rows("waiter"), {"U": "C", "D": "Y"})
		"stretcher":
			return _stretcher(false)
		"stretcher_patient":
			return _stretcher(true)
		"innkeeper":
			return _recolor(rows("waiter"), {"U": "G", "D": "B"})
		"bed":
			return _bed(1, "made", 0)
		"bed_unmade":
			return _bed(1, "unmade", 0)
		"bed_sleep":
			return _bed(1, "sleep", 1)
		"bed_double":
			return _bed(2, "made", 0)
		"bed_double_unmade":
			return _bed(2, "unmade", 0)
		"bed_double_sleep1":
			return _bed(2, "sleep", 1)
		"bed_double_sleep2":
			return _bed(2, "sleep", 2)
		"bed_icon":
			return [
				"................",
				"................",
				"................",
				"KK..............",
				"KLK.............",
				"KLK.KKKKK.......",
				"KLKKWWWWWKKKKKK.",
				"KLKWWWWWKXXXXXXK",
				"KLKXXXXXXXXXXXXK",
				"KLKXXXXXXXXXXXXK",
				"KLKKKKKKKKKKKKKK",
				"KLKBBBBBBBBBBBBK",
				"KLKKKKKKKKKKKKKK",
				"KBK..........KBK",
				"KKK..........KKK",
				"................",
			]
		"floor_wood":
			return [
				"BBBBBBBBBBBDBBBB",
				"BBDBBBBBBBBDBBBB",
				"BBBBBBBBBBBDBBDB",
				"DDDDDDDDDDDDDDDD",
				"BBBDBBBBBBBBBBBB",
				"BBBDBBBBLBBBBBBB",
				"BBBDBBBBBBBBBBBB",
				"DDDDDDDDDDDDDDDD",
				"BBBBBBBDBBBBBBBB",
				"BBBBBBBDBBBBBDBB",
				"BLBBBBBDBBBBBBBB",
				"DDDDDDDDDDDDDDDD",
				"BBBBBBBBBBBBBBBD",
				"BBBBBDBBBBBBBBBD",
				"BBBBBBBBBBBLBBBD",
				"DDDDDDDDDDDDDDDD",
			]
		"wall_stone":
			return [
				"ZZZZZZZKZZZZZZZK",
				"ZAAAAAAKZAAAAAAK",
				"ZAAAAAAKZAAAAZAK",
				"ZAAAAAAKZAAAAAAK",
				"ZAAZAAAKZAAAAAAK",
				"ZAAAAAAKZAAAAAAK",
				"ZAAAAAAKZAAAAAAK",
				"KKKKKKKKKKKKKKKK",
				"ZZZKZZZZZZZKZZZZ",
				"AAAKZAAAAAAKZAAA",
				"AAAKZAAAAAAKZAAA",
				"AAAKZAAAZAAKZAAA",
				"AZAKZAAAAAAKZAAA",
				"AAAKZAAAAAAKZAAA",
				"AAAKZAAAAAAKZAAA",
				"KKKKKKKKKKKKKKKK",
			]
		"wall_base":
			return [
				"KKKKKKKKKKKKKKKK",
				"LLLLLLLLLLLLLLLL",
				"BBBBBBBBBBBBBBBB",
				"DDDDDDDDDDDDDDDD",
			]
		"torch":
			return [
				"................",
				".......X........",
				"......XX........",
				"......XXX.......",
				".....XXYXX......",
				".....XYYYX......",
				".....XYWYX......",
				"......XYX.......",
				".....KAAAK......",
				"......KBK.......",
				"......KBK.......",
				"......KBK.......",
				"....KAAAAAK.....",
				"....KAKBKAK.....",
				"....KAAAAAK.....",
				"....KKKKKKK.....",
			]
		"window":
			return [
				"................",
				".....KKKKK......",
				"....KBBBBBK.....",
				"...KBUUBUUBK....",
				"..KBUUUBUUUBK...",
				"..KBUYUBUUUBK...",
				"..KBUUUBUUUBK...",
				"..KBBBBBBBBBK...",
				"..KBUUUBUUYBK...",
				"..KBUUUBUUUBK...",
				"..KBUUUBUUUBK...",
				"..KBUUUBUUUBK...",
				"..KBBBBBBBBBK...",
				".KLLLLLLLLLLLK..",
				".KKKKKKKKKKKKK..",
				"................",
			]
		"banner":
			return _banner()
		"house":
			return _house()
		"tree":
			return [
				"................",
				".....KKKKK......",
				"...KKGGGGGKK....",
				"..KGGNNGGGGGK...",
				".KGNNNGGGGNGGK..",
				".KGNNGGGGNNNGK..",
				".KGGGGGNGGNGGK..",
				".KGGNGGGGGGGGK..",
				"..KGGGGGNGGGK...",
				"...KKGGGGGKK....",
				".....KKBBKK.....",
				"......KBBK......",
				"......KBBK......",
				"......KBBK......",
				".....KBBBBK.....",
				"................",
			]
		"sword":
			return [
				".......KK.......",
				"......KZZK......",
				"......KZAK......",
				"......KZAK......",
				"......KZAK......",
				"......KZAK......",
				"......KZAK......",
				"......KZAK......",
				"......KZAK......",
				"......KZAK......",
				"...KKKKKKKKKK...",
				"...KYYYYYYYYK...",
				"...KKKKBBKKKK...",
				"......KBBK......",
				"......KYYK......",
				"......KKKK......",
			]
		"smith":
			return [
				"................",
				"....KKKKKKKK....",
				"...KOOOOOOOOK...",
				"...KOSSSSSSOK...",
				"...KSKSSSSKSK...",
				"...KSSSSSSSSK...",
				"...KOOSSSSOOK...",
				"....KOOOOOOK....",
				"...KRRRRRRRRK...",
				"..KRRBBBBBBRRK..",
				"..KRRBBBBBBRRK..",
				"..KSRBBBBBBRSK..",
				"...KKBBBBBBKK...",
				"....KBBBBBBK....",
				"....KDDKKDDK....",
				"....KKKKKKKK....",
			]
		"shield":
			return [
				"................",
				"..KKKKKKKKKKKK..",
				"..KAAAAAAAAAAK..",
				"..KABBBRRBBBAK..",
				"..KABBBRRBBBAK..",
				"..KABRRRRRRBAK..",
				"..KABRRRRRRBAK..",
				"..KABBBRRBBBAK..",
				"..KABBBRRBBBAK..",
				"...KABBRRBBAK...",
				"...KABBRRBBAK...",
				"....KABBBBAK....",
				".....KABBAK.....",
				"......KAAK......",
				".......KK.......",
				"................",
			]
		"helmet":
			return [
				"................",
				"................",
				".....KKKKKK.....",
				"....KZZZZZAK....",
				"...KZZZZZZAAK...",
				"..KZZZZZZZAAAK..",
				"..KZZZZZZZAAAK..",
				"..KAAAAAAAAAAK..",
				"..KZAKKKKKKAAK..",
				"..KZAZZAZZAAAK..",
				"..KZAZZAZZAAAK..",
				"..KZAZZAZZAAAK..",
				"..KAAAAAAAAAAK..",
				"..KKKKKKKKKKKK..",
				"................",
				"................",
			]
		"anvil":
			return [
				"................",
				"................",
				"................",
				"................",
				"..KKKKKKKKKKKK..",
				"KKAZZZZZZZZZZAK.",
				".KKAAAAAAAAAAK..",
				"...KKAAAAAAKK...",
				".....KAAAAK.....",
				".....KAAAAK.....",
				"....KAAAAAAK....",
				"...KAAAAAAAAK...",
				"...KKKKKKKKKK...",
				"..KBBBBBBBBBBK..",
				"..KBDBBBBBDBBK..",
				"..KKKKKKKKKKKK..",
			]
		"floor_stone":
			return [
				"ZZZZZZZZZZZZZZZK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAZAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAZAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAZAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"ZAAAAAAAAAAAAAAK",
				"KKKKKKKKKKKKKKKK",
			]
		"star":
			return [
				"................",
				".......KK.......",
				"......KXXK......",
				"......KXXK......",
				".....KXWXXK.....",
				"KKKKKXXXXXXKKKKK",
				"KXXXXXXXXXXXXXXK",
				".KXXXXXXXXXXXXK.",
				"..KXXXXXXXXXXK..",
				"...KXXXXXXXXK...",
				"...KXXXXXXXXK...",
				"..KXXXXKKXXXXK..",
				"..KXXXK..KXXXK..",
				".KXXKK....KKXXK.",
				".KKK........KKK.",
				"................",
			]
		"star_small":
			return [
				"...KK...",
				"..KXXK..",
				"KKKXXKKK",
				"KXXXXXXK",
				".KXXXXK.",
				".KXXXXK.",
				"KXXKKXXK",
				"KKK..KKK",
			]
		"coin":
			return [
				"..KKKK..",
				".KYYYYK.",
				"KYWYYYOK",
				"KYYOYYOK",
				"KYYOYYOK",
				"KYYYYYOK",
				".KOOOOK.",
				"..KKKK..",
			]
		"hourglass":
			return [
				"KKKKKKKK",
				".KWWWWK.",
				"..KYYK..",
				"...KK...",
				"..KWWK..",
				".KWYYWK.",
				".KYYYYK.",
				"KKKKKKKK",
			]
		"lock":
			return [
				"................",
				"................",
				".....KKKKKK.....",
				"....KAAAAAAK....",
				"....KAKKKKAK....",
				"....KAK..KAK....",
				"....KAK..KAK....",
				"...KKKKKKKKKK...",
				"...KYYYYYYYYK...",
				"...KYYYKKYYYK...",
				"...KYYYKKYYYK...",
				"...KYYYYYYYYK...",
				"...KOOOOOOOOK...",
				"...KKKKKKKKKK...",
				"................",
				"................",
			]
		"barrel":
			return [
				"................",
				"....KKKKKKKK....",
				"...KBLLBBLLBK...",
				"..KAAAAAAAAAAK..",
				"..KBLLBBBLLBBK..",
				".KBLLBBBBLLBBBK.",
				".KBLLBBBBLLBBBK.",
				".KAAAAAAAAAAAAK.",
				".KBLLBBBBLLBBBK.",
				".KBLLBBBBLLBBBK.",
				"..KBLLBBBLLBBK..",
				"..KAAAAAAAAAAK..",
				"...KBLLBBLLBK...",
				"....KKKKKKKK....",
				"................",
				"................",
			]
		"door":
			return _door()
		"bar":
			return _bar()
	return []


# Casa de 24x22 para el mapa: tejado de color X, paredes encaladas con vigas,
# dos ventanas con luz y puerta.
static func _house() -> Array:
	var rows: Array = []
	for i in 9:
		var pad := ".".repeat(11 - i)
		rows.append(pad + "K" + "X".repeat(i * 2) + "K" + pad)
	rows.append_array([
		"..KKKKKKKKKKKKKKKKKKKK..",
		"...KWWWWWWWWWWWWWWWWK...",
		"...KBWWWWWWWWWWWWWWBK...",
		"...KBWKKKKWWWWKKKKWBK...",
		"...KBWKUYKWWWWKUUKWBK...",
		"...KBWKUUKWWWWKYUKWBK...",
		"...KBWKKKKWWWWKKKKWBK...",
		"...KBBBBBBBBBBBBBBBBK...",
		"...KBWWWWKKKKKKWWWWBK...",
		"...KBWWWWKBBBBKWWWWBK...",
		"...KBWWWWKBBYBKWWWWBK...",
		"..KKKKKKKKKKKKKKKKKKKK..",
	])
	return rows


# Estandarte de 16x24 colgado de una barra, con un rombo dorado y cola de golondrina.
static func _banner() -> Array:
	var plain := "..KXXXXXXXXXXK.."
	var rows: Array = ["KAAAAAAAAAAAAAAK"]
	for i in 5:
		rows.append(plain)
	rows.append_array([
		"..KXXXXYYXXXXK..",
		"..KXXXYYYYXXXK..",
		"..KXXYYYYYYXXK..",
		"..KXXXYYYYXXXK..",
		"..KXXXXYYXXXXK..",
	])
	for i in 10:
		rows.append(plain)
	rows.append_array([
		"..KXXXXKKXXXXK..",
		"..KXXXK..KXXXK..",
		"..KKKK....KKKK..",
	])
	return rows


static func _table() -> Array:
	var rows: Array = []
	rows.append(".." + "K".repeat(28) + "..")
	for i in range(1, 15):
		var fill := "L"
		if i == 4 or i == 8 or i == 13:
			fill = "B"
		elif i == 14:
			fill = "D"
		rows.append(".K" + fill.repeat(28) + "K.")
	rows.append("." + "K".repeat(30) + ".")
	for i in 3:
		rows.append(".." + "KDDK" + ".".repeat(20) + "KDDK" + "..")
	rows.append(".." + "KKKK" + ".".repeat(20) + "KKKK" + "..")
	return rows


# Copia de un sprite cambiando unas letras por otras ({"U": "G"}).
static func _recolor(source: Array, swaps: Dictionary) -> Array:
	var result: Array = []
	for row in source:
		var r := ""
		for ch in String(row):
			r += swaps.get(ch, ch)
		result.append(r)
	return result


# Cama vista desde arriba, 24 de alto: cabecero, almohadas, manta (X) y pie.
# capacity 1 = 16 de ancho y una almohada; 2 = 26 de ancho y dos.
# state: "made" (sábana doblada), "sleep" (cabezas en la almohada, manta
# subida) o "unmade" (manta arrugada y apartada).
static func _bed(capacity: int, state: String, sleepers: int) -> Array:
	var w := 26 if capacity > 1 else 16
	var inner := w - 4
	var pillows: Array = [Vector2i(1, 10)] if capacity == 1 else [Vector2i(1, 9), Vector2i(12, 9)]
	var heads: Array = []
	if sleepers == 1:
		heads.append(floori(inner / 2.0) - 3)
	elif sleepers == 2:
		for pw in pillows:
			heads.append(pw.x + floori(pw.y / 2.0) - 3)
	var head_rows := ["?YYYY?", "YYYYYY", "YSSSSY", "SKSSKS", "SSSSSS"]
	var rows: Array = ["K".repeat(w), "K" + "L".repeat(w - 2) + "K", "K" + "B".repeat(w - 2) + "K"]
	for y in range(3, 22):
		var row := ""
		for x in inner:
			var ch := "Z"
			if y <= 7:
				var shift := 1 if state == "unmade" else 0
				for pw in pillows:
					if x >= pw.x + shift and x < pw.x + pw.y + shift and y >= 4 and y <= 6:
						ch = "A" if y == 6 else "W"
			else:
				match state:
					"made":
						ch = "W" if y <= 9 else "X"
					"sleep":
						ch = "X"
					_:
						# Manta apartada en diagonal hacia los pies.
						ch = "X" if x < floori((y - 8) * inner / 10.0) + 2 else "Z"
						if ch == "Z" and (x + y) % 7 == 0:
							ch = "A"
			for hx in heads:
				if y >= 3 and y <= 7 and x >= hx and x < hx + 6:
					var h: String = head_rows[y - 3][x - hx]
					if h != "?":
						ch = h
			row += ch
		rows.append("KB" + row + "BK")
	rows.append("K" + "B".repeat(w - 2) + "K")
	rows.append("K".repeat(w))
	return rows


# Camilla de 16x26 vista desde arriba: dos varas con asas y lona. Con
# paciente: cabeza sobre la lona y manta (X) hasta el cuello.
static func _stretcher(patient: bool) -> Array:
	var head_rows := ["?YYYY?", "YYYYYY", "YSSSSY", "SKSSKS", "SSSSSS"]
	var rows: Array = []
	for y in 26:
		var inner := ""
		if y < 2 or y > 23:
			inner = ".".repeat(10)
		elif y == 2 or y == 23:
			inner = "K".repeat(10)
		else:
			for x in 10:
				var ch := "W" if x > 0 and x < 9 else "Z"
				if patient:
					if y >= 3 and y <= 7 and x >= 2 and x < 8:
						var h: String = head_rows[y - 3][x - 2]
						if h != "?":
							ch = h
					elif y >= 8:
						ch = "X"
				elif y >= 3 and y <= 5 and x >= 2 and x < 8:
					ch = "Z"
				inner += ch
		rows.append(".KB" + inner + "BK.")
	return rows


# Puerta de 16x32: arco de madera con dos bandas de hierro y tirador.
static func _door() -> Array:
	var planks := "K" + "LBB".repeat(4) + "LBK"
	var band := "K" + "A".repeat(14) + "K"
	var rows: Array = [
		"....KKKKKKKK....",
		"..KKLBBLBBLBKK..",
		".KLBBLBBLBBLBBK.",
	]
	for y in range(3, 31):
		if y == 8 or y == 24:
			rows.append(band)
		elif y == 17:
			rows.append("K" + "LBBLBBLBBLB" + "YY" + "BK")
		else:
			rows.append(planks)
	rows.append("K".repeat(16))
	return rows


# Barra de la taberna, 48x36: encimera clara y frente de paneles de madera.
static func _bar() -> Array:
	var rows: Array = ["K".repeat(48)]
	for y in 3:
		rows.append("K" + ("W" if y == 0 else "L").repeat(46) + "K")
	rows.append("K".repeat(48))
	for y in range(5, 32):
		var row := "K"
		for x in range(1, 47):
			var col := (x - 1) % 23
			if col == 0 or col == 22 or y == 7 or y == 29:
				row += "D"
			elif col == 1 or y == 8:
				row += "L"
			else:
				row += "B"
		rows.append(row + "K")
	for y in 3:
		rows.append("K" + "D".repeat(46) + "K")
	rows.append("K".repeat(48))
	return rows

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

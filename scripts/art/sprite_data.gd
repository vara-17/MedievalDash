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

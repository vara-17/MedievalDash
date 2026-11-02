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
	return []


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

extends RefCounted

class_name AsepriteOldPaletteChunk

var _colors: Array

static func parse(parser: AsepriteParser) -> AsepriteOldPaletteChunk:
	var chunk := AsepriteOldPaletteChunk.new()
	var packets = parser.word()
	var index = 0
	chunk._colors = []
	for i in range(packets):
		var skip = parser.byte()
		var num = parser.byte()
		if num == 0:
			num = 256
		index += skip
		for j in range(num):
			var c = {}
			c.index = index
			c.r = parser.byte()
			c.g = parser.byte()
			c.b = parser.byte()
			chunk._colors.append(c)
			index += 1
	return chunk

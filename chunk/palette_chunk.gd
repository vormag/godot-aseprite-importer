extends RefCounted

class_name AsepritePaletteChunk

var _new_size: int
var _first: int
var _last: int
var _colors: Array

static func parse(parser: AsepriteParser) -> AsepritePaletteChunk:
	var chunk := AsepritePaletteChunk.new()
	chunk._new_size = parser.dword()
	chunk._first = parser.dword()
	chunk._last = parser.dword()
	parser.skip_bytes(8)
	var count = chunk._last - chunk._first + 1
	chunk._colors = []
	for i in range(count):
		var c = {}
		c.flags = parser.word()
		c.r = parser.byte()
		c.g = parser.byte()
		c.b = parser.byte()
		c.a = parser.byte()
		if c.flags & 1 != 0:
			c.name = parser.string()
		chunk._colors.append(c)
	return chunk

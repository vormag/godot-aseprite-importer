extends RefCounted

class_name AsepriteCelExtraChunk

var _flags: int
var _precise_x: float
var _precise_y: float
var _width: float
var _height: float

static func parse(parser: AsepriteParser) -> AsepriteCelExtraChunk:
	var chunk := AsepriteCelExtraChunk.new()
	chunk._flags = parser.dword()
	chunk._precise_x = parser.fixed()
	chunk._precise_y = parser.fixed()
	chunk._width = parser.fixed()
	chunk._height = parser.fixed()
	parser.skip_bytes(16)
	return chunk

extends RefCounted

class_name AsepriteMaskChunk

var _x: int
var _y: int
var _width: int
var _height: int
var _name: String
var _bitmap: PackedByteArray

static func parse(parser: AsepriteParser) -> AsepriteMaskChunk:
	var chunk := AsepriteMaskChunk.new()
	chunk._x = parser.short()
	chunk._y = parser.short()
	chunk._width = parser.word()
	chunk._height = parser.word()
	parser.skip_bytes(8)
	chunk._name = parser.string()
	var bytes = int((chunk._width + 7) / 8) * chunk._height
	chunk._bitmap = parser.file.get_buffer(bytes)
	return chunk

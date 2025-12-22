extends RefCounted

class_name AsepriteUserDataChunk

var _flags: int
var _text: String
var _color: Dictionary
var _raw: PackedByteArray

static func parse(parser: AsepriteParser) -> AsepriteUserDataChunk:
	var chunk := AsepriteUserDataChunk.new()
	chunk._flags = parser.dword()
	if chunk._flags & 1 != 0:
		chunk._text = parser.string()
	if chunk._flags & 2 != 0:
		chunk._color = {
			"r": parser.byte(),
			"g": parser.byte(),
			"b": parser.byte(),
			"a": parser.byte()
		}
	if chunk._flags & 4 != 0:
		var size = parser.dword()
		var maps = parser.dword()
		var remaining = size - 8
		if remaining > 0:
			chunk._raw = parser.file.get_buffer(remaining)
	return chunk

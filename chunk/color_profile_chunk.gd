extends RefCounted

class_name AsepriteColorProfileChunk

var _type: int
var _flags: int
var _gamma: float
var _icc: PackedByteArray

static func parse(parser: AsepriteParser) -> AsepriteColorProfileChunk:
	var chunk := AsepriteColorProfileChunk.new()
	chunk._type = parser.word()
	chunk._flags = parser.word()
	chunk._gamma = parser.fixed()
	parser.skip_bytes(8)
	if chunk._type == 2:
		var size = parser.dword()
		chunk._icc = parser.file.get_buffer(size)
	return chunk

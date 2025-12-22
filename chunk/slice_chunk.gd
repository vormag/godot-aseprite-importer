extends RefCounted

class_name AsepriteSliceChunk

var _key_count: int
var _flags: int
var _name: String
var _keys: Array

static func parse(parser: AsepriteParser) -> AsepriteSliceChunk:
	var chunk := AsepriteSliceChunk.new()
	chunk._key_count = parser.dword()
	chunk._flags = parser.dword()
	parser.skip_bytes(4)
	chunk._name = parser.string()
	chunk._keys = []
	for i in range(chunk._key_count):
		var k = {}
		k.frame = parser.dword()
		k.x = parser.long()
		k.y = parser.long()
		k.width = parser.dword()
		k.height = parser.dword()
		if chunk._flags & 1 != 0:
			k.center_x = parser.long()
			k.center_y = parser.long()
			k.center_width = parser.dword()
			k.center_height = parser.dword()
		if chunk._flags & 2 != 0:
			k.pivot_x = parser.long()
			k.pivot_y = parser.long()
		chunk._keys.append(k)
	return chunk

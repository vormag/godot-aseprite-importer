extends RefCounted

class_name AsepriteExternalFilesChunk

var _entries: Array

static func parse(parser: AsepriteParser) -> AsepriteExternalFilesChunk:
	var chunk := AsepriteExternalFilesChunk.new()
	var count = parser.dword()
	parser.skip_bytes(8)
	chunk._entries = []
	for i in range(count):
		var e = {}
		e.id = parser.dword()
		e.type = parser.byte()
		parser.skip_bytes(7)
		e.name = parser.string()
		chunk._entries.append(e)
	return chunk

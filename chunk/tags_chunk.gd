extends RefCounted

class_name AsepriteTagsChunk

var _tags: Array

static func parse(parser: AsepriteParser) -> AsepriteTagsChunk:
	var chunk := AsepriteTagsChunk.new()
	var count = parser.word()
	parser.skip_bytes(8)
	chunk._tags = []
	for i in range(count):
		var t: AsepriteTag = AsepriteTag.new()
		t.from = parser.word()
		t.to = parser.word()
		t.direction = parser.byte()
		t.repeat = parser.word() != 0
		parser.skip_bytes(6)
		
		t.color = Color(
			parser.byte(),
			parser.byte(),
			parser.byte()
		)
		parser.skip_bytes(1)
		t.name = parser.string()
		chunk._tags.append(t)
	return chunk

class AsepriteTag extends RefCounted:
	
	var name: String
	var from: int
	var to: int
	var direction: int
	var repeat: bool
	var color: Color

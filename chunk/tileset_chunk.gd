extends RefCounted

class_name AsepriteTilesetChunk

var _id: int
var _flags: int
var _tile_count: int
var _tile_width: int
var _tile_height: int
var _base_index: int
var _name: String
var _external_file_id: int
var _external_tileset_id: int
var _compressed: PackedByteArray

static func parse(parser: AsepriteParser) -> AsepriteTilesetChunk:
	var chunk := AsepriteTilesetChunk.new()
	chunk._id = parser.dword()
	chunk._flags = parser.dword()
	chunk._tile_count = parser.dword()
	chunk._tile_width = parser.word()
	chunk._tile_height = parser.word()
	chunk._base_index = parser.short()
	parser.skip_bytes(14)
	chunk._name = parser.string()
	if chunk._flags & 1 != 0:
		chunk._external_file_id = parser.dword()
		chunk._external_tileset_id = parser.dword()
	if chunk._flags & 2 != 0:
		var size = parser.dword()
		chunk._compressed = parser.file.get_buffer(size)
	return chunk

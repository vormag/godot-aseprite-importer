extends RefCounted

class_name AsepriteCelChunk

const CEL_TYPE_RAW        = 0
const CEL_TYPE_LINKED     = 1
const CEL_TYPE_COMPRESSED = 2
const CEL_TYPE_TILEMAP    = 3

const CEL_Z_DEFAULT = 0

var _layer_index: int
var _x: int
var _y: int
var _opacity: int
var _cel_type: int
var _z_index: int
var _width: int
var _height: int
var _raw: PackedByteArray
var _linked_frame: int
var _compressed: PackedByteArray
var _tiles: PackedByteArray
var _bits_per_tile: int
var _bitmask_id: int
var _bitmask_xflip: int
var _bitmask_yflip: int
var _bitmask_diag: int

static func parse(parser: AsepriteParser, chunk_end: int) -> AsepriteCelChunk:	
	var chunk := AsepriteCelChunk.new()
	chunk._layer_index = parser.word()
	chunk._x = parser.short()
	chunk._y = parser.short()
	chunk._opacity = parser.byte()
	chunk._cel_type = parser.word()
	chunk._z_index = parser.short()
	parser.skip_bytes(5)
	
	match chunk._cel_type:
		0:
			var w = parser.word()
			var h = parser.word()
			var bpp = 1
			if parser.header._color_depth == 32:
				bpp = 4
			elif parser.header._color_depth == 16:
				bpp = 2
			chunk._width = w
			chunk._height = h
			var size = w * h * bpp
			chunk._raw = parser.file.get_buffer(size)
		
		1:
			chunk._linked_frame = parser.word()
		
		2:
			var w2 = parser.word()
			var h2 = parser.word()
			chunk._width = w2
			chunk._height = h2
			var remaining = chunk_end - parser.file.get_position()
			if remaining > 0:
				chunk._compressed = parser.file.get_buffer(remaining)
		
		3:
			chunk._width = parser.word()
			chunk._height = parser.word()
			chunk._bits_per_tile = parser.word()
			chunk._bitmask_id = parser.dword()
			chunk._bitmask_xflip = parser.dword()
			chunk._bitmask_yflip = parser.dword()
			chunk._bitmask_diag = parser.dword()
			parser.skip_bytes(10)
			var remaining2 = chunk_end - parser.file.get_position()
			if remaining2 > 0:
				chunk._tiles = parser.file.get_buffer(remaining2)
	
	return chunk

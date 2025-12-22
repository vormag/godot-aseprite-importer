extends RefCounted

class_name AsepriteLayerChunk

const LAYER_VISIBLE               = 1
const LAYER_EDITABLE              = 2
const LAYER_LOCK_MOVEMENT         = 4
const LAYER_BACKGROUND            = 8
const LAYER_PREFER_LINKED_CELS    = 16
const LAYER_GROUP_COLLAPSED       = 32
const LAYER_REFERENCE             = 64

const LAYER_TYPE_NORMAL   = 0
const LAYER_TYPE_GROUP    = 1
const LAYER_TYPE_TILEMAP  = 2

const BLEND_NORMAL        = 0
const BLEND_MULTIPLY      = 1
const BLEND_SCREEN        = 2
const BLEND_OVERLAY       = 3
const BLEND_DARKEN        = 4
const BLEND_LIGHTEN       = 5
const BLEND_COLOR_DODGE   = 6
const BLEND_COLOR_BURN    = 7
const BLEND_HARD_LIGHT    = 8
const BLEND_SOFT_LIGHT    = 9
const BLEND_DIFFERENCE    = 10
const BLEND_EXCLUSION     = 11
const BLEND_HUE           = 12
const BLEND_SATURATION    = 13
const BLEND_COLOR         = 14
const BLEND_LUMINOSITY    = 15
const BLEND_ADDITION      = 16
const BLEND_SUBTRACT      = 17
const BLEND_DIVIDE        = 18

var _flags: int
var _layer_type: int
var _child_level: int
var _default_width: int
var _default_height: int
var _blend_mode: int
var _opacity: int
var _name: String
var _tileset_index: int
var _uuid: PackedByteArray

func is_visible() -> bool:
	return (_flags & LAYER_VISIBLE) != 0

static func parse(parser: AsepriteParser) -> AsepriteLayerChunk:
	var chunk: = AsepriteLayerChunk.new()
	chunk._flags = parser.word()
	chunk._layer_type = parser.word()
	chunk._child_level = parser.word()
	chunk._default_width = parser.word()
	chunk._default_height = parser.word()
	chunk._blend_mode = parser.word()
	chunk._opacity = parser.byte()
	parser.skip_bytes(3)
	chunk._name = parser.string()
	if chunk._layer_type == 2:
		chunk._tileset_index = parser.dword()
	if parser.header != null and (parser.header._flags & 4) != 0:
		chunk._uuid = parser.uuid()
	return chunk

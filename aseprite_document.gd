class_name AsepriteDocument

extends Resource

const CHUNK_OLD_PALETTE_A = 0x0004
const CHUNK_OLD_PALETTE_B = 0x0011
const CHUNK_LAYER          = 0x2004
const CHUNK_CEL            = 0x2005
const CHUNK_CEL_EXTRA      = 0x2006
const CHUNK_COLOR_PROFILE  = 0x2007
const CHUNK_EXTERNAL_FILES = 0x2008
const CHUNK_MASK           = 0x2016
const CHUNK_PATH           = 0x2017
const CHUNK_TAGS           = 0x2018
const CHUNK_PALETTE        = 0x2019
const CHUNK_USER_DATA      = 0x2020
const CHUNK_SLICE          = 0x2022
const CHUNK_TILESET        = 0x2023

var header: AsepriteHeader
var frames: Array = []

func get_layer_image(frame_index: int, layer: AsepriteLayerChunk) -> Image:
	var layer_index = 0
	for chunk in _get_layer_chunks():
		if chunk == layer:
			break
		layer_index += 1
	
	var frame: AsepriteFrame = frames[frame_index]
	var cel: AsepriteCelChunk = null
	for chunk in frame.chunks:
		if chunk._chunk_data is AsepriteCelChunk and chunk._chunk_data._layer_index == layer_index:
			cel = chunk._chunk_data
			break
			
	if cel == null:
		return null
	
	return decode_cel(cel)

func decode_cel(cel: AsepriteCelChunk) -> Image:
	var depth = header._color_depth
	match cel._cel_type:
		AsepriteCelChunk.CEL_TYPE_RAW:
			return decode_raw_pixels(cel, depth)
		AsepriteCelChunk.CEL_TYPE_COMPRESSED:
			var raw = cel._compressed.decompress(
				cel._width * cel._height * get_bpp(),
				FileAccess.CompressionMode.COMPRESSION_DEFLATE
			)
			return decode_raw_buffer(raw, cel, depth)
		AsepriteCelChunk.CEL_TYPE_LINKED:
			pass
		AsepriteCelChunk.CEL_TYPE_TILEMAP:
			pass
	return Image.create(header._width, header._height, false, Image.FORMAT_RGBA8)

func get_tags() -> Array:
	var result: Array = []
	for frame: AsepriteFrame in frames:
		for chunk in frame.chunks:
			if chunk._chunk_type == CHUNK_TAGS:
				var data: AsepriteTagsChunk = chunk._chunk_data
				result.append_array(data._tags)
	return result

func get_bpp() -> int:
	match header._color_depth:
		32: return 4
		16: return 2
		8: return 1
	return 4

func get_palette_color(index: int) -> Color:
	var palette: AsepritePaletteChunk = null
	var old_palette: AsepriteOldPaletteChunk = null
	for frame in frames:
		for chunk in frame.chunks:
			if chunk is AsepritePaletteChunk:
				palette = chunk
			elif chunk is AsepriteOldPaletteChunk:
				old_palette = chunk
	if palette != null:
		return palette.get_color(index)
	if old_palette != null:
		return old_palette.get_color(index)
	var v = clamp(index, 0, 255) / 255.0
	return Color(v, v, v, 1.0)

func decode_raw_pixels(cel: AsepriteCelChunk, depth: int) -> Image:
	var raw := cel._raw
	return decode_raw_buffer(raw, cel, depth)

func decode_raw_buffer(raw: PackedByteArray, cel: AsepriteCelChunk, depth: int) -> Image:
	var img := Image.create(header._width, header._height, false, Image.FORMAT_RGBA8)
	var i = 0
	for y in range(cel._height):
		for x in range(cel._width):
			var color: Color
			match depth:
				32:
					var r = raw[i]; var g = raw[i+1]; var b = raw[i+2]; var a = raw[i+3]
					color = Color8(r, g, b, a)
					i += 4
				16:
					var v = (raw[i] | (raw[i+1] << 8))
					var c = v / 255.0
					color = Color(c, c, c, 1)
					i += 2
				8:
					var index = raw[i]
					color = get_palette_color(index)
					i += 1
			
			var px = x + cel._x
			var py = y + cel._y
			if px < 0 or py < 0 or px >= header._width or py >= header._height:
				continue
			img.set_pixel(px, py, color)
	return img

func get_frames_count() -> int:
	return header._frames

func get_top_level_groups() -> Array:
	var groups = []
	for chunk: AsepriteLayerChunk in _get_layer_chunks():
		if chunk._child_level == 0 and chunk._layer_type == AsepriteLayerChunk.LAYER_TYPE_GROUP:
			groups.append(chunk)
	
	return groups

func get_layer(layer_name: String) -> AsepriteLayerChunk:
	for chunk: AsepriteLayerChunk in _get_layer_chunks():
		if chunk._layer_type == AsepriteLayerChunk.LAYER_TYPE_NORMAL and chunk._name == layer_name:
			return chunk
	
	return null

func get_layers_in_group(group: AsepriteLayerChunk) -> Array:
	var layers = []
	var in_group = false
	for chunk: AsepriteLayerChunk in _get_layer_chunks():
		if chunk._layer_type == AsepriteLayerChunk.LAYER_TYPE_GROUP:
			in_group = group == chunk
		if not in_group:
			continue
		if chunk._child_level == 1 and chunk._layer_type == AsepriteLayerChunk.LAYER_TYPE_NORMAL:
			layers.append(chunk)
	
	return layers
	
func get_unique_layer_names() -> Array:
	var layers = []
	for chunk: AsepriteLayerChunk in _get_layer_chunks():
		if chunk._layer_type == AsepriteLayerChunk.LAYER_TYPE_NORMAL \
			and chunk._name not in layers:
			layers.append(chunk._name)

	return layers

func _get_layer_chunks() -> Array:
	var layers = []
	for frame in frames:
		for chunk in frame.chunks:
			if chunk._chunk_type == CHUNK_LAYER:
				var data: AsepriteLayerChunk = chunk._chunk_data
				layers.append(data)
	return layers

class AsepriteHeader extends RefCounted:
	
	var _file_size
	var _frames
	var _width
	var _height
	var _color_depth
	var _flags
	var _speed
	var _palette_entry
	var _colors
	var _pixel_width
	var _pixel_height
	var _grid_x
	var _grid_y
	var _grid_width
	var _grid_height
	
	
class AsepriteFrame extends RefCounted:
	var _bytes
	var _chunks_old
	var _duration
	var _chunks_new

	var chunks = []
	
class AsepriteChunk extends RefCounted:
	var _chunk_size
	var _chunk_type
	var _chunk_data

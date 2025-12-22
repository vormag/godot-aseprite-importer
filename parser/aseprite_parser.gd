extends RefCounted

class_name AsepriteParser

const MAGIC_HEADER = 0xA5E0
const MAGIC_FRAME = 0xF1FA

var file: FileAccess
var header: AsepriteDocument.AsepriteHeader

static func parse(location: String) -> AsepriteDocument:
	var parser: AsepriteParser = AsepriteParser.new()
	parser.file = FileAccess.open(location, FileAccess.READ)
	
	var document = AsepriteDocument.new()
	document.header = parser.parse_header()
	for ind in document.header._frames:
		document.frames.append(parser.parse_frame())
	
	return document
	
func parse_frame() -> AsepriteDocument.AsepriteFrame:
	var frame := AsepriteDocument.AsepriteFrame.new()
	frame._bytes = dword()
	assert(word() == MAGIC_FRAME)
	frame._chunks_old = word()
	frame._duration = word()
	skip_bytes(2)
	frame._chunks_new = dword()
	
	var chunk_number = frame._chunks_new
	if chunk_number == 0:
		chunk_number = frame._chunks_old

	for ind in chunk_number:
		frame.chunks.append(parse_chunk())
	
	return frame
	
func parse_chunk() -> AsepriteDocument.AsepriteChunk:
	var chunk := AsepriteDocument.AsepriteChunk.new()
	chunk._chunk_size = dword()
	chunk._chunk_type = word()

	# FIXME: temporarily skip
	var data_start = file.get_position()
	var data_size = chunk._chunk_size - 6
	var data_end = data_start + data_size
	
	match chunk._chunk_type:
		AsepriteDocument.CHUNK_LAYER:
			chunk._chunk_data = AsepriteLayerChunk.parse(self)
		AsepriteDocument.CHUNK_CEL:
			chunk._chunk_data = AsepriteCelChunk.parse(self, data_end)
		AsepriteDocument.CHUNK_CEL_EXTRA:
			chunk._chunk_data = AsepriteCelExtraChunk.parse(self)
		AsepriteDocument.CHUNK_COLOR_PROFILE:
			chunk._chunk_data = AsepriteColorProfileChunk.parse(self)
		AsepriteDocument.CHUNK_EXTERNAL_FILES:
			chunk._chunk_data = AsepriteExternalFilesChunk.parse(self)
		AsepriteDocument.CHUNK_MASK:
			chunk._chunk_data = AsepriteMaskChunk.parse(self)
		AsepriteDocument.CHUNK_TAGS:
			chunk._chunk_data = AsepriteTagsChunk.parse(self)
		AsepriteDocument.CHUNK_PALETTE:
			chunk._chunk_data = AsepritePaletteChunk.parse(self)
		AsepriteDocument.CHUNK_USER_DATA:
			chunk._chunk_data = AsepriteUserDataChunk.parse(self)
		AsepriteDocument.CHUNK_SLICE:
			chunk._chunk_data = AsepriteSliceChunk.parse(self)
		AsepriteDocument.CHUNK_TILESET:
			chunk._chunk_data = AsepriteTilesetChunk.parse(self)
		AsepriteDocument.CHUNK_OLD_PALETTE_A, AsepriteDocument.CHUNK_OLD_PALETTE_B:
			chunk._chunk_data = AsepriteOldPaletteChunk.parse(self)
		_:
			skip_bytes(data_size)
	
	return chunk

func parse_header() -> AsepriteDocument.AsepriteHeader:
	var header := AsepriteDocument.AsepriteHeader.new()
	header._file_size = dword()
	assert(word() == MAGIC_HEADER)
	header._frames = word()
	header._width = word()
	header._height = word()
	header._color_depth = word()
	header._flags = dword()
	header._speed = word()
	assert(dword() == 0)
	assert(dword() == 0)
	header._palette_entry = byte()
	skip_bytes(3)
	header._colors = word()
	header._pixel_width = byte()
	header._pixel_height = byte()
	header._grid_x = short()
	header._grid_y = short()
	header._grid_width = word()
	header._grid_height = word()
	skip_bytes(84)
	assert(file.get_position() == 128)
	
	self.header = header
	return header

func dword() -> int:
	return file.get_32() & 0xFFFFFFFF

func word() -> int:
	return file.get_16() & 0xFFFF
	
func short() -> int:
	var v := file.get_16()
	if v & 0x8000:
		v -= 0x10000
	return v
	
func byte() -> int:
	return file.get_8() & 0xFF
	
func skip_bytes(count: int) -> void:
	var new_pos := file.get_position() + count
	if new_pos > file.get_length():
		new_pos = file.get_length()
	
	file.seek(new_pos)

func long() -> int:
	var v := file.get_32()
	if v & 0x80000000:
		v -= 0x100000000
	return v

func qword() -> int:
	return file.get_64()

func long64() -> int:
	return file.get_64()

func fixed() -> float:
	var raw := file.get_32()
	if raw & 0x80000000:
		raw -= 0x100000000
	return raw / 65536.0

func float32() -> float:
	return file.get_float()

func double() -> float:
	return file.get_double()

func string() -> String:
	var length := word()
	if length <= 0:
		return ""
	var bytes := file.get_buffer(length)
	return bytes.get_string_from_utf8()

func uuid() -> PackedByteArray:
	return file.get_buffer(16)

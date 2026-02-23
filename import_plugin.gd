@tool
extends EditorImportPlugin

func _get_importer_name():
	return "vormag.aseprite"

func _get_visible_name():
	return "Aseprite Animation"

func _get_recognized_extensions():
	return ["ase", "aseprite"]

func _get_save_extension():
	return "res"

func _get_resource_type():
	return "Resource"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var document: AsepriteDocument = AsepriteParser.parse(source_file)
	var texture: Texture2D = _build_single_frame_texture(document)
	if texture != null:
		return ResourceSaver.save(texture, "%s.%s" % [save_path, _get_save_extension()])

	var animation: AsepriteAnimation = _build_animation(document)
	return ResourceSaver.save(animation, "%s.%s" % [save_path, _get_save_extension()])

func _build_single_frame_texture(document: AsepriteDocument) -> Texture2D:
	var layers: Array = document.get_unique_layer_names()
	var image_frame_count: int = 0
	var image_frame_index: int = -1

	for frame_index: int in range(document.frames.size()):
		var has_image: bool = false
		for layer_name: String in layers:
			if layer_name.begins_with("ref"):
				continue
			var layer: AsepriteLayerChunk = document.get_layer(layer_name)
			var layer_image: Image = document.get_layer_image(frame_index, layer)
			if layer_image != null:
				has_image = true
				break

		if has_image:
			image_frame_count += 1
			image_frame_index = frame_index
			if image_frame_count > 1:
				return null

	if image_frame_count == 0:
		return null

	var merged_image: Image = Image.create(
		document.header._width,
		document.header._height,
		false,
		Image.FORMAT_RGBA8
	)

	for layer_name: String in layers:
		if layer_name.begins_with("ref"):
			continue
		var layer: AsepriteLayerChunk = document.get_layer(layer_name)
		var layer_image: Image = document.get_layer_image(image_frame_index, layer)
		if layer_image == null:
			continue
		merged_image.blend_rect(
			layer_image,
			Rect2i(0, 0, layer_image.get_width(), layer_image.get_height()),
			Vector2i.ZERO
		)

	return ImageTexture.create_from_image(merged_image)

func _build_animation(document: AsepriteDocument) -> AsepriteAnimation:
	var animation: AsepriteAnimation = AsepriteAnimation.new()

	animation.size = Vector2(
		document.header._width,
		document.header._height
	)
	animation.layers = []
	animation.animations = []
	animation.frame_durations = []
	animation.frame_positions = {}
	animation.textures = {}
	for frame: AsepriteDocument.AsepriteFrame in document.frames:
		animation.frame_durations.append(frame._duration)

	for layer_name: String in document.get_unique_layer_names():
		if not layer_name.begins_with("ref"):
			animation.layers.append(layer_name)

	for tag: AsepriteTagsChunk.AsepriteTag in document.get_tags():
		animation.animations.append(tag.name)
		animation.frame_positions[tag.name] = [tag.from, tag.to]

	var empty_image: Image = Image.create(
		animation.size.x,
		animation.size.y,
		false,
		Image.FORMAT_RGBA8
	)
	var empty_image_texture: ImageTexture = ImageTexture.create_from_image(empty_image)

	for layer_name: String in animation.layers:
		var layer: AsepriteLayerChunk = document.get_layer(layer_name)
		for tag: AsepriteTagsChunk.AsepriteTag in document.get_tags():
			var animation_name: String = tag.name
			var textures: Array = []
			for frame_index: int in range(tag.from, tag.to + 1):
				var image: Image = document.get_layer_image(frame_index, layer)
				var texture: Texture2D = ImageTexture.create_from_image(image) if image else empty_image_texture
				textures.append(texture)

			animation.textures["%s/%s" % [layer_name, animation_name]] = textures

	return animation

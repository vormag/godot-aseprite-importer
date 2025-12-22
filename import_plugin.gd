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
	for _frame: AsepriteDocument.AsepriteFrame in document.frames:
		animation.frame_durations.append(_frame._duration)
	
	for _layer: String in document.get_unique_layer_names():
		if not _layer.begins_with("ref"):
			animation.layers.append(_layer)

	for tag: AsepriteTagsChunk.AsepriteTag in document.get_tags():
		animation.animations.append(tag.name)
		animation.frame_positions[tag.name] = [tag.from, tag.to]

	var empty_image = Image.create(
		animation.size.x, 
		animation.size.y, 
		false, 
		Image.FORMAT_RGBA8
	)
	var empty_image_texture: ImageTexture = ImageTexture.create_from_image(empty_image)

	for layer_name: String in animation.layers:
		var layer: AsepriteLayerChunk = document.get_layer(layer_name)
		for tag: AsepriteTagsChunk.AsepriteTag in document.get_tags():
			var animation_name = tag.name
			var textures = []
			for frame_index in range(tag.from, tag.to + 1):
				var image = document.get_layer_image(frame_index, layer)
				var texture: Texture2D = ImageTexture.create_from_image(image) if image else empty_image_texture
				textures.append(texture)
			
			animation.textures["%s/%s" % [layer_name, animation_name]] = textures
		
	return ResourceSaver.save(animation, "%s.%s" % [save_path, _get_save_extension()])

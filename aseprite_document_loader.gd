class_name AsepriteDocumentLoader

extends ResourceFormatLoader

func _handles_type(type: StringName) -> bool:
	return type == "Resource"

func _get_recognized_extensions() -> PackedStringArray:
	return ["aseprite", "ase"]
	
func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	return AsepriteParser.parse(path)

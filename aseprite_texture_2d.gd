@tool
@icon("res://addons/aseprite_importer/icon/aseprite_animation.svg")
extends Texture2D

class_name AsepriteTexture2D

@export
var texture: Texture2D

@export
var layer_names: Array[String] = []

@export
var layer_textures: Dictionary = {}

func get_layer_names() -> Array[String]:
	return layer_names

func get_layer_texture(layer_name: String) -> Texture2D:
	return layer_textures.get(layer_name) as Texture2D

func _get_width() -> int:
	return texture.get_width()

func _get_height() -> int:
	return texture.get_height()

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	texture.draw(to_canvas_item, pos, modulate, transpose)

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)

func _has_alpha() -> bool:
	return texture.has_alpha()

func _is_pixel_opaque(x: int, y: int) -> bool:
	var image: Image = texture.get_image()
	return image.get_pixel(x, y).a > 0.0

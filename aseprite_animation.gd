extends Resource

class_name AsepriteAnimation

@export
var textures: Dictionary
@export
var size: Vector2
@export
var layers: Array
@export
var animations: Array
@export
var frame_durations: Array
@export
var frame_positions: Dictionary

func get_textures(layer, animation) -> Array:
	return textures["%s/%s" % [layer, animation]]

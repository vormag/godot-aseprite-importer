# Aseprite Importer for Godot 4

Aseprite Importer is a Godot Engine extension that enables seamless import and management of Aseprite (.ase/.aseprite) files directly within your Godot projects. Extension is based on a format specification and does not require any command line tools, including aseprite to be installed and configured.
Extension is low level, with the main goal being to import aseprite animations as a custom resource called `AsepriteAnimation`. Constructing AnimatedSprite2D based on this is not included.

## Features
- **Aseprite File Parsing**: Supports .ase and .aseprite formats. You can use `AsepriteParser.parse` to get a full document.
- **Animation Import**: Automatically imports Aseprite animations as AsepriteAnimation resources. Use "preload" or assign through UI to "@export"ed properties.

## Installation
1. **Copy Files**: Place all files and folders from this repository into your Godot project's `addons/aseprite_importer` directory. Alternatively use git submodules.
2. **Enable Plugin**: In Godot, go to `Project > Project Settings > Plugins` and enable the "Aseprite Importer" plugin.

## Usage
1. **Import Aseprite Files**: Drag and drop your `.ase` or `.aseprite` files into your Godot project.
2. **Automatic Conversion**: The importer will automatically import files to AsepriteAnimation resources.
3. **Low level usage**: If you only want to use AsepriteParser, you can keep plugin disabled.

## Examples

### Single layer called "default"

```gdscript
extends Node2D

@export var ase: AsepriteAnimation          # drag the .tres here in the inspector
@export var layer_name: String = "default"  # set to one of ase.layers (often the aseprite layer name)

func _ready() -> void:
	var spr := AnimatedSprite2D.new()
	var sf := SpriteFrames.new()

    # Animations are "tags" in Aseprite
	for anim_name: String in ase.animations:
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, 1.0) # irrelevant if you don't use AnimatedSprite2D.play()

		for tex: Texture2D in ase.get_textures(layer_name, anim_name):
			sf.add_frame(anim_name, tex)

	spr.sprite_frames = sf

	spr.animation = ase.animations[0] if ase.animations.size() > 0 else ""
	spr.frame = 0
	add_child(spr)
```
### Multilayer

You can stack multiple `AnimatedSprite2D` on top of one another. This is especially useful if you want to control different colthing/items, and show/hide them depending on what is selected. You will need to synchronize in this case either through `Timer` or `frame_changed` signal.

```gdscript
extends Node2D

@export var ase: AsepriteAnimation

func _ready() -> void:
	for layer in ase.layers:
		var spr := AnimatedSprite2D.new()
		var frames := SpriteFrames.new()

		for anim in ase.animations:
			frames.add_animation(anim)
			for tex in ase.get_textures(layer, anim):
				frames.add_frame(anim, tex)

		spr.name = layer
		spr.sprite_frames = frames
		spr.animation = ase.animations[0]
		spr.frame = 0
		add_child(spr)
```

## Supported Chunks
- Layer
- Cel
- Palette
- Tags
- Slices
- Tileset
- Color Profile
- User Data
- Mask
- External Files

## Contribution
You can add support for additional Aseprite features by creating new chunk parsers in the `chunk/` directory and updating the main parser logic in `parser/aseprite_parser.gd`. A lot of parser code is AI generated, GenAI actually understands binary protocols pretty well, you can feed it oficial spec and ask to add new features when they arrive.

Feel free to fork, and create pull requests.

## Requirements
- **Godot Engine 4.x**
- **Aseprite** for asset creation, not needed for import.

## Contributing
Pull requests and issues are welcome! Please follow Godot and GDScript best practices.

## License
This extension is released under the MIT License. See [LICENSE](LICENSE.md) for details.

## Links
- [Aseprite File Format Documentation](https://github.com/aseprite/aseprite/blob/main/docs/ase-file-spec.md)
- [Godot Engine Documentation](https://docs.godotengine.org/)

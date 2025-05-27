extends TextureButton

@export_enum("Start Animation", "Visibility Toggle", "Change Scene") var buttonAction: int
@export_file() var targetScene: String
@export var targetNode: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_pressed() -> void:
	match buttonAction:
		0: # animation
			pass
		1: # menu visibility toggle
			targetNode.visible = !targetNode.visible
		2: # level transition
			pass

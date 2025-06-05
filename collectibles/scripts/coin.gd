extends Node2D

@export var coinValue : int = 1
@onready var anim : AnimationPlayer = $AnimationPlayer
var canCollect = true

func _ready() -> void:
	anim.play(("idle"))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerPuck and canCollect:
		anim.play("collect")
		EventController.emit_signal("coin_collected", coinValue)

func toggle_canCollect():
	canCollect = !canCollect

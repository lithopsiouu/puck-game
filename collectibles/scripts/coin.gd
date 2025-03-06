extends Node2D

@export var coinValue : int = 1
@onready var anim : AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerPuck:
		anim.play("collect")
		GameController.coin_collected(coinValue)
		anim.animation_finished

extends Node2D

@export var coinValue : int = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerPuck:
		GameController.coin_collected(coinValue)
		self.queue_free()

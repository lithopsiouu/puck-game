extends Node2D

var totalCoins : int = 0

func coin_collected(value: int):
	totalCoins += value
	EventController.emit_signal("coin_collected", totalCoins)

func wall_hurt(targetTile: RID, puckPos):
	
	EventController.emit_signal("wall_hurt", targetTile, puckPos)

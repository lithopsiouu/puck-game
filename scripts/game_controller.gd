extends Node2D

var totalCoins : int = 0

func coin_collected(value: int):
	totalCoins += value
	EventController.emit_signal("coin_collected", totalCoins)

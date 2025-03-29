extends Node2D

@export_enum("Exit", "Gem", "Timed") var winCondition: int
@export var time: int = 60

var totalCoins : int = 0
var totalGems : int = 0

func _ready() -> void:
	EventController.emit_signal("send_gamemode", winCondition)
	if winCondition == 2:
		EventController.emit_signal("send_timer", time)

func coin_collected(value: int):
	totalCoins += value
	EventController.emit_signal("coin_collected", totalCoins)

func gem_smashed():
	totalGems += 1
	EventController.emit_signal("gem_smashed", totalGems)

func wall_hurt(targetTile: RID, puckPos):
	EventController.emit_signal("wall_hurt", targetTile, puckPos)

func get_total_coins() -> int:
	return totalCoins

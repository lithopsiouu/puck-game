extends Node2D

@export_enum("Exit", "Gem", "Timed") var winCondition: int
@export var time: int = 60
@export var coinHolder : Node

var totalCoins : int = 0
var collectedCoins : int = 0
var totalGems : int = 0

func _ready() -> void:
	EventController.emit_signal("send_gamemode", winCondition)
	if coinHolder != null: 
		totalCoins = get_total_coins()
		EventController.emit_signal("send_total_coins", totalCoins)
	EventController.connect("game_win", reset_stuff)
	if winCondition == 2:
		EventController.emit_signal("send_timer", time)

func reset_stuff() -> void:
	collectedCoins = 0
	totalGems = 0

func coin_collected(value: int):
	collectedCoins += value
	EventController.emit_signal("coin_collected", collectedCoins)

func gem_smashed():
	totalGems += 1
	EventController.emit_signal("gem_smashed", totalGems)

func wall_hurt(targetTile: RID, puckPos):
	EventController.emit_signal("wall_hurt", targetTile, puckPos)

func _get_coinHolder() -> Node2D:
	return find_child("CoinHolder")

func get_total_coins() -> int:
	return coinHolder.get_child_count()

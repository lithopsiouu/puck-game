extends Node2D

var save_path = "user://puck_save_data.puck"

@export_enum("Exit", "Gem", "Timed") var winCondition: int
@export var time: int = 60
@export var coinHolder : Node

var wins = 0
var totalCoins : int = 0
var coinsCollected : int = 0
var totalGems : int = 0

func _ready() -> void:
	EventController.emit_signal("send_gamemode", winCondition)
	EventController.connect("game_win", _on_game_win)
	EventController.connect("reset_game_shit", reset_stuff)
	EventController.connect("coin_collected", coin_collected)
	if winCondition == 2:
		EventController.emit_signal("send_timer", time)
	
	if coinHolder != null: 
		totalCoins = get_total_coins()
	EventController.emit_signal("send_total_coins", totalCoins)
	#EventController.connect("total_coins_from_screen_effects", set_totalCoins)
	EventController.connect("save_level_stats", save_stats)

# called on nextLevelButton press
func reset_stuff() -> void:
	coinsCollected = 0
	totalGems = 0

func coin_collected(value: int):
	coinsCollected += value
	#print("coins: " + str(coinsCollected) + "| max: " + str(totalCoins))
	#EventController.emit_signal("coin_collected", coinsCollected)

func gem_smashed():
	totalGems += 1
	EventController.emit_signal("gem_smashed", totalGems)

func _get_coinHolder() -> Node2D:
	return find_child("CoinHolder")

func get_total_coins() -> int:
	return coinHolder.get_child_count()

func set_totalCoins(coins: int):
	totalCoins = coins

func _on_game_win():
	pass

func save_stats():
	print("---attempting save...---")
	#print("save attempt: " + str(saves))
	print("--- saving... ---")
	#print(str(coinsCollected) + " and " + str(totalCoins))
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var levelName = str(get_tree().get_current_scene().scene_file_path)
	var levelInt = levelName.to_int()
	# string.get_csv_line("\:")
	var data_to_save = [levelInt, totalCoins == coinsCollected]
	var json_string = JSON.stringify(data_to_save)
	file.store_string(json_string)
	file.close()
	print("---saving done.---")
	#printerr("---already saved.---")

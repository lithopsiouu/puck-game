extends Node2D

var save_path = "user://level_scores"
var configSuffix = ".cfg"
@onready var recordTime = self.get_meta("TimeScore")

@export_enum("Exit", "Gem", "Timed") var winCondition: int
@export var time: int = 60
@export var coinHolder : Node

var wins = 0
var totalCoins : int = 0
var coinsCollected : int = 0
var totalGems : int = 0
var finalTime : float = 777777777.7

func _ready() -> void:
	EventController.emit_signal("send_gamemode", winCondition)
	EventController.connect("game_win", _on_game_win)
	EventController.connect("reset_game_shit", reset_stuff)
	EventController.connect("coin_collected", coin_collected)
	EventController.connect("send_final_time", _set_final_time)
	EventController.connect("restart_level", restart_level)
	if winCondition == 2:
		EventController.emit_signal("send_timer", time)
	
	if coinHolder != null: 
		totalCoins = get_total_coins()
	EventController.emit_signal("send_total_coins", totalCoins)
	#EventController.connect("total_coins_from_screen_effects", set_totalCoins)
	EventController.connect("save_level_stats", _save_stats)

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

func _set_final_time(newFinalTime: float):
	finalTime = newFinalTime
	print("final time: " + str(finalTime))

func _compare_final_times() -> bool:
	var answer: bool = false
	if finalTime < recordTime: answer = true
	return answer

func _save_stats(overrideBest: bool = false):
	print("--- saving... ---")
	var config = ConfigFile.new()
	var levelName = str(get_tree().get_current_scene().scene_file_path)
	var levelInt = levelName.to_int()
	config.load(save_path + configSuffix)
	config.set_value("Level" + str(levelInt), "Completed", true)
	if overrideBest:
		#print(str(coinsCollected) + " and " + str(totalCoins))
		config.set_value("Level" + str(levelInt), "MaxPoints", totalCoins == coinsCollected)
		config.set_value("Level" + str(levelInt), "BetterThanRecord", _compare_final_times())
		config.set_value("Level" + str(levelInt), "FinishTime", finalTime)
	else:
		var maxPointsValue = config.get_value("Level" + str(levelInt), "MaxPoints")
		if maxPointsValue == true: print("already achieved best score. not overriding")
		else: 
			config.set_value("Level" + str(levelInt), "MaxPoints", totalCoins == coinsCollected)
		
		if config.has_section_key("Level" + str(levelInt), "FinishTime"):
			var finishTimeValue = config.get_value("Level" + str(levelInt), "FinishTime")
			if finalTime > finishTimeValue: print("already has best score. not overriding")
			else:
				config.set_value("Level" + str(levelInt), "BetterThanRecord", _compare_final_times())
				config.set_value("Level" + str(levelInt), "FinishTime", finalTime)
		else:
			config.set_value("Level" + str(levelInt), "BetterThanRecord", _compare_final_times())
			config.set_value("Level" + str(levelInt), "FinishTime", finalTime)
	config.save(save_path + configSuffix)
	print("---saving done.---")
	#printerr("---already saved.---")

func restart_level(): get_tree().reload_current_scene()

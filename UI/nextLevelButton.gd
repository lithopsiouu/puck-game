extends Button

var levelPathPlaceholder: String = "res://scenes/Levels/lvl%s.tscn"
var currentLevelPath: String
var nextLevelPath: String

func _ready() -> void:
	_get_next_level()

func _on_pressed() -> void:
	EventController.emit_signal("reset_game_shit")
	get_tree().change_scene_to_file(nextLevelPath)

# Grabs level number and adds one to it and turns the new level number back into a filepath string
func _get_next_level() -> void:
	currentLevelPath = str(get_tree().get_current_scene().scene_file_path)
	var levelInt = currentLevelPath.to_int()
	nextLevelPath = levelPathPlaceholder % str(levelInt + 1)
	if !ResourceLoader.exists(nextLevelPath):
		nextLevelPath = "res://scenes/mainMenu.tscn"

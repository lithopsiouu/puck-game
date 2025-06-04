extends Button

var mainMenuPath: String = "res://scenes/mainMenu.tscn"

func _on_pressed() -> void:
	get_tree().change_scene_to_file(mainMenuPath)

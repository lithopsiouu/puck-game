extends Control

@onready var uiAnims: AnimationPlayer = $AnimationPlayer
@onready var settingsButtons = $SettingsButtons
@onready var levelSelect = $LevelSelect
@onready var mainButtons = $MainButtons
@onready var credits = $Credits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_play_button_pressed() -> void:
	levelSelect.visible = true
	mainButtons.visible = false
	uiAnims.play("levelSelect_enter")


func _on_settings_button_pressed() -> void:
	uiAnims.play("disk_enter")
	mainButtons.visible = false

func _on_credits_button_pressed() -> void:
	credits.visible = true
	uiAnims.play("credits_enter")


func _on_exit_button_pressed() -> void:
	#get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"disk_enter":
			settingsButtons.visible = true
		"credits_enter":
			#mainButtons.visible = false
			pass
		"disk_exit":
			mainButtons.visible = true
		"levelSelect_exit":
			levelSelect.visible = false
			mainButtons.visible = true
		"credits_exit":
			credits.visible = false
		"all_disappear":
			get_tree().change_scene_to_file("res://scenes/Levels/lvl1.tscn")

func _on_settings_exit_button_pressed() -> void:
	settingsButtons.visible = false
	uiAnims.play("disk_exit")

func _on_level_exit_button_pressed() -> void:
	uiAnims.play("levelSelect_exit")

func _on_credits_exit_button_pressed() -> void:
	#mainButtons.visible = true
	uiAnims.play("credits_exit")

func _on_quick_play_button_pressed() -> void:
	uiAnims.play("all_disappear")

func _on_level_select_button_pressed() -> void:
	uiAnims.play("all_disappear")

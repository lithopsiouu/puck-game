extends Control


@onready var uiAnims: AnimationPlayer = $AnimationPlayer
@onready var settingsButtons = $SettingsButtons
@onready var levelSelect = $LevelSelect
@onready var mainButtons = $MainButtons
@onready var credits = $Credits
@onready var distFilter = $MainButtons/Distortion

# level selection
@onready var levelTitleLabel = $LevelSelect/LevelSelectPanel/LevelTitleLabel
@onready var levelNumberLabel = $LevelSelect/LevelSelectPanel/NumericalLevelPanel/LevelNumberLabel
var levelPathEmpty: String = "res://scenes/Levels/lvl%s.tscn"
var levelInt := 1
var level_data_path = "user://level_info_data.puck"
var levelNames := ["first steps", "a cage of stone", "hedge walk", "first gems"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_level_names()

func _initialize_level_names():
	if not FileAccess.file_exists(level_data_path):
		print("names file does not exist. writing now")
		var levelNamesFile = FileAccess.open(level_data_path, FileAccess.WRITE)
		for i in range(levelNames.size()):
			var json_string = JSON.stringify(levelNames[i])
			levelNamesFile.store_line(json_string.replace("\"", "") + "\r")
		levelNamesFile.close()
	else:
		print("names file exists")

func _change_level(level: int):
	level = clampi(level, 1, levelNames.size())
	print("level changing to: " + str(level))
	levelTitleLabel.text = _get_level_name(level)
	levelNumberLabel.text = str(level)
	levelInt = level

func _get_level_name(line: int) -> String:
	var levelNamesFile = FileAccess.open(level_data_path, FileAccess.READ)
	var _name = ""
	for i in line:
		_name = levelNamesFile.get_line()
	if _name == "":
		_name = "777"
	levelNamesFile.close()
	return _name

func _on_play_button_pressed() -> void:
	levelSelect.visible = true
	mainButtons.visible = false
	levelTitleLabel.text = _get_level_name(levelInt)
	levelNumberLabel.text = str(levelInt)
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
			get_tree().change_scene_to_file(levelPathEmpty % str(levelInt))

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

func _on_test_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(distFilter.material, "shader_parameter/strength", 0, 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

func _on_left_level_scroll_pressed() -> void:
	_change_level(levelInt -1)

func _on_right_level_scroll_pressed() -> void:
	_change_level(levelInt +1)

extends Control

@onready var whitePanel = $White
var whiteBorderStyle = preload("res://UI/white_border_blend.tres")
var greenBorderStyle = preload("res://UI/green_big_border_blend.tres")
@onready var blackPanel = $Black
@onready var winScrn = $WinScreen
@onready var loseScrn = $LoseScreen

@onready var finalPointsDisplay = $WinScreen/Points

@onready var finalTimeDisplay = $WinScreen/TimeBox/finalTime
@onready var timeElapsedLabel = $WinScreen/TimeBox/timeElapsedLabel
@onready var timeLeftLabel = $WinScreen/TimeBox/timeLeftLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("game_win", winProcess)
	EventController.connect("get_current_time", display_time)
	EventController.connect("send_gamemode", set_timeBox_label)
	EventController.connect("coin_collected", _on_event_coin_collected)
	EventController.connect("gem_smashed", _on_event_gem_smashed)

func winProcess() -> void:
	green_border_flash()
	Engine.time_scale = 0.4# reset this before switching scenes!
	await fade_in_white(1)
	Engine.time_scale = 1
	await get_tree().create_timer(0.5).timeout
	winScrn.visible = true

func loseProcess() -> void:
	Engine.time_scale = 0.5
	fade_in_black(1)

func set_timeBox_label(gamemode: int) -> void:
	if gamemode != 2:
		timeElapsedLabel.visible = true
	else:
		timeLeftLabel.visible = true

func display_time(time: float) -> void:
	var msec = fmod(time, 1) * 100
	var seconds = fmod(time, 60)
	var minutes = fmod(time, 3600) / 60
	
	finalTimeDisplay.text = "%02d:%02d.%03d" % [minutes, seconds, msec]

func _on_event_coin_collected(value: int) -> void:
	finalPointsDisplay.text = str(value)
	white_border_flash()

func _on_event_gem_smashed() -> void:
	green_border_flash()

func fade_in_black(speed: int):
	blackPanel.visible = true
	blackPanel.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(blackPanel, "modulate:a", 1, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)#.set_delay(1)
	await tween.finished

func fade_out_black(speed: int):
	blackPanel.visible = true
	blackPanel.modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(blackPanel, "modulate:a", 0, speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)#.set_delay(1)
	await tween.finished
	blackPanel.visible = false

func fade_in_white(speed: int):
	whitePanel.visible = true
	whitePanel.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(whitePanel, "modulate:a", 1, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)#.set_delay(1)
	await tween.finished

func fade_out_white(speed: int):
	whitePanel.visible = true
	whitePanel.modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(whitePanel, "modulate:a", 0, speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)#.set_delay(1)
	await tween.finished
	whitePanel.visible = false

func white_border_flash():
	var tween = get_tree().create_tween()
	var whiteBorderPanel = Panel.new()
	add_child(whiteBorderPanel)
	whiteBorderPanel.add_theme_stylebox_override("panel", whiteBorderStyle)
	whiteBorderPanel.mouse_filter = 2
	whiteBorderPanel.set_anchors_preset(PRESET_FULL_RECT, true)
	tween.tween_property(whiteBorderPanel, "modulate:a", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)#.set_delay(1)
	await tween.finished
	whiteBorderPanel.queue_free()

func green_border_flash():
	var tween = get_tree().create_tween()
	var greenBorderPanel = Panel.new()
	add_child(greenBorderPanel)
	greenBorderPanel.add_theme_stylebox_override("panel", greenBorderStyle)
	greenBorderPanel.mouse_filter = 2
	greenBorderPanel.set_anchors_preset(PRESET_FULL_RECT, true)
	tween.tween_property(greenBorderPanel, "modulate:a", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)#.set_delay(1)
	await tween.finished
	greenBorderPanel.queue_free()

extends Control

@onready var whitePanel = $White
@onready var blackPanel = $Black
@onready var winScrn = $WinScreen
@onready var loseScrn = $LoseScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("game_win", winProcess)

func winProcess() -> void:
	Engine.time_scale = 0.3# reset this before switching scenes!
	await fade_in_white(1)
	Engine.time_scale = 1
	await get_tree().create_timer(1).timeout
	winScrn.visible = true

func loseProcess() -> void:
	Engine.time_scale = 0.5
	fade_in_black(1)

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

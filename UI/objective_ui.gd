extends Control

@onready var gemLabel = $GemObjective/Panel/GemsLabel
@onready var timerMins = $TimeObjective/Panel/TimerMins
@onready var timerSecs = $TimeObjective/Panel/TimerSecs
@onready var timerMsecs = $TimeObjective/Panel/TimerMilisecs
@onready var timer: Timer = $TimeObjective/Timer
@onready var timerBorder: Panel = $TimeObjective/TimerBorder
@onready var gemsBorder: Panel = $GemObjective/Panel/GemsBorder
var gamemode: int = 0
var totalGems: int = 0
var smashedGems: int = 0
# 0 = exit, 1 = gem, 2 = time

@onready var time: float = timer.time_left
var minutes: int = 0
var seconds: int = 0
var msec: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("gem_smashed", on_event_gem_smashed)
	EventController.connect("send_gamemode", recieve_gamemode)
	EventController.connect("send_timer", set_timer)
	EventController.connect("game_win", win_process)
	EventController.connect("send_total_gems", setup_gems_label)

func _physics_process(_delta: float) -> void:
	#print(timer.time_left)
	if gamemode == 2: 
		time = timer.time_left
		msec = fmod(time, 1) * 100
		seconds = fmod(time, 60)
		minutes = fmod(time, 3600) / 60
		
		timerMins.text = "| %02d" % minutes
		timerSecs.text = ":%02d" % seconds
		timerMsecs.text = ".%03d" % msec

func win_process() -> void:
	timer.paused = true
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	match gamemode:
		0:
			pass
		1:
			tween.tween_property(gemsBorder, "modulate:a", 0, 0.65).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween2.tween_property(gemsBorder, "scale", Vector2(5, 5), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		2:
			tween.tween_property(timerBorder, "modulate:a", 0, 0.65).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween2.tween_property(timerBorder, "scale", Vector2(5, 5), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func get_time_formatted() -> String:
	return "%02d:%02d.%03d" % [minutes, seconds, msec]

func set_timer(time: int):
	print(str(time))
	timer.wait_time = time
	print(str(timer.wait_time))
	timer.start()

func on_event_gem_smashed() -> void:
	smashedGems += 1
	gemLabel.text = "%02d/%02d" % [smashedGems, totalGems]
	check_gems_collected()

func recieve_gamemode(mode: int) -> void:
	gamemode = mode
	match mode:
		0: $ExitObjective.visible = true
		1: $GemObjective.visible = true
		2: $TimeObjective.visible = true

func setup_gems_label(allGems: int) -> void:
	totalGems = allGems
	gemLabel.text = "00/%02d" % totalGems

func check_gems_collected() -> void:
	if smashedGems == totalGems:
		EventController.emit_signal("game_win")

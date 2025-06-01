extends Control

@onready var timerMinsDown = $TimeObjective/Countdown/TimerMins
@onready var timerSecsDown = $TimeObjective/Countdown/TimerSecs
@onready var timerMsecsDown = $TimeObjective/Countdown/TimerMilisecs

@onready var timerMinsUp = $Elapsed/TimerMins
@onready var timerSecsUp = $Elapsed/TimerSecs
@onready var timerMsecsUp = $Elapsed/TimerMilisecs

@onready var timer: Timer = $TimeObjective/Timer

@onready var timeLeftBox : Panel = $TimeObjective/Countdown
@onready var timeElapsedBox : Panel = $Elapsed

@onready var gemLabel = $GemObjective/Panel/GemsLabel
@onready var timerBorder: Panel = $TimeObjective/TimerBorder
@onready var gemsBorder: Panel = $GemObjective/Panel/GemsBorder
var gamemode: int = 0
var totalGems: int = 0
var smashedGems: int = 0
# 0 = exit, 1 = gem, 2 = time

@onready var time: float = timer.time_left
var elapsedTime: float = 0
var time_at_start: float = 0
var time_now: float = 0
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
	time_at_start = Time.get_unix_time_from_system()
	_fade_in()

func _physics_process(_delta: float) -> void:
	#print(timer.time_left)
	if timer.paused == false:
		if gamemode == 2: 
			time = timer.time_left
			msec = fmod(time, 1) * 100
			seconds = fmod(time, 60)
			minutes = fmod(time, 3600) / 60
			
			timerMinsDown.text = "| %02d" % minutes
			timerSecsDown.text = ":%02d" % seconds
			timerMsecsDown.text = ".%03d" % msec
		else:
			time_now = Time.get_unix_time_from_system()
			var time_elapsed = time_now - time_at_start
			msec = fmod(time_elapsed, 1) * 100
			seconds = fmod(time_elapsed, 60)
			minutes = fmod(time_elapsed, 3600) / 60
			
			timerMinsUp.text = "| %02d" % minutes
			timerSecsUp.text = ":%02d" % seconds
			timerMsecsUp.text = ".%03d" % msec
			
			# confusing, but gives local elapsed time to declared elapsed time
			elapsedTime = time_elapsed

func _fade_in() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.8, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).set_delay(0.2)

# 0 = exit, 1 = gem, 2 = time
func win_process() -> void:
	timer.paused = true
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	match gamemode:
		0:
			EventController.emit_signal("get_current_time", elapsedTime)
		1:
			EventController.emit_signal("get_current_time", elapsedTime)
			tween.tween_property(gemsBorder, "modulate:a", 0, 0.65).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween2.tween_property(gemsBorder, "scale", Vector2(5, 5), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		2:
			EventController.emit_signal("get_current_time", time)
			tween.tween_property(timerBorder, "modulate:a", 0, 0.65).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween2.tween_property(timerBorder, "scale", Vector2(5, 5), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func get_time_formatted() -> String:
	return "%02d:%02d.%03d" % [minutes, seconds, msec]

func set_timer(funcTime: int):
	print(str(funcTime))
	timer.wait_time = funcTime
	print(str(timer.wait_time))
	timer.start()

func get_timer():
	return timer.time_left

func on_event_gem_smashed() -> void:
	smashedGems += 1
	gemLabel.text = "%02d/%02d" % [smashedGems, totalGems]
	check_gems_collected()

func recieve_gamemode(mode: int) -> void:
	gamemode = mode
	match mode:
		0: 
			$ExitObjective.visible = true
			timeElapsedBox.visible = true
		1: 
			$GemObjective.visible = true
			timeElapsedBox.visible = true
		2: 
			$TimeObjective.visible = true

func setup_gems_label(allGems: int) -> void:
	totalGems = allGems
	gemLabel.text = "00/%02d" % totalGems

func check_gems_collected() -> void:
	if smashedGems == totalGems:
		EventController.emit_signal("game_win")

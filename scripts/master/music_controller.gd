extends Node

@onready var bassTrack = $Bass
@onready var padsTrack = $Pads
@onready var levelsTrack = $Levels
@onready var settingsTrack = $Settings

@onready var allTrackNames = [bassTrack.name, padsTrack.name, levelsTrack.name, settingsTrack.name]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_main_menu_tracks()

func start_main_menu_tracks():
	default_main_menu_track_volumes()
	bassTrack.play()
	padsTrack.play()
	levelsTrack.play()
	settingsTrack.play()

func default_main_menu_track_volumes():
	set_track_volume(bassTrack.name, 0)
	set_track_volume(padsTrack.name, 0)
	set_track_volume(levelsTrack.name, -80)
	set_track_volume(settingsTrack.name, -80)

# tween volume of trackName to finalVolume in fadeTime seconds after playing trackName
func fade_track(trackName: String, finalVolume: int, fadeTime: float) -> void:
	var trackToUse : AudioStreamPlayer = _match_trackName(trackName)
	
	var tween = get_tree().create_tween()
	tween.tween_property(trackToUse, "volume_db", finalVolume, fadeTime)

func fade_all_tracks(finalVolume: int, fadeTime: float) -> void:
	fade_track(bassTrack.name, finalVolume, fadeTime)
	fade_track(padsTrack.name, finalVolume, fadeTime)
	fade_track(levelsTrack.name, finalVolume, fadeTime)
	fade_track(settingsTrack.name, finalVolume, fadeTime)

# set volume of trackName to trackVolume which is clamped to -80 and 24 dB
func set_track_volume(trackName: String, trackVolume: float):
	var track: AudioStreamPlayer = _match_trackName(trackName)
	trackVolume = clampf(trackVolume, -80, 24)
	
	track.volume_db = trackVolume

# set all music track volumes to -80 dB
func _mute_all_track_volumes():
	bassTrack.volume_db = -80
	padsTrack.volume_db = -80
	levelsTrack.volume_db = -80
	settingsTrack.volume_db = -80

# set all music track volumes to 0 dB
func _reset_all_track_volumes():
	bassTrack.volume_db = 0
	padsTrack.volume_db = 0
	levelsTrack.volume_db = 0
	settingsTrack.volume_db = 0

# uses the play() function on trackName
func play_track(trackName: String):
	var track: AudioStreamPlayer = _match_trackName(trackName)
	track.play()

# uses the stop() function on trackName
func stop_track(trackName: String):
	var track: AudioStreamPlayer = _match_trackName(trackName)
	track.stop()

func stop_all_tracks():
	bassTrack.stop()
	padsTrack.stop()
	levelsTrack.stop()
	settingsTrack.stop()

# return track node based on trackName string given
func _match_trackName(trackName: String) -> Node:
	trackName = trackName.to_lower()
	var trackToUse: Node
	
	match trackName:
		"bass", "bassTrack": trackToUse = bassTrack
		"pads", "padsTrack": trackToUse = padsTrack
		"levels", "levelsTrack": trackToUse = levelsTrack
		"settings", "settingsTrack": trackToUse = settingsTrack
	return trackToUse

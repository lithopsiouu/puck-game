extends Area2D

@export var speed = 5
@export var zoom = Vector2(0.9,0.9)
@export var zoomSpeedIn = 0.7
@export var zoomSpeedOut = 0.4
var startZoom: Vector2

func _on_body_entered(body: Node2D) -> void:
	cam_to_area_pos(body)
	EventController.emit_signal("player_under_cam_snap", true)

func _on_body_exited(body: Node2D) -> void:
	cam_reset_to_player_pos(body)
	EventController.emit_signal("player_under_cam_snap", false)

func lerp_new_cam_zoom(body) -> void:
	var cam: Camera2D = body.cam
	#cam.zoom.lerp(zoom, 0.8)
	var tween = get_tree().create_tween()
	tween.tween_property(cam, "zoom", zoom, zoomSpeedIn).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func lerp_exit_cam_zoom(body) -> void:
	var cam: Camera2D = body.cam
	#cam.zoom.lerp(body.defaultCamScale, 0.8)
	var tween = get_tree().create_tween()
	tween.tween_property(cam, "zoom", body.defaultCamScale, zoomSpeedOut).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func cam_to_area_pos(body) -> void:
	if body is PlayerPuck:
		if !body.ignoreCamSnap:
			lerp_new_cam_zoom(body)
			var cam: Camera2D = body.cam
			cam.position_smoothing_enabled = false
			cam.position_smoothing_speed = speed
			cam.reparent(self)
			await get_tree().create_timer(0.01).timeout
			cam = get_child(1)
			#cam.global_position = body.global_position
			cam.position_smoothing_enabled = true
			cam.zoom = zoom
			cam.global_position = global_position
			print("cam repositioned")

func cam_reset_to_player_pos(body) -> void:
	if body is PlayerPuck:
		if !body.ignoreCamSnap:
			lerp_exit_cam_zoom(body)
			var cam: Camera2D = get_child(1)
			cam.position_smoothing_enabled = false
			cam.position_smoothing_speed = body.defaultCamPosSmoothing
			cam.reparent(body)
			await get_tree().create_timer(0.01).timeout
			cam = body.cam
			cam.global_position = global_position
			cam.position_smoothing_enabled = true
			cam.zoom = body.defaultCamScale
			cam.global_position = body.global_position
			print("cam returned")

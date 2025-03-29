class_name PlayerPuck extends RigidBody2D

"""
created by connie anderson 
february 2025
"""

const speedMult = 2
const maxSpeed = 800
const camZoomSpeed = 2
const defaultCamScale = Vector2(0.9, 0.9)
const defaultCamPosSmoothing = 6
const camVelScale = 5000.0
const cam_shake_enabled = false
var cam_zoom_speed_enabled = true
const minVelToChangeCamScale = 110.0
const invertDrag = false

@onready var arrow = $Arrow
@onready var dustParticle = preload("res://particles/dust.tscn")
@onready var cam : Camera2D = $MainCamera

var mouseOnPuck = false

var ignoreCamSnap = false
var grabbingPuck = false
var mouseGrabPos = null
var mouseReleasePos = null
var mouseDragDist = 0.0
var isCamShaking : bool = false
var newCamScale : float = 0
var areaCamScale : Vector2 = Vector2.ZERO

var lastColliderRID = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("player_under_cam_snap", on_cam_snap)
	EventController.connect("game_win", on_game_win)

func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_key_pressed(KEY_W):
		#_add_puck_velocity(Vector2(100, 0))
	#elif Input.is_key_pressed(KEY_D):
		#_add_puck_velocity(Vector2(100,100))
	#elif Input.is_key_pressed(KEY_S):
		#_add_puck_velocity(Vector2(-100,0))
	
	if Input.is_action_just_pressed("PuckGrab") and !grabbingPuck:
		_set_mouse_grab_pos()
		grabbingPuck = true
		arrow.prepareArrow(mouseGrabPos)
		#print("Puck grabbed, pos: " + str(mouseGrabPos))
	elif Input.is_action_just_released("PuckGrab") and grabbingPuck:
		_set_mouse_release_pos()
		grabbingPuck = false
		_add_puck_velocity(get_dist_btwn_grabs())
		arrow.resetArrow()
		#print("Puck released, pos: " + str(mouseReleasePos))

func _physics_process(delta: float) -> void:
	if grabbingPuck == true:
		arrow.updateArrow(get_mouse_pos_relative_to_puckbody())
	
	if cam_zoom_speed_enabled: _cam_scale_from_velocity(delta)
	
	var collision := move_and_collide(linear_velocity*delta)
	if collision and collision.get_collider().get_class() == "TileMapLayer":
		if linear_velocity.length() > 600.0:
			if collision.get_collider().get("name") == "Breakable":
				_shake_cam(4, 12)
				#print("BIG camshake")
				if lastColliderRID == null:
					lastColliderRID = collision.get_collider_rid()
					GameController.wall_hurt(collision.get_collider_rid(), global_position)
					await get_tree().create_timer(0.1).timeout
					lastColliderRID = null
			else:
				_shake_cam(1, 10)
				print("medium camshake")
		elif linear_velocity.length() > 250.0:
			#_shake_cam(2, 8)
			print("small camshake")
			makeNewParticle(global_position)

func makeNewParticle(newPos : Vector2):
	var instance = dustParticle.instantiate()
	get_tree().root.add_child(instance)
	instance.position = newPos
	instance.emitting = true
	await get_tree().create_timer(1).timeout
	instance.queue_free()

func _cam_scale_from_velocity(delta: float):
	if linear_velocity.length() > minVelToChangeCamScale:
		newCamScale = linear_velocity.length() / camVelScale
		var camScaleWithVel = Vector2(defaultCamScale.x - newCamScale, defaultCamScale.y - newCamScale)
		cam.zoom = cam.zoom.lerp(camScaleWithVel, delta)
	else:
		cam.zoom = cam.zoom.lerp(defaultCamScale, delta/ camZoomSpeed)
	#print(str(cam.zoom))

func _shake_cam(multiple : float, speed : float):
	if cam_shake_enabled:
		if !isCamShaking:
			isCamShaking = true
			cam.position_smoothing_speed = speed
			cam.position = Vector2((2.5 * multiple)*randf_range(-1.1, 1.1), (3 * multiple)*randf_range(-1.1, 1.1))
			await get_tree().create_timer(0.02).timeout
			cam.position = Vector2((2 * multiple)*randf_range(-1.1, 1.1), (2 * multiple)*randf_range(-1.1, 1.1))
			await get_tree().create_timer(0.08).timeout
			cam.position = Vector2((1 * multiple)*randf_range(-1.1, 1.1), (1 * multiple)*randf_range(-1.1, 1.1))
			await get_tree().create_timer(0.1).timeout
			cam.position_smoothing_speed = defaultCamPosSmoothing
			cam.position = Vector2.ZERO
			isCamShaking = false
		else: pass#print("cam is already shaking!")

#currently unused
func _mouse_dist_from_puck():
	var puckDistToMouse = get_global_position() - get_global_mouse_position()
	return puckDistToMouse

#Sets mouseGrabPos to the position the mouse is locally at.
func _set_mouse_grab_pos():
	mouseGrabPos = get_local_mouse_position()

#Sets mouseReleasePos to the position the mouse is locally at.
func _set_mouse_release_pos():
	mouseReleasePos = get_local_mouse_position()

func get_mouse_grab_pos():
	return mouseGrabPos

func get_mouse_pos_relative_to_puckbody():
	return get_local_mouse_position()

#Subtracts the grab position from the release position, or vice versa if invertDrag is true
func get_dist_btwn_grabs() -> Vector2:
	var distance
	if !invertDrag:
		distance = (mouseGrabPos - mouseReleasePos)
	else:
		distance = (mouseReleasePos - mouseGrabPos)
	#print("drag distance: " + str(distance.length()))
	return distance

#Sets the linear_velocity property by using the distance's direction and min under maxSpeed multiplied by speedMult
func _add_puck_velocity(distance):
	var direction = distance.normalized()
	var newVelocity = direction * min(distance.length() * speedMult, maxSpeed)
	
	linear_velocity = newVelocity
	#use += for additive velocity
	
	#print(str(linear_velocity.length()))

func _on_body_entered(body: Node2D) -> void:
	if body.name.contains("Coin"):
		collect_coin(body)

func collect_coin(coin: Node2D) -> void:
	coin.queue_free()

func on_cam_snap(value: bool) -> void:
	if value: cam_zoom_speed_enabled = false
	else: cam_zoom_speed_enabled = true

func on_game_win() -> void:
	ignoreCamSnap = true
	cam_zoom_speed_enabled = false
	var tween = get_tree().create_tween()
	tween.tween_property(cam, "zoom", Vector2(0.6, 0.6), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(cam, "zoom", Vector2(2, 2), 0.9).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

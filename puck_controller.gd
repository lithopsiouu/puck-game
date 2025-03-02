class_name PlayerPuck extends RigidBody2D

"""
created by connie anderson 
february 2025
"""

const velocityScale = 5
const maxSpeed = 800
const invertDrag = false

@onready var arrow = $Arrow

var mouseOnPuck = false

var grabbingPuck = false
var mouseGrabPos = null
var mouseReleasePos = null
var mouseDragDist = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
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
	#print(str(_mouse_dist_from_puck().normalized()))
	#print("position: " + str(get_global_position()) + "mouse pos: " + str(get_global_mouse_position()))
	#print("local mouse pos: " + str(get_local_mouse_position()) + "global mouse pos: " + str(get_global_mouse_position()))
	#print(str(linear_velocity.length()))
	if grabbingPuck == true:
		arrow.updateArrow(get_mouse_pos_relative_to_puckbody())

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

#Multiplies the direction by velocityScale and applies it to the object's linear_velocity
func _add_puck_velocity(distance):
	var scaledDirection = distance * velocityScale
	linear_velocity.x += clamp(scaledDirection.x, maxSpeed * -1, maxSpeed)
	linear_velocity.y += clamp(scaledDirection.y, maxSpeed * -1, maxSpeed)

func _on_body_entered(body: Node2D) -> void:
	if body.name.contains("Coin"):
		collectCoin(body)

func collectCoin(coin: Node2D) -> void:
	coin.queue_free()

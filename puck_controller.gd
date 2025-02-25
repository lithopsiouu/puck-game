extends RigidBody2D

"""
created by connie anderson 
february 2025
"""

const velocityScale = 4

var mouseOnPuck = false

var mouseGrabPos = null
var mouseReleasePos = null
var mouseDragDist = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("PuckGrab"):
		_set_mouse_grab_pos()
		# print("Puck grabbed, pos: " + str(mouseGrabPos))
		# pass
	elif Input.is_action_just_released("PuckGrab"):
		_set_mouse_release_pos()
		_add_puck_velocity(_get_dist_btwn_grabs())
		# print("Puck released, pos: " + str(mouseReleasePos))

#Sets mouseGrabPos to the position the mouse is globally at.
func _set_mouse_grab_pos():
	mouseGrabPos = get_global_mouse_position()

#Sets mouseReleasePos to the position the mouse is globally at.
func _set_mouse_release_pos():
	mouseReleasePos = get_global_mouse_position()

#Subtracts the grab position from the release position
func _get_dist_btwn_grabs() -> Vector2:
	var distance = (mouseGrabPos - mouseReleasePos)
	# print("drag distance: " + str(distance))
	return distance

#Multiplies the direction by velocityScale and applies it to the object's linear_velocity
func _add_puck_velocity(direction):
	var scaledDirection = direction * velocityScale
	linear_velocity.x += scaledDirection.x
	linear_velocity.y += scaledDirection.y

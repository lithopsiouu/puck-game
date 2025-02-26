extends Sprite2D

const fadeArrow = true
const scaleArrow = true

var puckGrabInitPos = null
var puckGrabCurrentPos = null
var puck = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	puck = get_parent()
	if fadeArrow:
		modulate.a = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("PuckGrab"):
		puckGrabInitPos = puck.get_mouse_grab_pos()
		
	elif Input.is_action_pressed("PuckGrab") and puckGrabInitPos != null:
		puckGrabCurrentPos = puck.get_mouse_pos_relative_to_puckbody()
		rotation = atan2((puck.get_mouse_pos_relative_to_puckbody() - puck.get_mouse_grab_pos()).normalized().y, (puck.get_mouse_pos_relative_to_puckbody() - puck.get_mouse_grab_pos()).normalized().x) - (PI / 2)
		
		if fadeArrow:
			modulate.a = get_puck_grab_power() / 250.0
		elif !fadeArrow:
			modulate.a = 1.0
		if scaleArrow:
			scale.y = get_puck_grab_power() / 190.0 + 1
		
		#print(str(get_puck_grab_power()))
		#print(rotation)
		#print("\ninitial grab: " + str(puckGrabInitPos) + "\ncurrent grab: " + str(puckGrabCurrentPos) + 
		#"\ndot: " + str((puckGrabInitPos - puckGrabCurrentPos).normalized()) + "\nrotation: " + str((puckGrabInitPos - puckGrabCurrentPos).angle()))
		#print(str(atan2((puckGrabCurrentPos - puckGrabInitPos).normalized().y, (puckGrabCurrentPos - puckGrabInitPos).normalized().x)))
	elif Input.is_action_just_released("PuckGrab"):
		modulate.a = 0

func get_puck_grab_power():
	return (puck.get_mouse_grab_pos() - puck.get_mouse_pos_relative_to_puckbody()).length()

extends Sprite2D

# Arrow does not reliably display shot direction. Swiping back and forth displays this. Look into atan2 math or how mouse position is grabbed
# ^^^ fixed!!!

const fadeArrow : bool = true
const scaleArrow : bool = true

var puckGrabInitPos = null
var puckGrabCurrentPos = null
#var canUpdateArrow : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#puck = get_parent()
	if fadeArrow:
		modulate.a = 0.0

func prepareArrow(initPos) -> void:
	puckGrabInitPos = initPos
	if fadeArrow:
		modulate.a = 0.0
	else:
		modulate.a = 1.0
	if scaleArrow:
		scale.y = 0.0
	else:
		scale.y = 1.0
	#print("arrow prepared")

func resetArrow() -> void:
	modulate.a = 0
	if scaleArrow:
		scale.y = 0.0
	
	#print("arrow reset")

func updateArrow(mouseGrabPos) -> void:
	#print("updating")
	puckGrabCurrentPos = mouseGrabPos
	rotation = atan2((puckGrabCurrentPos - puckGrabInitPos).normalized().y, (puckGrabCurrentPos - puckGrabInitPos).normalized().x) - (PI / 2)
	
	if fadeArrow:
		modulate.a = get_puck_grab_power() / 250.0
	if scaleArrow:
		scale.y = get_puck_grab_power() / 190.0 + 1

func get_puck_grab_power():
	return (puckGrabInitPos - puckGrabCurrentPos).length()

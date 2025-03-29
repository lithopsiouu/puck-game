extends Node2D

var cursor = preload("res://assets/cursor.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	makeNewCursor(Vector2(9999, 9999))


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("PuckGrab"):
		makeNewCursor(get_global_mouse_position())
	elif Input.is_action_just_released("PuckGrab"):
		#pass
		clearCursors()

func makeNewCursor(pos):
	var instance = cursor.instantiate()
	instance.position = pos
	add_child(instance)
	#print(str(instance.name))

#invalid access error on modulate
func makeNewCursorColored(pos, alpha):
	var instance = cursor.instantiate()
	instance.position = pos
	instance.modualte.a = alpha
	add_child(instance)

func changeCursorPos(newPosition):
	var instance = get_child(0)
	instance.transform = newPosition

func changeCursorColor(color):
	var instance = get_child(0)
	instance.modulate.a = color

func clearCursors():
	for i in get_children():
		i.queue_free()
		

extends Node2D

var cursor = preload("res://cursor.tscn")
var container = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	container = get_node("CursorHolder")


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("PuckGrab"):
		makeNewCursor(get_global_mouse_position())
	elif Input.is_action_just_released("PuckGrab"):
		#pass
		clearCursors()

func makeNewCursor(pos):
	var instance = cursor.instantiate()
	instance.position = pos
	container.add_child(instance)
	#print(str(instance.name))

func clearCursors():
	for i in container.get_children():
		i.queue_free()
		

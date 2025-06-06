extends TextureRect

@export_enum("Rotate", "Pulse") var transformType = "Rotate"

@export_group("Rotation")
@export var rotationSpeed: float = 1 #as degrees

@export_group("Pulse")
@export var frequency := 1.0
@export var pulseSize := 1.0
@export var offset := 1.0
@export var useX := true
@export var useY := true

var time : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	match transformType:
		"Rotate":
			rotation_degrees += rotationSpeed
		"Pulse":
			if useX: scale.x = offset + (sin(time * frequency) * pulseSize)
			if useY: scale.y = offset + (sin(time * frequency) * pulseSize)

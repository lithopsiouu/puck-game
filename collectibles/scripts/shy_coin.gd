class_name ShyCoin extends RigidBody2D

@export var coinValue : int = 5
@export var dead : bool = false
@onready var animPlayer : AnimationPlayer = $AnimationPlayer

var lastPlayerBodyPos : Vector2 = Vector2.ZERO
var playerBody : RigidBody2D = null
var playerInRunRadius : bool = false
var runWhenReady : bool = false
var canSeePlayer : bool = false
var canCollect : bool = true
var collected : bool = false

const tickUpdateTime : int = 20
var ticks : int = 0

#     state:  0     1       2
enum _states {IDLE, MOVING, RECOVER}
var state = _states.IDLE

func _ready() -> void:
	animPlayer.play("idle")
	animPlayer.set_blend_time("recovering", "idle", 0.2)
	animPlayer.set_blend_time("moving", "recovering", 1)

func _physics_process(delta: float) -> void:
	if collected:
		ticks += 1
		if playerInRunRadius and ticks > tickUpdateTime:
			ticks = 0
			lastPlayerBodyPos = playerBody.global_position
			if !canSeePlayer and !dead:
				try_start_moving(playerBody)
			if state == _states.RECOVER:
				runWhenReady = true

func handle_state_transitions(newState):
	var newStateEnum : int = newState
	if newStateEnum == state:
		pass
		#print("already in state")
	elif newStateEnum == 1 and state == _states.RECOVER:
		runWhenReady = true
		#print("Queuing additional run away")
	else:
		state = newStateEnum
		perform_state_actions()
		#print("state set to " + str(state))

func perform_state_actions() -> void:
	match state:
		_states.IDLE:
			animPlayer.play("idle", 2)
		_states.MOVING:
			animPlayer.play("moving", 0.4)
			run_away_from_player()
		_states.RECOVER:
			animPlayer.play("recovering", 1.3)
			linear_damp = 1.2
			await get_tree().create_timer(1.7).timeout
			linear_damp = 0.3
			if runWhenReady:
				state = _states.IDLE
				runWhenReady = false
				handle_state_transitions(1)
			else:
				handle_state_transitions(0)

func run_away_from_player():
	apply_impulse(get_vector_away_from_player() * 900.0)
	await get_tree().create_timer(randf_range(0.2, 1.2)).timeout
	apply_impulse(get_vector_away_from_player() * 600.0)
	await get_tree().create_timer(randf_range(0.2, 0.6)).timeout
	apply_impulse(get_vector_away_from_player() * 700.0)
	handle_state_transitions(2)

func _on_run_radius_body_entered(body: Node2D) -> void:
	if body is PlayerPuck:
		playerInRunRadius = true
		playerBody = body
		#print("initial check:")
		try_start_moving(body)

func try_start_moving(body: Node2D):
	#print(str(cast_ray_to_player(body) is PlayerPuck))
	if cast_ray_to_player(body) is PlayerPuck:
		canSeePlayer = true
		handle_state_transitions(1)
		#print("entered")

func cast_ray_to_player(body: Node2D):
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(global_position, body.global_position)
	var result = space_state.intersect_ray(query)
	return result.collider

func _on_run_radius_body_exited(body: Node2D) -> void:
	canSeePlayer = false
	playerInRunRadius = false
	runWhenReady = false
	playerBody = null

func get_vector_away_from_player() -> Vector2:
	var awayDir
	awayDir = lastPlayerBodyPos.direction_to((global_position)).rotated(randf_range(-0.5, 0.5))
	#print(str(awayDir))
	return awayDir

func _on_collect_radius_body_entered(body: Node2D) -> void:
	if body is PlayerPuck and canCollect:
		collected = true
		collision_layer = 8
		linear_damp = 5
		GameController.coin_collected(coinValue)
		animPlayer.play("collect", 0.5)

func set_canCollect(newCanCollect: bool):
	canCollect = newCanCollect

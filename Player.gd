extends KinematicBody2D

const GRAVITY = 600.0
const ACCELERATION = 500
const MAX_SPEED = 120
const TERMINAL_SPEED = 120
const FRICTION = 800
const JUMP_VELOCITY = -200

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
#onready var animationTree = $AnimationTree
#onready var animationState = animationTree.get("parameters/playback")
	
	
func _process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		#animationTree.set("parameters/Idle/blend_position", input_vector)
		#animationTree.set("parameters/Run/blend_position", input_vector)
		#animationTree.set("parameters/Attack/blend_position", input_vector)
		#animationState.travel("Run")
		velocity.x = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta).x
	else:
		#animationState.travel("Idle")
		velocity.x = 0
		velocity = velocity.move_toward(velocity, FRICTION * delta)
		
	#TODO: make sure jump action can only be performed on ground, or if double jump is enabled
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	velocity = move_and_slide(velocity)
	
	
	"""match state:
		MOVE:
			move_state(delta)
		ROLL:
			pass
		ATTACK:
			attack_state(delta)"""
	
func _physics_process(delta):
	velocity.y += delta * GRAVITY
	#move_and_collide(motion)	
	
		
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#print(input_vector.x)
	#input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		#animationTree.set("parameters/Idle/blend_position", input_vector)
		#animationTree.set("parameters/Run/blend_position", input_vector)
		#animationTree.set("parameters/Attack/blend_position", input_vector)
		#animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		#animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
func attack_state(delta):
	velocity = Vector2.ZERO
	#animationState.travel("Attack")
	
func attack_animation_finished():
	state = MOVE

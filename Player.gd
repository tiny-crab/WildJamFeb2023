extends KinematicBody2D


const UP = Vector2(0, -1)
const GRAVITY = 600.0
const ACCELERATION = 500
const MAX_SPEED = 120
const TERMINAL_SPEED = 120
const FRICTION = 800
const JUMP_VELOCITY = -200

#controls logs indicating what state the player is in
const STATE_DEBUG = true

enum {
	GROUND,
	JUMP,
	GRAPPLE
}

var state = GROUND
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
#onready var animationTree = $AnimationTree
#onready var animationState = animationTree.get("parameters/playback")
	
	
func _process(delta):
	#TODO: make sure jump action can only be performed on ground, or if double jump is enabled
	if Input.is_action_just_pressed("jump") and state != JUMP:
		velocity.y = JUMP_VELOCITY
		state = JUMP
	
	match state:
		GROUND:
			move_ground(delta)
			if STATE_DEBUG:
				print("Ground")
		JUMP:
			move_jump(delta)
			if STATE_DEBUG:
				print("Jump")
		GRAPPLE:
			move_grapple(delta)
			if STATE_DEBUG:
				print("Grapple")
			
			
	velocity = move_and_slide(velocity, UP)
	
func _physics_process(delta):
	velocity.y += delta * GRAVITY
	#move_and_collide(motion)	
	
func move_ground(delta):
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
	
func move_jump(delta):
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		#animationTree.set("parameters/Idle/blend_position", input_vector)
		#animationTree.set("parameters/Run/blend_position", input_vector)
		#animationTree.set("parameters/Attack/blend_position", input_vector)
		#animationState.travel("Run")
		velocity.x = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta).x
	
	if is_on_floor() and velocity.y >= 0:
		state = GROUND

func move_grapple(delta):
	pass
			
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

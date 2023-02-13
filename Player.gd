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
var interactable = null

onready var animationPlayer = $AnimationPlayer
#onready var animationTree = $AnimationTree
#onready var animationState = animationTree.get("parameters/playback")
    
signal player_can_interact(area)
signal player_interacted(area)
   
func _process(delta):
    #TODO: make sure jump action can only be performed on ground, or if double jump is enabled
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
            
    if Input.is_action_just_pressed("jump") and state != JUMP:
        velocity.y = JUMP_VELOCITY
                
    velocity = move_and_slide(velocity, UP)
    
    if Input.is_action_just_pressed("interact") and interactable != null:
        print("Interacted with %s" % interactable.name)
        emit_signal("player_interacted", interactable)
        
    
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
        
    if Input.is_action_just_pressed("jump") and state != JUMP:
        velocity.y = JUMP_VELOCITY
        state = JUMP
        
    if Input.is_action_just_pressed("grapple"):
        print("grappling")
        state = GRAPPLE		
    
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
    var mouse_position = get_local_mouse_position()
    print(mouse_position.normalized())

func _on_InteractHitbox_area_entered(area):
    var node = area.get_owner()
    print("Collided with %s" % node.name)
    interactable = node
    emit_signal("player_can_interact", interactable)


func _on_InteractHitbox_area_exited(area):
    var node = area.get_owner()
    print("Stopped colliding with %s" % area.name)
    if (area.name == interactable.name): 
        interactable = null

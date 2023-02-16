extends KinematicBody2D


const UP = Vector2(0, -1)
const GRAVITY = 600.0
const ACCELERATION = 500
const MAX_SPEED = 120
onready var modified_speed = MAX_SPEED
const TERMINAL_SPEED = 120
const FRICTION = 800
const JUMP_VELOCITY = -200
const CHAIN_PULL = 105
const SHOTGUN_OFFSET = 20
const SHOTGUN_CENTER_OFFSET = Vector2(0, -12)

#controls logs indicating what state the player is in
const STATE_DEBUG = false

enum {
    GROUND,
    JUMP,
    GRAPPLE
}

var state = JUMP
var velocity = Vector2.ZERO
var hook_velocity = Vector2.ZERO
# not a const because we may want to change this during gameplay
var max_grapple_charges = 3
var grapple_charges = max_grapple_charges
var interactable = null

onready var Player = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var grapplingHook = $GrappleHook
onready var ShotgunPosition = $ShotgunPosition
onready var Shotgun = $ShotgunPosition/Shotgun

signal player_interacted(area)
signal interacted_with_shrine(isCurseShrine)

func _ready():
    grapplingHook.connect("grappling_released", self, "_on_grappling_released")
    SignalBus.add_listener("curse_purchased", self, "_on_curse_purchased")
    SignalBus.add_emitter("interacted_with_shrine", self)
   
func _process(delta):
    update()
    #MOVEMENT
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
            
    if Input.is_action_just_pressed("jump") and state == GROUND:
        velocity.y = JUMP_VELOCITY
        state = JUMP
        
    if Input.is_action_just_pressed("grapple") and grapple_charges >= 1:
        grapplingHook.shoot(get_local_mouse_position())
        grapple_charges -= 1
        
    if grapplingHook.hooked:
        state = GRAPPLE
        
    if Input.is_action_just_released("grapple"):
        grapplingHook.release()
        state = JUMP    
                
    velocity = move_and_slide(velocity, UP)
    
    #WEAPONS
    aim_shotgun()
    
    if Input.is_action_just_pressed("attack"):
        Shotgun.shoot()
    
    #INTERACTIONS
    if Input.is_action_just_pressed("interact") and interactable != null:
        print("Interacted with %s" % interactable.name)
        if (interactable.get_class() == "Shrine"):
            _on_Interacted_with_Shrine(interactable)
        elif (interactable.get_class() == "Key"):
            _on_Interacted_with_Key(interactable)
        else:
            push_warning("Attempted to interact with an Interactable without a class")
           
func _on_grappling_released():
    print("grappling released")
    state = JUMP
    
func _physics_process(delta):
    if state == JUMP or state == GROUND:
        velocity.y += delta * GRAVITY
    
func move_ground(delta):
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector = input_vector.normalized()
    if input_vector != Vector2.ZERO:
        velocity.x = velocity.move_toward(input_vector * modified_speed, ACCELERATION * delta).x
    else:
        velocity.x = 0
        velocity = velocity.move_toward(velocity, FRICTION * delta)
    
func move_jump(delta):
    
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector = input_vector.normalized()
    if input_vector != Vector2.ZERO:
        velocity.x = velocity.move_toward(input_vector * modified_speed, ACCELERATION * delta).x
    
    if is_on_floor() and velocity.y >= 0:
        grapple_charges = max_grapple_charges
        state = GROUND

func move_grapple(delta):
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector = input_vector.normalized()
    
    hook_velocity = to_local(grapplingHook.tip).normalized() * CHAIN_PULL * delta
    hook_velocity.x *= 5.65
    if sign(input_vector.x) != sign(hook_velocity.x):
        hook_velocity.x *= 0.7
    velocity += hook_velocity
    
#WEAPONS

func aim_shotgun():
    #Aiming
    var cursor_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET
    var look_at_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET * 10
    #Make sure the shotgun sprite is always in the right orientation
    if cursor_position.x > 0:
        ShotgunPosition.set_scale(Vector2(1, 1))
    else:
        ShotgunPosition.set_scale(Vector2(1, -1))
    ShotgunPosition.position = cursor_position + SHOTGUN_CENTER_OFFSET
    
    ShotgunPosition.look_at(to_global(look_at_position))


# INTERACTIONS

func _on_InteractHitbox_area_entered(area):
    var node = area.get_owner()
    interactable = node

func _on_InteractHitbox_area_exited(area):
    var node = area.get_owner()
    if (node.name == interactable.name):
        interactable = null

func _on_Interacted_with_Shrine(node):
    emit_signal("interacted_with_shrine", node.isCurseShrine)
    pass

func _on_Interacted_with_Key(node):
    pass

# CURSES

func _on_curse_purchased(curses):
    for curse in curses:
        print("Purchased %s" % curse.name)
    modified_speed -= 50

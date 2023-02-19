extends KinematicBody2D


const UP = Vector2(0, -1)
const GRAVITY = 600.0
const ACCELERATION = 500
const INITIAL_SPEED = 120
onready var modified_speed = INITIAL_SPEED
const TERMINAL_SPEED = 120
const FRICTION = 800
const INITIAL_JUMP_VELOCITY = -200
const CHAIN_PULL = 105
const SHOTGUN_OFFSET = 20
const SHOTGUN_CENTER_OFFSET = Vector2(0, -12)
const INTIAL_HEALTH = 100
#const SHOTGUN_POSITION_RIGHT = Vector2(-2, -17)

#controls logs indicating what state the player is in
const STATE_DEBUG = false

enum {
    GROUND,
    JUMP,
    GRAPPLE,
    DEATH
}

var state = JUMP
var velocity = Vector2.ZERO
var hook_velocity = Vector2.ZERO
# not a const because we may want to change this during gameplay
var max_grapple_charges = 3
var grapple_charges = max_grapple_charges
var max_jump_charges = 1
var jump_charges = max_jump_charges
var jump_velocity = INITIAL_JUMP_VELOCITY
var interactable = null

var damage_received_modifier = 1
var current_health = INTIAL_HEALTH

var shotgun_has_sight = true
var shotgun_is_cursed = false

var num_boss_attempts = 5
var should_lose_attempt = false

onready var player = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var grapplingHook = $GrappleHook
onready var ShotgunPosition = $PlayerSprite/ShotgunPosition
onready var Shotgun = $PlayerSprite/ShotgunPosition/Shotgun

signal player_interacted(area)
signal interacted_with_shrine(shrineNode)
signal interacted_with_key(keyNode)
signal activated_teleporter()
signal send_player_position(player_position)
signal paused_game()
signal game_over()

func _ready():
    grapplingHook.connect("grappling_released", self, "_on_grappling_released")
    SignalBus.add_listener("curse_purchased", self, "_on_curse_purchased")
    SignalBus.add_emitter("interacted_with_shrine", self)
    SignalBus.add_emitter("interacted_with_key", self)
    SignalBus.add_emitter("activated_teleporter", self)
    SignalBus.add_emitter("paused_game", self)
    animationTree.active = true
   
func _process(delta):
    update()
    emit_signal("send_player_position", position)
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
            
    if Input.is_action_just_pressed("jump") and (state == GROUND or jump_charges >= 1):
        jump_charges -= 1
        velocity.y = jump_velocity
        animationState.travel("Jump")
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
    if velocity. x > 0:
        player.set_scale(Vector2(1, 1))
    elif velocity.x < 0:
        player.set_scale(Vector2(-1, 1))
    
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
    
    if Input.is_action_just_pressed("reset"):
        #used for teleportation
        emit_signal("activated_teleporter")
        
    if Input.is_action_just_pressed("pause"):
        emit_signal("paused_game")
           
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
    
    #Animation
    if velocity.x == 0:
        animationState.travel("Idle")
    else:
        animationState.travel("Walk")
    
func move_jump(delta):
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector = input_vector.normalized()
    if input_vector != Vector2.ZERO:
        velocity.x = velocity.move_toward(input_vector * modified_speed, ACCELERATION * delta).x
    
    if is_on_floor() and velocity.y >= 0:
        grapple_charges = max_grapple_charges
        jump_charges = max_jump_charges
        state = GROUND
    play_in_air_animations()
        
func move_grapple(delta):
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector = input_vector.normalized()
    
    hook_velocity = to_local(grapplingHook.tip).normalized() * CHAIN_PULL * delta
    hook_velocity.x *= 5.65
    if sign(input_vector.x) != sign(hook_velocity.x):
        hook_velocity.x *= 0.7
    velocity += hook_velocity
    play_in_air_animations()
    
func play_in_air_animations():
    #Animation
    if velocity.y < 0:
        animationState.travel("Jump")
    else:
        animationState.travel("Fall")
    
#WEAPONS

func aim_shotgun():
    #Aiming
    var cursor_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET
    var look_at_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET * 10
    
    ShotgunPosition.look_at(to_global(look_at_position))
    
func _draw():   
    if shotgun_has_sight:
        var look_at_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET * 10
        var sight_begin_position = ShotgunPosition.position + Vector2(0, -24)
        draw_line(sight_begin_position, look_at_position, Color(255, 0, 0), 1)


#Damage
func receive_damage(damage_to_receive):
    current_health -= damage_to_receive * damage_received_modifier
    if current_health <= 0:
        state = DEATH
        #dirt way to handle it, but easier than figuring out a lerp for now.
        Shotgun.visible = false
        shotgun_has_sight = false
        animationState.travel("Death")
        #TODO: add teleport method here and move state back to ground

#called when death animation finishes from animation player        
func death():
    #In the future if we want this to work add a signal from boss
    #letting the player know the boss is active and the player should lose attempts
    if should_lose_attempt and num_boss_attempts > 0:
        num_boss_attempts -= 1
    elif num_boss_attempts <= 0:
        emit_signal("game_over")
        
    emit_signal("activated_teleporter")
    reset()
    
    
func reset():
    Shotgun.visible = true
    if not shotgun_is_cursed:
        shotgun_has_sight = true
    current_health = INTIAL_HEALTH
    animationState.travel("Idle")
        
    
# INTERACTIONS
func _on_InteractHitbox_area_entered(area):
    var node = area.get_owner()
    interactable = node

func _on_InteractHitbox_area_exited(area):
    var node = area.get_owner()
    if (node.name == interactable.name):
        interactable = null

func _on_Interacted_with_Shrine(node):
    if (!node.destroyed):
        emit_signal("interacted_with_shrine", node)

func _on_Interacted_with_Key(node):
    emit_signal("interacted_with_key", node)

# CURSES

func _on_curse_purchased(curses):
    for curse in curses:
        print("Purchased %s" % curse.name)
        match curse.name:
            "Damage +":
                var damage_increase = Shotgun.damage * 0.5
                Shotgun.alter_damage(damage_increase)
            "Damage -":
                var damage_decrease = Shotgun.damage * -0.5
                Shotgun.alter_damage(damage_decrease)
            "Jump Charges":
                max_jump_charges += 1
            "Fall Damage":
                #Maybe add fall damage someday
                pass
            "Jump Height +":
                jump_velocity = jump_velocity * 1.1
            "Jump Height -":
                jump_velocity = clamp(jump_velocity - (jump_velocity * .1), -10, -1000000000000)
            "Move Speed +":
                modified_speed = modified_speed * 1.1
            "Move Speed -":
                modified_speed = clamp(modified_speed - (modified_speed * -1), 20, 1000000000000)
            "Grapple Charge +":
                grapple_charges += 1
            "Grapple Charge -":
                grapple_charges = clamp(grapple_charges - 1, 1, 10000000000)
            "Grapple Length +":
                grapplingHook.chain_length = grapplingHook.chain_length * 1.1
            "Grapple Length -":
                grapplingHook.chain_length = clamp(grapplingHook.chain_length - (grapplingHook.chain_length *.1), 100, 1000000000)
            "Grapple Time +":
                grapplingHook.grapple_duration = grapplingHook.grapple_duration * 1.1
            "Grapple Time -":
                grapplingHook.grapple_duration = clamp(grapplingHook.grapple_duration - (grapplingHook.grapple_duration *.1), 0.25, 1000000000)
            "Lose LaserSight":
                shotgun_has_sight = false

func _on_Hurtbox_area_entered(area):
    #print("hurtbox hit")
    var bodies = area.get_overlapping_bodies()
    for body in bodies:
        if body.get_class() == "Minion" or body.get_class() == "Boss":
            print(body.attack_damage)
            receive_damage(body.attack_damage)

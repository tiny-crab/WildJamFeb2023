extends KinematicBody2D

# TODO export these to allow tuning in remote tree view
const UP = Vector2(0, -1)
const JUMP_GRAVITY = 600.0
const FALL_GRAVITY = 900.0
const HOVER_GRAVITY = JUMP_GRAVITY * 0.1
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

const AIR_SCALE_LERP_VELOCITY = 8
const GROUND_SCALE_LERP_VELOCITY = 10
var targetScale = Vector2(1, 1)

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
var facingRight = true
var hook_velocity = Vector2.ZERO
# not a const because we may want to change this during gameplay
var max_grapple_charges = 3
var grapple_charges = max_grapple_charges
var max_air_jump_charges = 1
var air_jump_charges = max_air_jump_charges
var jump_velocity = INITIAL_JUMP_VELOCITY
var was_on_floor = false
var interactable = null

var damage_received_modifier = 1
var current_health = INTIAL_HEALTH

var current_sap = 0

var shotgun_has_sight = true
var shotgun_is_cursed = false

var num_boss_attempts = 5
var should_lose_attempt = false

var hover_jump_on = false

onready var player = $PlayerSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var grapplingHook = $GrappleHook
onready var ShotgunPosition = $PlayerSprite/ShotgunPosition
onready var Shotgun = $PlayerSprite/ShotgunPosition/Shotgun
onready var coyoteTime = $CoyoteTime

signal player_health_changed(newHealth)
signal activated_teleporter()
signal send_player_position(player_position)
signal paused_game()
signal game_over()

func _ready():
    grapplingHook.connect("grappling_released", self, "_on_grappling_released")
    SignalBus.add_emitter("activated_teleporter", self)
    SignalBus.add_emitter("player_health_changed", self)
    SignalBus.add_emitter("paused_game", self)
    animationTree.active = true

func _process(delta):
    update()
    # TODO what do you think about the boss / enemies doing a circle cast to find the player's position within a "sight range"?
    # I don't know how heavyweight it is to be emitting a signal upon every frame
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

    # if player just started falling off a platform
    if was_on_floor and !is_on_floor():
        coyoteTime.start()

    # if player just hit the ground
    if !was_on_floor and is_on_floor():
        targetScale = Vector2(1.2, 0.7)
        $SquashTimer.start()

    was_on_floor = is_on_floor()

    if $SqueezeTimer.is_stopped() and $SquashTimer.is_stopped():
        targetScale = Vector2(1, 1)

    var lerpVelocity = GROUND_SCALE_LERP_VELOCITY if is_on_floor() else AIR_SCALE_LERP_VELOCITY
    player.scale.x = lerp(player.scale.x, targetScale.x if facingRight else -targetScale.x, lerpVelocity * delta)
    player.scale.y = lerp(player.scale.y, targetScale.y, lerpVelocity * delta)

    if Input.is_action_just_pressed("jump") and (state == GROUND or air_jump_charges >= 1):
        targetScale = Vector2(0.8, 1.1)
        $SqueezeTimer.start()
        if can_ground_jump():
            # player gets a single jump from off the ground
            velocity.y = jump_velocity
            state = JUMP
        elif not is_on_floor() and air_jump_charges > 0:
            # player gets to jump air_jump_charges times while in the air
            air_jump_charges -= 1
            velocity.y = jump_velocity
            state = JUMP

    if Input.is_action_just_released("jump") and (state == JUMP):
        # just ramp down on upward velocity quickly, so that player transitions into fall gravity more quickly
        velocity.y = velocity.y / 5

    if Input.is_action_pressed("hover_down") and state == JUMP and hover_jump_on:
        velocity.y += JUMP_GRAVITY * 0.8 * delta

    if Input.is_action_just_pressed("grapple") and grapple_charges >= 1:
        grapplingHook.shoot(get_local_mouse_position())
        grapple_charges -= 1

    if grapplingHook.hooked:
        state = GRAPPLE

    if Input.is_action_just_released("grapple"):
        grapplingHook.release()
        state = JUMP

    velocity = move_and_slide(velocity, UP)
    if velocity.x > 0:
        if not facingRight:
            # immediately force player sprite to flip if changing direction
            player.scale.x *= -1
        facingRight = true
    elif velocity.x < 0:
        if facingRight:
            # immediately force player sprite to flip if changing direction
            player.scale.x *= -1
        facingRight = false


    #WEAPONS
    aim_shotgun()

    if Input.is_action_just_pressed("attack"):
        Shotgun.shoot()

    # TODO could remove this action type and just have an option in the pause menu to teleport
    if Input.is_action_just_pressed("reset"):
        emit_signal("activated_teleporter")

    if Input.is_action_just_pressed("pause"):
        emit_signal("paused_game")

func _on_grappling_released():
    print("grappling released")
    state = JUMP

func _physics_process(delta):
    if state == JUMP or state == GROUND:
        if not hover_jump_on:
            # if coyote time is still active, the fall should be slower
            var gravity = JUMP_GRAVITY if velocity.y < 0 or not coyoteTime.is_stopped() else FALL_GRAVITY
            velocity.y += delta * gravity
        else:
            velocity.y += delta * HOVER_GRAVITY

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
        air_jump_charges = max_air_jump_charges
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

func can_ground_jump():
    if is_on_floor() or not coyoteTime.is_stopped():
        return true
    else:
        return false

#WEAPONS

func aim_shotgun():
    #Aiming
    var cursor_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET
    var look_at_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET * 10

    ShotgunPosition.look_at(to_global(look_at_position))

func _draw():
    if shotgun_has_sight:
        var look_at_position = get_local_mouse_position().normalized() * SHOTGUN_OFFSET * 10
        var sight_begin_position = ShotgunPosition.position + Vector2(0, 4)
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
    emit_signal("player_health_changed", current_health)

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

func _on_Hurtbox_area_entered(area):
    var bodies = area.get_overlapping_bodies()
    for body in bodies:
        if body.get_class() == "Minion" or body.get_class() == "Boss":
            print(body.attack_damage)
            receive_damage(body.attack_damage)

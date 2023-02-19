extends KinematicBody2D

const INITIAL_HEALTH = 300
const INTIAL_CHARGE_INCREMENT_TIME = 10
const INITIAL_SCALE = Vector2(0.1, 0.1)
const SCALE_INCREMENT = Vector2(0.01, 0.01)
const INITIAL_DAMAGE_DEALT = 5
const INTIAL_POWER = 1
const MAX_POWER = 100
const MIN_PURSUIT_TIME = 1
const MAX_PURSUIT_TIME = 3
const PURSUIT_SPEED = 5

onready var teleportPositionOne = to_global($TeleportPosition1.position)
onready var teleportPositionTwo = to_global($TeleportPosition2.position)
onready var teleportPositionThree = to_global($TeleportPosition3.position)

onready var sprite = $FloorSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var chargeUpTimer = $ChargeUpTimer
onready var pursuitAndIdleTimer = $PursuitAndIdleTimer
var current_min_pursuitTime = MIN_PURSUIT_TIME
var current_max_pursuitTime = MAX_PURSUIT_TIME

onready var boss_teleport_positions = [teleportPositionOne, teleportPositionTwo, teleportPositionThree]
var current_health = INITIAL_HEALTH
var current_charge_increment_time = INTIAL_CHARGE_INCREMENT_TIME
var scale_increment_modifier = 1
var power = INTIAL_POWER
var teleport_location = Vector2.ZERO
var attack_damage = INITIAL_DAMAGE_DEALT
var pursuit_position = Vector2.ZERO
var velocity = Vector2.ZERO

var rng = RandomNumberGenerator.new()

enum {
    CHARGING,
    IDLE,
    PURSUING,
    TELEPORTING,
    SIMPLE_ATTACK,
    WIDE_ATTACK,
    DEAD
   }

var state = CHARGING

func get_class():
    return "Boss"
    
# Called when the node enters the scene tree for the first time.
func _ready():
    animationTree.active = true
    chargeUpTimer.connect("timeout", self, "_on_Timer_timeout")
    pursuitAndIdleTimer.connect("timeout", self, "_on_PursuitAndIdleTimer_timeout")
    scale = INITIAL_SCALE
    if state == CHARGING:
        animationState.travel("Idle")
        chargeUpTimer.wait_time = current_charge_increment_time
        chargeUpTimer.start()
        
func _process(delta):
    update()
    match state:
        PURSUING:
            pursuit(delta)
        IDLE:
            idle()
        SIMPLE_ATTACK:
            pass
        TELEPORTING:
            pass
    
    #negative is left, positive is right        
    var player_side = pursuit_position.x - sprite.position.x        
    if (player_side >= 0 and sprite.scale.x < 0) or (player_side < 0 and sprite.scale.x > 0):
        sprite.scale.x *= -1

    
func teleport():
    velocity = Vector2.ZERO
    rng.randomize()
    var rng_index = rng.randi_range(0, 2)
    var teleport_choice = boss_teleport_positions[rng_index]
    teleport_location = teleport_choice
    animationState.travel("Teleport")

func idle():
    velocity = Vector2.ZERO
    animationState.travel("Idle")
    
func pursuit(delta):
    animationState.travel("Pursuit")
    velocity = velocity.move_toward(pursuit_position, delta)
    move_and_collide(velocity)
    if (to_global(sprite.position) - to_global(pursuit_position)).length() <= 20:
        simple_attack()
    
func simple_attack():
    velocity = Vector2.ZERO
    animationState.travel("SimpleAttack")

func wide_attack():
    velocity = Vector2.ZERO
    animationState.travel("WideAttack")
          
func take_damage(damage_to_receive, knockback):
    if state != CHARGING:
        current_health -= damage_to_receive
        if current_health <= 0 and state != DEAD:
            state = DEAD
            animationState.travel("Death")
            
func power_up():
    scale += SCALE_INCREMENT * scale_increment_modifier
    power += 1
    attack_damage += 0.5
    if power >= MAX_POWER:
        chargeUpTimer.stop()
        teleport()
        
func change_pursuit_and_idle_time(min_time, max_time):
    current_min_pursuitTime = min_time
    current_max_pursuitTime = max_time
         
func awaken():
    state = IDLE
    chargeUpTimer.stop()
    
func choose_behavior():
    rng.randomize()
    var behavior = rng.randi_range(0, 2)
    #var behavior = 2
    if behavior == 0:
        teleport()
    elif behavior == 1:
        wide_attack()
    elif behavior == 2:
        state = PURSUING
        var pursuit_time = rng.randi_range(current_min_pursuitTime, current_max_pursuitTime)
        pursuitAndIdleTimer.wait_time = pursuit_time
        pursuitAndIdleTimer.start()
        print("timer started")
    else:
        state = IDLE
        var pursuit_time = rng.randi_range(current_min_pursuitTime, current_max_pursuitTime)
        pursuitAndIdleTimer.wait_time = pursuit_time
        pursuitAndIdleTimer.start()

func teleport_finished():
    position = teleport_location
    animationState.travel("Appear")

func appear_finished():
    choose_behavior()

func wide_attack_finished():
    teleport()

func simple_attack_finished():
    state = IDLE
    var pursuit_time = rng.randi_range(MIN_PURSUIT_TIME, MAX_PURSUIT_TIME)
    pursuitAndIdleTimer.wait_time = pursuit_time
    pursuitAndIdleTimer.start()
    
func _on_Timer_timeout():
    power_up()
    chargeUpTimer.wait_time = current_charge_increment_time
    if power <= MAX_POWER:
        chargeUpTimer.start()


func _on_PursuitAndIdleTimer_timeout():
    if state == IDLE:
        rng.randomize()
        var choice = rng.randi_range(0, 1)
        print(choice)
        if choice == 0:
            state = TELEPORTING
            teleport()
        else:
            state = PURSUING
    else:
        print("simple attack")
        state = SIMPLE_ATTACK
        animationState.travel("SimpleAttack")
        pursuitAndIdleTimer.stop()

func _on_Player_send_player_position(player_position):
    pursuit_position = to_local(player_position + Vector2(0, -12))

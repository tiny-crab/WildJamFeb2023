extends KinematicBody2D

const MOVE_SPEED = 20
const GRAVITY = 600.0
#5 frames of hit delay
const HIT_DELAY = 0.016666 * 3
const KNOCKBACK_PERIOD = 0.3
const INITIAL_DAMAGE_DEALT = 20

onready var minionSprite = $Sprite
onready var minionDeathSprite = $DeathSprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var ledgeCheckRight = $LedgeCheckRight
onready var ledgeCheckLeft = $LedgeCheckLeft
onready var timer = $HitDelay
onready var knockbackPeriod = $KnockbackPeriod

enum {
    NORMAL,
    HIT,
    KNOCKBACK
   }

var state = NORMAL

var direction = Vector2.RIGHT + Vector2.DOWN
var velocity = Vector2.ZERO

var max_health = 100
var current_health = max_health

var attack_damage = INITIAL_DAMAGE_DEALT

func get_class():
    return "Minion"

func _ready():
    timer.connect("timeout", self, "_on_Timer_timeout")
    timer.wait_time = HIT_DELAY
    knockbackPeriod.connect("timeout", self, "_on_KnockbackPeriod_timeout")
    knockbackPeriod.wait_time = KNOCKBACK_PERIOD
    minionDeathSprite.visible = false
    
    animationTree.active = true
        
func _physics_process(delta):
    match state:
        NORMAL:
            #animationState.travel("Walk")
            minion_movement(delta)
            move_and_slide(velocity, Vector2.UP)
        HIT:
            pass
        KNOCKBACK:
            move_and_slide(velocity, Vector2.UP)
            
func minion_movement(delta):
    var found_wall = is_on_wall()
    var found_ledge = not ledgeCheckRight.is_colliding() or not ledgeCheckLeft.is_colliding()
    if found_wall or found_ledge:
        direction.x *= -1
        scale.x *= -1
        
    if not is_on_floor():
        velocity.y += delta * GRAVITY
    
    velocity = direction * MOVE_SPEED
    velocity.y += delta * GRAVITY
    
func take_damage(damage_to_receive, knockback):
    state = HIT
    timer.start()
    velocity = knockback
    current_health -= damage_to_receive
    
func _on_Timer_timeout():
    if current_health <= 0:
        minionSprite.visible = false
        minionDeathSprite.visible = true
        animationState.travel("Death")
        #queue_free()
    timer.stop()
    state = KNOCKBACK
    knockbackPeriod.start()
    
func _on_KnockbackPeriod_timeout():
    state = NORMAL
    knockbackPeriod.stop()


func _on_Hitbox_area_entered(area):
    var bodies = area.get_overlapping_bodies()
    for body in bodies:
        pass
        #print(body.get_class())


extends KinematicBody2D

const MOVE_SPEED = 100
const GRAVITY = 600.0

onready var ledgeCheckRight = $LedgeCheckRight
onready var ledgeCheckLeft = $LedgeCheckLeft

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

var max_health = 100
var current_health = max_health

func _process(delta):
    if current_health <= 0:
        queue_free()
        
func _physics_process(delta):
    var found_wall = is_on_wall()
    var found_ledge = not ledgeCheckRight.is_colliding() or not ledgeCheckLeft.is_colliding()
    if found_wall or found_ledge:
        print("turning around")
        direction *= -1
        
    if not is_on_floor():
        print("not on floor")
        velocity.y += delta * GRAVITY
    
    velocity = direction * MOVE_SPEED
    move_and_slide(velocity, Vector2.UP)
            

func take_damage(damage_to_receive):
    current_health -= damage_to_receive
    print(current_health)

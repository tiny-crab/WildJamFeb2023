extends Node2D

const BASE_DAMAGE = 100
const DAMAGE_DROPOFF_MODIFIER = 2

onready var raycast = $RayCast2D
onready var shotgunSprite = $ShotgunSprite
onready var animationPlayer = $AnimationPlayer

var enable_self_knockback = false
var knockback_force = 100

func _ready():
    #ensure shotgun starts at frame 0
    shotgunSprite.frame = 0

func _process(delta):
    pass

func shoot():
    print("Bang")
    print(to_global(raycast.cast_to).normalized())
    animationPlayer.play("Fire")
    if raycast.is_colliding():
        var hit_object = raycast.get_collider()
        #TODO make list of hittable scenes and tack that way if we have more than one enemey type
        if hit_object.get_class() == "Minion":
            var knockback_direction = raycast.get_collision_normal()
            knockback_direction.x *= -1
            hit_object.take_damage(20, knockback_direction * knockback_force)
    
func apply_damage(enemy):
    pass

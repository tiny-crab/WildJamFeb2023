extends Node2D

const BASE_DAMAGE = 20
const MIN_DAMAGE = 1
const DAMAGE_DROPOFF_MODIFIER = 2

onready var raycast = $RayCast2D
onready var shotgunSprite = $ShotgunSprite
onready var animationPlayer = $AnimationPlayer

var enable_self_knockback = false
var knockback_force = 100
var damage = BASE_DAMAGE

func _ready():
    #ensure shotgun starts at frame 0
    shotgunSprite.frame = 0

func alter_damage(damage_to_add):
    damage = clamp(damage + damage_to_add, MIN_DAMAGE, 10000000000000)

func shoot():
    animationPlayer.play("Fire")
    if raycast.is_colliding():
        var hit_object = raycast.get_collider()
        #TODO make list of hittable scenes and tack that way if we have more than one enemey type
        if hit_object.get_class() == "Minion" or hit_object.get_class() == "Boss":
            var knockback_direction = raycast.get_collision_normal()
            knockback_direction.x *= -1
            hit_object.take_damage(damage, knockback_direction * knockback_force)

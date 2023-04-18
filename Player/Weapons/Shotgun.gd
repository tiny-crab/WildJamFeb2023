extends Node2D

const BASE_DAMAGE = 20
const MIN_DAMAGE = 1
const ZONE_DISTANCES = [50, 75, 110]
const ZONE_MULTIPLIERS = [1.5, 1, 0.75]
const DAMAGE_DROPOFF_MODIFIER = 2

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

func _on_Hitbox_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
    var hit_object = body
    if hit_object.get_class() == "Minion" or hit_object.get_class() == "Boss":
        var distance = global_position.distance_to(hit_object.global_position)
        var zone_multiplier = 0
        for i in range(ZONE_DISTANCES.size()):
            var zone = ZONE_DISTANCES[i]
            if distance < zone:
                zone_multiplier = ZONE_MULTIPLIERS[i]
                break
        if zone_multiplier > 0:
            var knockback_direction = global_position.direction_to(hit_object.global_position)
            knockback_direction.x *= -1
            hit_object.take_damage(damage * zone_multiplier, knockback_direction * knockback_force)


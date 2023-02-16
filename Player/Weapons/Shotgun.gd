extends Node2D

const BASE_DAMAGE = 100
const DAMAGE_DROPOFF_MODIFIER = 2

onready var raycast = $RayCast2D
onready var shotgunSprite = $ShotgunSprite

var enable_knockback = false
var knockback_force = 100

func _process(delta):
    pass

func shoot():
    print("Bang")
    if raycast.is_colliding():
        var hit_object = raycast.get_collider()
        #TODO make list of hittable scenes and tack that way if we have more than one enemey type
        if hit_object.name == "Minion":
            hit_object.take_damage(20)
    
func apply_damage(enemy):
    pass

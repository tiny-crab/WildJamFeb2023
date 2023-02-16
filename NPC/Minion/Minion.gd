extends KinematicBody2D

onready var collision = $CollisionShape2D

var max_health = 100
var current_health = max_health

func _process(delta):
    if current_health <= 0:
        queue_free()

func take_damage(damage_to_receive):
    current_health -= damage_to_receive
    print(current_health)

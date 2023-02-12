extends Node2D

const SPEED = 50

onready var chain = $ChainSprite

var direction = Vector2.ZERO
var tip = Vector2.ZERO

var flying = false
var hooked = false

func shoot(dir):
    direction = dir.normalized()
    flying = true
    tip = self.global_position
    
func release():
    flying = false
    hooked = false
    
func _process(delta):
    self.visible = flying or hooked
    if not self.visible:
        return
    var tip_loc = to_local(tip)

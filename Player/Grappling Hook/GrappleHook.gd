extends Node2D

const SPEED = 50
const MAX_LENGTH = 700

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
    
    chain.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
    $Hook.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
    chain.position = tip_loc
    chain.region_rect.size.y = tip_loc.length()
    
    if tip_loc.length() >= MAX_LENGTH:
        flying = false
    
func _physics_process(delta):
    $Hook.global_position = tip
    if flying:
        if $Hook.move_and_collide(direction * SPEED):
            hooked = true
            flying = false
    tip = $Hook.global_position
    

extends Node2D

const SPEED = 20
const INITIAL_LENGTH = 700
const INITIAL_GRAPPLE_DURATION = 1.25

var chain_length = INITIAL_LENGTH
var grapple_duration = INITIAL_GRAPPLE_DURATION

onready var chain = $ChainSprite
onready var timer = $GrappleTimer

var direction = Vector2.ZERO
var tip = Vector2.ZERO

var flying = false
var hooked = false

signal grappling_released

func _ready():
    timer.connect("timeout", self, "_on_Timer_timeout")
    timer.wait_time = grapple_duration

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
    
    if tip_loc.length() >= chain_length:
        flying = false
    
func _physics_process(delta):
    $Hook.global_position = tip
    if flying:
        if $Hook.move_and_collide(direction * SPEED):
            timer.start()
            hooked = true
            flying = false
    tip = $Hook.global_position
    
func _on_Timer_timeout():
    emit_signal("grappling_released")
    release()
    timer.stop()

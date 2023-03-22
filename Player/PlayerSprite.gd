extends Sprite

const AIR_SCALE_LERP_VELOCITY = 8
const GROUND_SCALE_LERP_VELOCITY = 10
var targetScale = Vector2(1, 1)
var isOnFloor = false
var facingRight = true

func _process(delta):
    var lerpVelocity = GROUND_SCALE_LERP_VELOCITY if isOnFloor else AIR_SCALE_LERP_VELOCITY
    scale.x = lerp(scale.x, targetScale.x if facingRight else -targetScale.x, lerpVelocity * delta)
    scale.y = lerp(scale.y, targetScale.y, lerpVelocity * delta)

    if $SqueezeTimer.is_stopped() and $SquashTimer.is_stopped():
        targetScale = Vector2(1, 1)

func on_land(velocity):
    targetScale = Vector2(1.2, 0.7)
    $SquashTimer.start()

func on_jump():
    targetScale = Vector2(0.8, 1.1)
    $SqueezeTimer.start()

func on_direction_change(facingRight):
    self.facingRight = facingRight
    # immediately force player sprite to flip if changing direction
    scale.x *= -1

func on_floor_status_change(isOnFloor):
    self.isOnFloor = isOnFloor

"""
.oOOOo.  ooOoOOo  .oOOOo.  o.     O    Oo     o      .oOOOo.
o     o     O    .O     o  Oo     o   o  O   O       o     o
O.          o    o         O O    O  O    o  o       O.
 `OOoo.     O    O         O  o   o oOooOoOo o        `OOoo.
      `O    o    O   .oOOo O   o  O o      O O             `O
       o    O    o.      O o    O O O      o O              o
O.    .O    O     O.    oO o     Oo o      O o     . O.    .O
 `oooO'  ooOOoOo   `OooO'  O     `o O.     O OOoOooO  `oooO'
"""

func _on_Player_on_land(velocity):
    on_land(velocity)

func _on_Player_on_jump():
    on_jump()

func _on_Player_on_direction_change(facingRight):
    on_direction_change(facingRight)


func _on_Player_on_floor_status_change(isOnFloor):
    on_floor_status_change(isOnFloor)

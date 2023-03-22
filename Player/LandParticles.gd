extends Particles2D

func on_land(velocity):
    if velocity.y > 250:
        restart()

func _on_Player_on_land(velocity):
    on_land(velocity)

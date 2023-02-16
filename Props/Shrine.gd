extends Node2D
class_name Shrine

export(bool) var isCurseShrine = true
var animationString = ""

func get_class():
    return "Shrine"

func _ready():
    animationString = "PlayerNearCurse" if isCurseShrine else "PlayerNearBoon"
    $AnimatedSprite.play(animationString)
    $AnimatedSprite.stop()

func _on_InteractHurtbox_area_entered(area):
    $InteractNotification.show()
    $AnimatedSprite.play(animationString)

func _on_InteractHurtbox_area_exited(area):
    $InteractNotification.hide()
    $AnimatedSprite.stop()

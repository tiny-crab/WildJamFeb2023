extends Node2D
class_name Shrine

export(bool) var isCurseShrine = true
var selections = []
var animationString = ""
var destroyed = false

func get_class():
    return "Shrine"

func _ready():
    animationString = "PlayerNearCurse" if isCurseShrine else "PlayerNearBoon"
    $AnimatedSprite.play(animationString)
    $AnimatedSprite.stop()
    
func destroy():
    destroyed = true
    $AnimatedSprite.play("DestroyedCurse" if isCurseShrine else "DestroyedBoon")

func _on_InteractHurtbox_area_entered(area):
    if (!destroyed):
        $InteractNotification.show()
        $AnimatedSprite.play(animationString)

func _on_InteractHurtbox_area_exited(area):
    if (!destroyed):
        $InteractNotification.hide()
        $AnimatedSprite.stop()

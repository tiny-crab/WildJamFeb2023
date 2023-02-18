extends Node2D
class_name Shrine

export(bool) var isCurseShrine = true
var animationString = ""
var destroyed = false

var curseTutorialText = [
    "The cursed, blood red sap running from this tree bark withers and shrivels your skin on contact.",
    "Taking sap will weaken you in different ways, but you can use the sap to gain power from sacred trees."
   ]
var boonTutorialText = [
    "The soothing, moss-green sap running from this tree bark cools and heals your skin on contact.",
    "You can use your cursed tree sap to gain power from these sacred trees."
   ]

signal queue_dialogue(textArray)

func get_class():
    return "Shrine"

func _ready():
    animationString = "PlayerNearCurse" if isCurseShrine else "PlayerNearBoon"
    $AnimatedSprite.play(animationString)
    $AnimatedSprite.stop()
    SignalBus.add_emitter("queue_dialogue", self)
    
func destroy():
    destroyed = true
    $AnimatedSprite.play("DestroyedCurse" if isCurseShrine else "DestroyedBoon")

func _on_InteractHurtbox_area_entered(area):
    if (!destroyed):
        $InteractNotification.show()
        $AnimatedSprite.play(animationString)
        if (GlobalOptions.tutorialsEnabled):
            if (!GlobalOptions.curseTutorialQueued and isCurseShrine):
                emit_signal("queue_dialogue", curseTutorialText)
                GlobalOptions.curseTutorialQueued = true
            if (!GlobalOptions.boonTutorialQueued and !isCurseShrine):
                emit_signal("queue_dialogue", boonTutorialText)
                GlobalOptions.boonTutorialQueued = true

func _on_InteractHurtbox_area_exited(area):
    if (!destroyed):
        $InteractNotification.hide()
        $AnimatedSprite.stop()

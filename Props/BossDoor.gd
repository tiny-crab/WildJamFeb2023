extends Node2D

var keysPickedUp = 0
signal queue_dialogue(textArray)

func _ready():
    SignalBus.add_listener("interacted_with_key", self, "_on_Key_pickup")
    SignalBus.add_emitter("queue_dialogue", self)

func _on_Key_pickup(node):
    keysPickedUp += 1
    if (keysPickedUp == 1):
        print("keyWest complete")
        $LockWest.show()
    if (keysPickedUp == 2):
        print("keyEast complete")
        $LockEast.show()
    if (keysPickedUp == 3):
        print("keySouth complete")
        $LockSouth.show()
    
func _on_InteractHurtbox_area_entered(area):
        if (GlobalOptions.tutorialsEnabled and !GlobalOptions.bossTutorialQueued):
            emit_signal("queue_dialogue", [
                "This monstrosity is the reason you came here. Even while shackled with deep magic, its power grows.",
                "The magic that binds it works two ways: you can't harm it while it is still imprisoned. Free it so you can destroy it forever.",
                "As you gaze at it, a probing thought enters your mind. It offers you power... great power.",
                "Making a pact with this demon could be a trap. Or - can you wield this power and defeat it more easily?",
            ])
            GlobalOptions.bossTutorialQueued = true
        $InteractNotification.show()


func _on_InteractHurtbox_area_exited(area):
    $InteractNotification.hide()

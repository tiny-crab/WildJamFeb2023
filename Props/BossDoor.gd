extends Node2D

var keysPickedUp = 0
var pactOffered = false
signal queue_dialogue(textArray)
signal boss_unlocked()
signal show_pact_menu()

func _ready():
    SignalBus.add_listener("interacted_with_key", self, "_on_Key_pickup")
    SignalBus.add_listener("interacted_with_boss", self, "_on_Interacted_with_boss")
    SignalBus.add_listener("pact_signed", self, "_on_Pact_signed")
    SignalBus.add_listener("pact_offered", self, "_on_Pact_offered")
    SignalBus.add_listener("boss_unlocked", self, "_on_Boss_unlocked")
    SignalBus.add_listener("boss_powered_up", self, "_on_Boss_powered_up")
    SignalBus.add_emitter("queue_dialogue", self)
    SignalBus.add_emitter("show_pact_menu", self)
    SignalBus.add_emitter("boss_unlocked", self)

func _on_Key_pickup(node):
    keysPickedUp += 1
    if (keysPickedUp == 1):
        $LockWest.show()
    if (keysPickedUp == 2):
        $LockEast.show()
    if (keysPickedUp == 3):
        $LockSouth.show()
        
func _on_Interacted_with_boss(bossNode):
    if keysPickedUp < 3 and pactOffered:
        emit_signal("show_pact_menu")
    elif keysPickedUp == 3:
        emit_signal("boss_unlocked")
        
func _on_Pact_signed():
    $InteractNotification.hide()
    pactOffered = false
    
func _on_Boss_unlocked():
    hide()
    
func _on_Boss_powered_up(powerLevel):
    $ProgressBar.value = powerLevel

func _on_Pact_offered():
    if !pactOffered:
        emit_signal("queue_dialogue", [
            "You feel a brief tickle before a pulse of latent energy hits the base of your skull.",
            "The demon has a proposition for you. Go interact with it and hear about the deal it wants to strike with you.",
        ])
    pactOffered = true
    
func _on_InteractHurtbox_area_entered(area):
        if (GlobalOptions.tutorialsEnabled and !GlobalOptions.bossTutorialQueued):
            emit_signal("queue_dialogue", [
                "This monstrosity is the reason you came here. Even while shackled with deep magic, its power grows.",
                "The magic that binds it works two ways: you can't harm it while it is still imprisoned. Free it so you can destroy it forever.",
                "As you gaze at it, a probing thought enters your mind. It offers you power... great power.",
                "Making a pact with this demon could be a trap. Or - can you wield this power and defeat it more easily?",
            ])
            GlobalOptions.bossTutorialQueued = true
        if pactOffered:
            $InteractNotification.show()


func _on_InteractHurtbox_area_exited(area):
    $InteractNotification.hide()

func get_class():
    return "Boss"

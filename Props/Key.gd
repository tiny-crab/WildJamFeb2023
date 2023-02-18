extends Node2D

signal key_pickup
signal queue_dialogue(textArray)

onready var notification = get_node("InteractNotification")

func get_class():
    return "Key"

func _ready():    
    SignalBus.add_listener("interacted_with_key", self, "_on_Interacted_with_key")
    SignalBus.add_emitter("queue_dialogue", self)
    
func _on_Interacted_with_key(node):
    if (node.name == name):
        emit_signal("key_pickup")
        queue_free()

func _on_InteractHurtbox_area_entered(area):
    if (GlobalOptions.tutorialsEnabled and !GlobalOptions.keyTutorialQueued):
        emit_signal("queue_dialogue", [
            "When you pick up this key (press E!), all shrines in this area will be destroyed.",
            "Until you return to the starting room, the boss will power up rapidly. Be quick!",
        ])
        GlobalOptions.keyTutorialQueued = true
    notification.show()

func _on_InteractHurtbox_area_exited(area):
    notification.hide()

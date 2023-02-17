extends Node2D

signal key_pickup(node)

onready var notification = get_node("InteractNotification")

func get_class():
    return "Key"

func _ready():    
    SignalBus.add_listener("interacted_with_key", self, "_on_Interacted_with_key")
    
func _on_Interacted_with_key(node):
    if (node.name == name):
        queue_free()

func _on_InteractHurtbox_area_entered(area):
    notification.show()

func _on_InteractHurtbox_area_exited(area):
    notification.hide()

extends Node2D

signal key_pickup(node)

onready var notification = get_node("InteractNotification")

func _ready():
    var player = get_parent().get_node("Player")
    player.connect("player_interacted", self, "_on_Player_interacted")
    
    SignalBus.add_emitter("key_pickup", self)
    
func _on_Player_interacted(node):
    if (node.name == name):
        emit_signal("key_pickup", self)
        queue_free()

func _on_InteractHurtbox_area_entered(area):
    notification.show()

func _on_InteractHurtbox_area_exited(area):
    notification.hide()

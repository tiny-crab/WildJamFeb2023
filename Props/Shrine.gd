extends Node2D

onready var notification = get_node("InteractNotification")

func _ready():
    var player = get_parent().get_node("Player")
    player.connect("player_interacted", self, "_on_Player_interacted")
    
func _on_Player_interacted(node):
    if (node.name == name):
        get_owner().get_node("ShrineUI").show()


func _on_InteractHurtbox_area_entered(area):
    notification.show()


func _on_InteractHurtbox_area_exited(area):
    notification.hide()

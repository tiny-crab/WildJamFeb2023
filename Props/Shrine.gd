extends Node2D
class_name Shrine

onready var notification = get_node("InteractNotification")

export(bool) var isCurseShrine = true

func get_class():
    return "Shrine"

func _on_InteractHurtbox_area_entered(area):
    notification.show()

func _on_InteractHurtbox_area_exited(area):
    notification.hide()

extends Node2D
class_name Shrine

export(bool) var isCurseShrine = true

func get_class():
    return "Shrine"

func _on_InteractHurtbox_area_entered(area):
    $InteractNotification.show()

func _on_InteractHurtbox_area_exited(area):
    $InteractNotification.hide()

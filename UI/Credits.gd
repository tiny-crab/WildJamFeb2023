extends Panel

signal credits_dismissed


func _on_Dismiss_pressed():
    emit_signal("credits_dismissed")
    hide()

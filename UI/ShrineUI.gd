extends Control

func _on_CloseButton_pressed():
    get_owner().get_node("ShrineUI").hide()

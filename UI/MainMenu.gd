extends Control

func _ready():
    $Options.hide()
    $Credits.hide()

func _on_Start_pressed():
    get_tree().change_scene("res://Level/DraftLevel.tscn")

func _on_Options_pressed():
    $Options.show()
    $Buttons.hide()

func _on_Credits_pressed():
    $Credits.show()
    $Buttons.hide()

func _on_Quit_pressed():
    get_tree().quit()

func _on_Options_options_saved():
    $Buttons.show()

func _on_Credits_credits_dismissed():
    $Buttons.show()

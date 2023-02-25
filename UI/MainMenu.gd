extends Control

func _ready():
    $Options.hide()
    $Credits.hide()

func _on_Start_pressed():
    SoundPlayer.play_click()
    get_tree().change_scene("res://Level/DraftLevel.tscn")

func _on_Options_pressed():
    SoundPlayer.play_click()
    $Options.show()
    $Buttons.hide()

func _on_Credits_pressed():
    SoundPlayer.play_click()
    $Credits.show()
    $Buttons.hide()

func _on_Quit_pressed():
    SoundPlayer.play_click()
    get_tree().quit()

func _on_Options_options_saved():
    SoundPlayer.play_click()
    $Buttons.show()

func _on_Credits_credits_dismissed():
    SoundPlayer.play_click()
    $Buttons.show()

extends VBoxContainer

signal options_saved

func _ready():
    $VolumeSlider.value = GlobalOptions.volume
    $TutorialsCheckButton.pressed = GlobalOptions.tutorialsEnabled

func _on_VolumeSlider_value_changed(value):
    GlobalOptions.volume = value

func _on_Save_pressed():
    emit_signal("options_saved")
    hide()

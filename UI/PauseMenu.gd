extends Panel

func _ready():
    SignalBus.add_emitter("resumed_game", self)
    $Options.hide()
    $QuitConfirmation.hide()
    
func _process(delta):
    if Input.is_action_just_pressed("pause"):
        if get_tree().paused == false:
            pause_game()
        else:
            resume_game()
        
func pause_game():
    show()
    get_tree().paused = true
    
func resume_game():
    hide()
    get_tree().paused = false
    
func _on_Resume_pressed():
    SoundPlayer.play_click()
    resume_game()

func _on_Options_pressed():
    SoundPlayer.play_click()
    $Buttons.hide()
    $Options.show()

func _on_Options_options_saved():
    SoundPlayer.play_click()
    $Options.hide()
    $Buttons.show()

func _on_Quit_pressed():
    SoundPlayer.play_click()
    $Buttons.hide()
    $QuitConfirmation.show()

func _on_ConfirmQuit_pressed():
    SoundPlayer.play_click()
    get_tree().quit()

func _on_Cancel_pressed():
    SoundPlayer.play_click()
    $Buttons.show()
    $QuitConfirmation.hide()


extends Node

func play_sound(sound):
    for audioStreamPlayer in $Players.get_children():
        if not audioStreamPlayer.playing:
            audioStreamPlayer.stream = sound
            audioStreamPlayer.play()
            break

extends Node

onready var AMBIENCE = preload("res://Assets/ambience.wav") 

onready var CALLOUT1 = preload("res://Assets/ditty_1.wav")
onready var CALLOUT2 = preload("res://Assets/ditty_2.wav")
onready var CALLOUT3 = preload("res://Assets/ditty_3.wav")
onready var CALLOUT4 = preload("res://Assets/ditty_4.wav")

onready var clicks = [
    preload("res://Assets/kenney_uiaudio/Audio/click1.ogg"),
    preload("res://Assets/kenney_uiaudio/Audio/click2.ogg"),
    preload("res://Assets/kenney_uiaudio/Audio/click3.ogg"),
    preload("res://Assets/kenney_uiaudio/Audio/click4.ogg"),
    preload("res://Assets/kenney_uiaudio/Audio/click5.ogg"),
   ]

func play_sound(sound):
    for audioStreamPlayer in $Players.get_children():
        if not audioStreamPlayer.playing:
            audioStreamPlayer.stream = sound
            audioStreamPlayer.play()
            break

func play_callout(calloutSound):
    $Callouts.stream = calloutSound
    $Callouts.play()

func play_click():
    play_sound(clicks[randi() % clicks.size()])

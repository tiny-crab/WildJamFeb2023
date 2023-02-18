extends Node2D

signal queue_dialogue(textArray)

func _ready():
    SignalBus.add_listener("activated_teleporter", self, "_on_Teleporter_activated")
    SignalBus.add_listener("paused_game", self, "_on_Game_paused")
    SignalBus.add_listener("resumed_game", self, "_on_Game_resumed")
    SignalBus.add_emitter("queue_dialogue", self)
    if (GlobalOptions.tutorialsEnabled and !GlobalOptions.movementTutorialQueued):
        emit_signal("queue_dialogue", [
            "Aim with your mouse and left click to shoot.",
            "Right click to fire your grappling hook at a wall or enemy.",
            "Move around the level with WASD. Use Space to jump.",
            "Press TAB at any time to skip through the text shown in this box.",
        ])
        GlobalOptions.movementTutorialQueued = true

func _on_Teleporter_activated():
    $Player.transform = $Teleporter.transform

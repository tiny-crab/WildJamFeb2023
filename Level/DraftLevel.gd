extends Node2D

func _ready():
    SignalBus.add_listener("activated_teleporter", self, "_on_Teleporter_activated")
    SignalBus.add_listener("paused_game", self, "_on_Game_paused")
    SignalBus.add_listener("resumed_game", self, "_on_Game_resumed")

func _on_Teleporter_activated():
    $Player.transform = $Teleporter.transform

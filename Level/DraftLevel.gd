extends Node2D

func _ready():
    SignalBus.add_listener("activated_teleporter", self, "_on_Teleporter_activated")

func _on_Teleporter_activated():
    $Player.transform = $Teleporter.transform

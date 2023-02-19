extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    SignalBus.add_listener("player_health_changed", self, "_on_Player_health_changed")

func _on_Player_health_changed(newHealth):
    $VBoxContainer/CurrentHealth.value = newHealth

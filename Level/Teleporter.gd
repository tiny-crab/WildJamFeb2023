extends Node2D

func _ready():
    $AnimatedSprite.play("Idle")
    SignalBus.add_listener("activated_teleporter", self, "_on_Teleporter_activated")

func _on_Teleporter_activated():
    $AnimatedSprite.play("Activated")
    
func _on_AnimatedSprite_animation_finished():
    if ($AnimatedSprite.animation == "Activated"):
        $AnimatedSprite.play("Idle")

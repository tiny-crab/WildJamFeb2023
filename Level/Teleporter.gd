extends Node2D

signal queue_dialogue(textArray)

func _ready():
    $AnimatedSprite.play("Idle")
    SignalBus.add_listener("activated_teleporter", self, "_on_Teleporter_activated")
    SignalBus.add_emitter("queue_dialogue", self)

func _on_Teleporter_activated():
    $AnimatedSprite.play("Activated")
    
func _on_AnimatedSprite_animation_finished():
    if ($AnimatedSprite.animation == "Activated"):
        $AnimatedSprite.play("Idle")


func _on_InteractHurtbox_area_entered(area):
    if (GlobalOptions.tutorialsEnabled and !GlobalOptions.teleporterTutorialQueued):
            emit_signal("queue_dialogue", [
                "You can teleport to safety here at any time by pressing G.",
                "It's free for you to use now while this game is getting tested during the Godot Wild Jam :)",
            ])
            GlobalOptions.teleporterTutorialQueued = true

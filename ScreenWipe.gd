extends Node2D

export var velocity = 0.02
var started = false
var t = 0.0

func _ready():
    $Squeegee.transform = $Start.transform

func start():
    print("started %s" % started)
    started = true

func _physics_process(delta):
    if (started && $Squeegee.transform != $End.transform):
        t += delta * velocity
        $Squeegee.transform = $Start.transform.interpolate_with($End.transform, t)

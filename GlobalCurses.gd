extends Node

onready var curses = [
        preload("res://Resources/JumpHeightCurse.tres"),
        preload("res://Resources/MoveSpeedCurse.tres"),
        preload("res://Resources/DamageReduceCurse.tres"),
        preload("res://Resources/LoseShotgunSightCurse.tres"),
        preload("res://Resources/GrappleLengthCurse.tres"),
        preload("res://Resources/GrappleTimeCurse.tres"),
        preload("res://Resources/GrappleChargeCurse.tres"),
        
        
    ]
onready var boons = [
        preload("res://Resources/DoubleJumpBoon.tres"),
        preload("res://Resources/JumpHeightBoon.tres"),
        preload("res://Resources/MoveSpeedBoon.tres"),
        preload("res://Resources/DamageBoostBoon.tres"),
        preload("res://Resources/GrappleLengthBoon.tres"),
        preload("res://Resources/GrappleTimeBoon.tres"),
        preload("res://Resources/GrappleChargeBoon.tres")
    ]

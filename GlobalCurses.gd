extends Node

onready var curses = [
        preload("res://Resources/FallDamageCurse.tres"),
        preload("res://Resources/JumpHeightCurse.tres"),
        preload("res://Resources/MoveSpeedCurse.tres"),
        preload("res://Resources/DamageReduceCurse.tres")
    ]
onready var boons = [
        preload("res://Resources/DoubleJumpBoon.tres"),
        preload("res://Resources/JumpHeightBoon.tres"),
        preload("res://Resources/MoveSpeedBoon.tres"),
        preload("res://Resources/DamageBoostBoon.tres")
    ]

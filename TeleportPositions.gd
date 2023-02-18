extends Node2D

onready var teleportPositionOne = to_global($TeleportPosition1.position)
onready var teleportPositionTwo = to_global($TeleportPosition2.position)
onready var teleportPositionThree = to_global($TeleportPosition3.position)

onready var teleport_positions = [teleportPositionOne, teleportPositionTwo, teleportPositionThree]
signal send_teleport_positions(teleport_positions)

# Called when the node enters the scene tree for the first time.
func _ready():
    emit_signal("send_teleport_positions", teleport_positions)

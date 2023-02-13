extends Node2D

onready var lockWest = get_node("LockWest")
onready var lockEast = get_node("LockEast")
onready var lockSouth = get_node("LockSouth")

var keysPickedUp = 0

func _ready():
    SignalBus.add_listener("key_pickup", self, "_on_Key_pickup")

func _on_Key_pickup(node):
    print("%s was picked up" % node.name)
    keysPickedUp += 1
    if (keysPickedUp == 1):
        print("keyWest complete")
        lockWest.show()
    if (keysPickedUp == 2):
        print("keyEast complete")
        lockEast.show()
    if (keysPickedUp == 3):
        print("keySouth complete")
        lockSouth.show()
    

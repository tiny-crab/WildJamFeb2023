extends Node2D

var keysPickedUp = 0

func _ready():
    SignalBus.add_listener("interacted_with_key", self, "_on_Key_pickup")

func _on_Key_pickup(node):
    keysPickedUp += 1
    if (keysPickedUp == 1):
        print("keyWest complete")
        $LockWest.show()
    if (keysPickedUp == 2):
        print("keyEast complete")
        $LockEast.show()
    if (keysPickedUp == 3):
        print("keySouth complete")
        $LockSouth.show()
    

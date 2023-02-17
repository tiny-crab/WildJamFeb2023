extends Node

# TODO figure out why this is getting triggered when the other key is picked up...
# is it because the node names have to be unique for signaling?? D:
func _on_Key_key_pickup():
    print("key picked up")
    # $ScreenWipe.start()

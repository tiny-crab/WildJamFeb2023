extends Node

func _on_Key_key_pickup():
    # $ScreenWipe.start()
    var minions = $Minions.get_children() 
    var shrines = $Shrines.get_children()
    
    for shrine in shrines:
        shrine.destroy()

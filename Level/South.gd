extends Node

func _on_KeySouth_key_pickup():
    var minions = $Minions.get_children() 
    var shrines = $Shrines.get_children()
    
    for shrine in shrines:
        shrine.destroy()

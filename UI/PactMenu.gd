extends Panel

signal queue_dialogue(textArray)
signal curse_purchased(curseArray)
signal pact_signed()

var pactOptions = [
    preload("res://Resources/DoubleDamagePact.tres"),
    preload("res://Resources/DoubleHealthPact.tres"),
    preload("res://Resources/HoverJumpPact.tres"),
]
var pactsOffered = -1 # this is set to -1 so that the first pact offered sets the index to 0

func _ready():
    SignalBus.add_emitter("curse_purchased", self)
    SignalBus.add_emitter("pact_signed", self)
    SignalBus.add_listener("pact_offered", self, "offer_pact")
    SignalBus.add_listener("show_pact_menu", self, "_on_Show_pact_menu")
    
func offer_pact():
    pactsOffered += 1
    
func _on_Show_pact_menu(): 
    $VBoxContainer/PactName.text = pactOptions[pactsOffered].name
    $VBoxContainer/PactDetails.text = pactOptions[pactsOffered].description
    show()
    
func _on_ConfirmPact_pressed():
    emit_signal("curse_purchased", [pactOptions[pactsOffered]])
    emit_signal("pact_signed")
    hide()

func _on_DismissPact_pressed():
    hide()

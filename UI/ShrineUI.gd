extends Control

onready var curses = [
        preload("res://Resources/FallDamageCurse.tres"),
        preload("res://Resources/JumpHeightCurse.tres"),
        preload("res://Resources/MoveSpeedCurse.tres")
    ]
onready var boons = [
        preload("res://Resources/DoubleJumpBoon.tres"),
        preload("res://Resources/JumpHeightBoon.tres"),
        preload("res://Resources/MoveSpeedBoon.tres")
    ]
    
var selectedCurse: Curse = null

signal curse_purchased(curse)

func _ready():
    SignalBus.add_emitter("curse_purchased", self)
    SignalBus.add_listener("interacted_with_shrine", self, "_on_Interacted_with_shrine")

func _on_CloseButton_pressed():
    hide()

func _on_BuyButton_pressed():
    emit_signal("curse_purchased", selectedCurse)
    hide()
    
func _on_Interacted_with_shrine(isCurseShrine: bool):
    var possibilities = curses if isCurseShrine else boons
    var curseSelections = $CurseSelections.get_children()
    # ensure that we're not going to run into array indexing error
    var maxSelections = max(possibilities.size(), curseSelections.size())
    for i in range(maxSelections):
        var selectionUI = curseSelections[i]
        var selection = possibilities[i]
        selectionUI.connect("mouse_entered", self, "_curse_hovered", [selection])
        selectionUI.connect("pressed", self, "_curse_selected", [selection])
        selectionUI.set_curse(selection)
    _curse_selected(possibilities[0])
    show()

func _curse_hovered(curse: Curse):
    pass

func _curse_selected(curse: Curse):
    selectedCurse = curse
    $CurseDescription.text = curse.description
    $CurseValue.text = "You would gain %d coins" % curse.value

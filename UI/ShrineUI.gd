extends Control

onready var curses = _generate_curse_selection()
var selectedCurse: Curse = null

signal curse_purchased(curse)

func _ready():
    var curses = _generate_curse_selection()
    var curseSelections = $CurseSelections.get_children()
    # ensure that we're not going to run into array indexing error
    var maxSelections = max(curses.size(), curseSelections.size())
    for i in range(maxSelections):
        var selectionUI = curseSelections[i]
        var curse = curses[i]
        selectionUI.connect("mouse_entered", self, "_curse_hovered", [curse])
        selectionUI.connect("pressed", self, "_curse_selected", [curse])
        selectionUI.set_curse(curse)
    _curse_selected(curses[0])
    SignalBus.add_emitter("curse_purchased", self)

func _on_CloseButton_pressed():
    hide()

func _on_BuyButton_pressed():
    emit_signal("curse_purchased", selectedCurse)
    hide()

func _generate_curse_selection():
    return [
        load("res://Resources/FallDamageCurse.tres"),
        load("res://Resources/JumpHeightCurse.tres"),
        load("res://Resources/MoveSpeedCurse.tres")
    ]

func _curse_hovered(curse: Curse):
    pass

func _curse_selected(curse: Curse):
    selectedCurse = curse
    $CurseDescription.text = curse.description
    $CurseValue.text = "You would gain %d coins" % curse.value

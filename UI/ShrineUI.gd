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
    
var displayedCurse: Curse = null
var curseOptions = []
var selectedCurses = []
var curseSelectionUIs = []
var isCurseUI: bool

signal curse_purchased(curse)

func _ready():
    SignalBus.add_emitter("curse_purchased", self)
    SignalBus.add_listener("interacted_with_shrine", self, "_on_Interacted_with_shrine")
    curseSelectionUIs = $CurseSelections.get_children()
    for i in range(3):
        var selectionUI = curseSelectionUIs[i]
        selectionUI.connect("toggled", self, "_curse_toggled", [i])
    
func _on_Interacted_with_shrine(isCurseShrine: bool):
    curseOptions = curses if isCurseShrine else boons
    isCurseUI = isCurseShrine

    for i in range(3):
        var selectionUI = curseSelectionUIs[i]
        selectionUI.curseData = curseOptions[i]
        selectionUI.pressed = false

    displayedCurse = curseOptions[0]
    $CurseDescription.text = ""
    $CurseValue.text = ""
    show()

func _curse_toggled(toggled_state, curseIndex: int):
    var curse = curseOptions[curseIndex]
    displayedCurse = curse
    $CurseDescription.text = displayedCurse.description
    if toggled_state:
        selectedCurses.append(curse)
    else:
        selectedCurses.erase(curse)
    refresh_selected_curses()

func refresh_selected_curses():
    var sum = 0
    for curse in selectedCurses:
        sum += curse.value

    var verb = "gain" if isCurseUI else "spend"
    var noun = "curse" if isCurseUI else "boon"
    var descriptor = "bonus" if isCurseUI else "extra"
    var lastSelectedCurseText = "You would {0} {1} coin(s)".format([verb, sum])
    if selectedCurses.size() == 1:
        $CurseValue.text = lastSelectedCurseText
    elif selectedCurses.size() > 1:
        var bonusText = " + {0} {1} coins for each {2} taken at once".format([(selectedCurses.size()-1), descriptor, noun])
        $CurseValue.text = lastSelectedCurseText + bonusText
    else:
        $CurseValue.text = ""

func _on_CloseButton_pressed():
    displayedCurse = null
    selectedCurses = []
    hide()

func _on_BuyButton_pressed():
    displayedCurse = null
    selectedCurses = []
    emit_signal("curse_purchased", selectedCurses)
    hide()

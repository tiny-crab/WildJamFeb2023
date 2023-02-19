extends Control

var activatedShrine: Shrine = null
var displayedCurse: Curse = null
var availableSap: int = 0
var curseOptions = []
var selectedCurses = []
var curseSelectionUIs = []
var isCurseUI: bool

signal curse_purchased(curses)

func _ready():
    SignalBus.add_emitter("curse_purchased", self)
    SignalBus.add_listener("interacted_with_shrine", self, "_on_Interacted_with_shrine")
    curseSelectionUIs = $CurseSelections.get_children()
    for i in range(3):
        var selectionUI = curseSelectionUIs[i]
        selectionUI.connect("toggled", self, "_curse_toggled", [i])
    
func _on_Interacted_with_shrine(shrine: Shrine, currentSap: int):
    availableSap = currentSap
    activatedShrine = shrine
    curseOptions = shrine.selections
    isCurseUI = shrine.isCurseShrine

    for i in range(3):
        var selectionUI = curseSelectionUIs[i]
        selectionUI.curseData = curseOptions[i]
        selectionUI.pressed = false

    displayedCurse = curseOptions[0]
    $CurseDescription.text = ""
    $CurseValue.text = ""
    $TotalSap.text = "%s total sap" % availableSap
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

    var verb = "gather" if isCurseUI else "deposit"
    var noun = "curse" if isCurseUI else "boon"
    var descriptor = "bonus" if isCurseUI else "extra"
    var lastSelectedCurseText = "You would {0} {1} sap".format([verb, sum])
    if selectedCurses.size() == 1:
        $CurseValue.text = lastSelectedCurseText
    elif selectedCurses.size() > 1:
        var bonusText = " + {0} {1} sap for each {2} taken at once".format([(selectedCurses.size()-1), descriptor, noun])
        $CurseValue.text = lastSelectedCurseText + bonusText
    else:
        $CurseValue.text = ""

func _on_CloseButton_pressed():
    displayedCurse = null
    selectedCurses = []
    hide()
    
func _compute_cost():
    var sum = 0
    for curse in selectedCurses:
        sum += curse.value
    sum += selectedCurses.size()-1
    print("total sum %s" % sum)
    return sum

func _on_BuyButton_pressed():
    if !isCurseUI and availableSap < _compute_cost():
        pass
    else:
        activatedShrine.destroy()
        emit_signal("curse_purchased", selectedCurses)
        displayedCurse = null
        selectedCurses = []
        hide()
    

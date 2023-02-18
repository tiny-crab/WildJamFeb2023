extends Panel

var queue = []

func _ready():
    SignalBus.add_listener("queue_dialogue", self, "_on_Dialogue_queued")
    $Timer.start()
    hide()
    
func _process(delta):
    if Input.is_action_just_pressed("skip"):
        skip_dialogue()
    $ProgressBar.value = ($Timer.time_left / $Timer.wait_time) * 100
    
func _on_Dialogue_queued(textArray):
    show()
    queue.append_array(textArray)
    if queue.size() == textArray.size():
        $Timer.start()
        $Label.text = queue.pop_front()
        
func skip_dialogue():
    if queue.size() > 0:
        $Label.text = queue.pop_front()
        $Timer.start()
    else:
        hide_dialogue()
        
func hide_dialogue():
    hide()
    $Label.text = ""

func _on_Timer_timeout():
    if queue.size() > 0:
        skip_dialogue()
    else:
        hide_dialogue()

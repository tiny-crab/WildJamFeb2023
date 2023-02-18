extends Panel

var queue = []

func _ready():
    SignalBus.add_listener("queue_dialogue", self, "_on_Dialogue_queued")
    $Timer.start()
    hide()
    
func _process(delta):
    $ProgressBar.value = ($Timer.time_left / $Timer.wait_time) * 100
    
func _on_Dialogue_queued(textArray):
    show()
    queue.append_array(textArray)
    if queue.size() == textArray.size():
        $Timer.start()
        $Label.text = queue.pop_front()

func _on_Timer_timeout():
    if queue.size() > 0:
        $Label.text = queue.pop_front()
        $Timer.start()
    else:
        hide()

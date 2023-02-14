extends Control

var curseData: Curse setget set_curse

func set_curse(newValue):
    curseData = newValue
    $VBoxContainer/Label.text = curseData.name

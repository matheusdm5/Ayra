extends Control

var Status = preload("res://Resources/Status.tres")
var Obj = preload("res://Resources/Objectives.tres")

func _ready():
	Obj.map = 1
	Obj.e_counter = 15
	Status.Player_HP = 4

func _on_StartButton_pressed():
	get_tree().change_scene("res://Scenes/Maps/Level 1.tscn")

func _on_InstructionsButton_pressed():
	pass

func _on_LeaderboardButton_pressed():
	pass
	
func _on_QuitButton_pressed():
	get_tree().quit()

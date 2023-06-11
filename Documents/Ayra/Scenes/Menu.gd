extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Scenes/Maps/Level 1.tscn")

func _on_InstructionsButton_pressed():
	pass

func _on_LeaderboardButton_pressed():
	pass
	
func _on_QuitButton_pressed():
	get_tree().quit()

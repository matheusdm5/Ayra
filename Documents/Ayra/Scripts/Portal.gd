extends StaticBody2D

var Objective = preload("res://Resources/Objectives.tres")

func _ready():
	$AnimationPlayer.play("Closed")

func _process(delta):
	if Objective.e_counter == 0:
		$AnimationPlayer.play("Open")
		$Portal/CollisionShape2D.disabled = false

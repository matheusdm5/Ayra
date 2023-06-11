extends CanvasLayer

signal use_move_vector_aim

var move_vector = Vector2(0,0)
var joystick_active = false

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if $TouchScreenButton.is_pressed():
			move_vector = calculate_move_vector(event.position)
			joystick_active = true
			$Joystick_Center.position = event.position
			$Joystick_Center.visible = true
		if event is InputEventScreenTouch:
			if event.pressed == false:
				joystick_active = false
				$Joystick_Center.visible = false
				
func _physics_process(delta):
	if joystick_active:
		emit_signal("use_move_vector_aim", move_vector)

func calculate_move_vector(event_position):
	var texture_center = $TouchScreenButton.position + Vector2(80,80)
	return (event_position - texture_center).normalized()

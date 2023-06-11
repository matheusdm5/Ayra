extends KinematicBody2D

var movespeed = 50

var facing_right = true
var facing_down = true

var can_fire = true
var fire_rate = 0.6

var key_input = true
var mouse_input = true

var portal = null

var Status = preload("res://Resources/Status.tres")
var Obj = preload("res://Resources/Objectives.tres")

var finished = 0

var level_2 = 0
var level_3 = 0

onready var Arrow = $RayCast_Arrow

func _ready():
	printerr("Player HP - ", Status.Player_HP)
	$AnimationPlayer.play("Idle")
	
	var tree = get_tree()
	if tree.has_group("Portal"):
		portal = tree.get_nodes_in_group("Portal")[0]

func _physics_process(delta):
	Arrow.look_at(portal.global_position)

	enemy_counter()
	if Input.is_action_pressed("shoot") and can_fire == true:
		shoot()
	if Obj.e_counter >= 1:
		$RayCast_Arrow/Arrow.modulate = Color(1, 1, 1, 0)
	if Obj.e_counter == 0:
		$RayCast_Arrow/Arrow.modulate = Color(1, 1, 1, 1)
	if Obj.map == 2:
		if level_2 == 0:
			$Life.set_frame(7)
			level_2 = 1
	if Obj.map == 3:
		if level_3 == 0:
			$Life.set_frame(1)
			level_3 = 1
	
	get_mouse_position()
	movement()
	
func movement():
	var motion = Vector2()

	if facing_right == true:
		$Ayra_Sprite.scale.x = 1
		$Wand_Ray.scale.y = 1
	else:
		$Ayra_Sprite.scale.x = -1
		$Wand_Ray.scale.y = -1
	
	if Input.is_action_pressed("up") and Input.is_action_pressed("right") and key_input == true:
		motion.y -= 1
		motion.x += 1
		$AnimationPlayer.play("Walk")
	elif Input.is_action_pressed("up") and Input.is_action_pressed("left") and key_input == true:
		motion.y -= 1
		motion.x -= 1
	elif Input.is_action_pressed("down") and Input.is_action_pressed("left") and key_input == true:
		motion.y += 1
		motion.x -= 1
	elif Input.is_action_pressed("down") and Input.is_action_pressed("right") and key_input == true:
		motion.y += 1
		motion.x += 1
	elif Input.is_action_pressed("up") and key_input == true:
		motion.y -= 1
		$AnimationPlayer.play("Walk_Up")
	elif Input.is_action_pressed("down") and key_input == true:
		motion.y += 1
		$AnimationPlayer.play("Walk_Down")
	elif Input.is_action_pressed("right") and key_input == true:
		motion.x += 1
		$AnimationPlayer.play("Walk")
	elif Input.is_action_pressed("left") and key_input == true:
		motion.x -= 1
		$AnimationPlayer.play("Walk")
	elif Input.is_action_just_released("left") and key_input == true or Input.is_action_just_released("right") and key_input == true or Input.is_action_just_released("up") and key_input == true or Input.is_action_just_released("down") and key_input == true:
		$AnimationPlayer.play("Idle")
		
	motion = motion.normalized()
	motion = move_and_slide(motion * movespeed)

func get_mouse_position():
	if mouse_input == true:
		$Camera_Ray.look_at(get_global_mouse_position())
		$Wand_Ray.look_at(get_global_mouse_position())
		if get_global_mouse_position().x > global_position.x:
			facing_right = true
		elif get_global_mouse_position().x < global_position.x:
			facing_right = false
	
func shoot():
	can_fire = false
	var bullet = load("res://Scenes/Weapons/Bullets/Bullet.tscn")
	bullet = bullet.instance()
	$AnimationWand.play("Shoot")
			
	bullet.direction = $Wand_Ray/Wand_Sprite/BulletSpawn.global_position - global_position
	bullet.global_position = $Wand_Ray/Wand_Sprite/BulletSpawn.global_position
	get_parent().add_child(bullet)
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true

func Player_die():
	movespeed = 0
	key_input = false
	mouse_input = false
	$AnimationPlayer.play("Death")
	printerr("Player Erased Sucessfuly")

func take_damage():
	
	printerr("Player HP - ", Status.Player_HP)
	if Obj.map == 1:
		if Status.Player_HP >= 5:
			Status.Player_HP = 4
		if Status.Player_HP == 4:
			$Life.set_frame(0)
		if Status.Player_HP == 3:
			$Life.set_frame(2)
		if Status.Player_HP == 2:
			$Life.set_frame(4)
		if Status.Player_HP == 1:
			$Life.set_frame(6)
		if Status.Player_HP <= 0:
			$Life.set_frame(8)
			Player_die()
			
	if Obj.map >= 2:
		if Status.Player_HP == 10:
			$Life.set_frame(1)
		if Status.Player_HP == 9:
			$Life.set_frame(3)
		if Status.Player_HP == 8:
			$Life.set_frame(5)
		if Status.Player_HP == 7:
			$Life.set_frame(7)
		if Status.Player_HP == 6:
			$Life.set_frame(9)
		if Status.Player_HP == 5:
			$Life.set_frame(11)
		if Status.Player_HP == 4:
			$Life.set_frame(13)
		if Status.Player_HP == 3:
			$Life.set_frame(15)
		if Status.Player_HP == 2:
			$Life.set_frame(17)
		if Status.Player_HP == 1:
			$Life.set_frame(19)
		if Status.Player_HP == 0:
			$Life.set_frame(21)
			Player_die()

func _on_Hurtbox_area_entered(Hitbox):
	if Hitbox is Area2D:
		var collision_name = Hitbox.name
		
		if collision_name == "Hitbox_E_SingleBullet":
			Status.Player_HP -= Status.E_SingleBullet_DMG - Status.Player_DEF
			take_damage()
		elif collision_name == "Hitbox_Slime":
			printerr("Player hit by: ", collision_name)
			Status.Player_HP -= Status.Slime_DMG - Status.Player_DEF
			take_damage()
		elif collision_name == "Hitbox_F_Skeleton":
			printerr ("Player hit by: ", collision_name)
			Status.Player_HP -= Status.F_Skeleton_DMG - Status.Player_DEF
			take_damage()
		elif collision_name == "Hitbox_Bomb":
			printerr("Player hit by: ", collision_name)
			Status.Player_HP -= Status.Bomb_DMG - Status.Player_DEF
			take_damage()
#		elif collision_name == "Life_Area":
#			printerr("Player Healed: ", collision_name)
#			Status.Player_HP += 1
#			take_damage()
		elif collision_name == "Portal":
			Status.Player_HP = 4
			if Obj.map == 2:
				Obj.e_counter = Obj.lv_2
				Status.Player_HP = 7
				get_tree().change_scene("res://Scenes/Maps/Level 2.tscn")
			
			if Obj.map == 3:
				Obj.e_counter = Obj.lv_3
				Status.Player_HP = 10
				get_tree().change_scene("res://Scenes/Maps/Level 3.tscn")
			
			if Obj.map == 4:
				get_tree().change_scene("res://Scenes/Maps/End.tscn")
			
func enemy_counter():
	$Label.text = str(Obj.e_counter)
	if Obj.e_counter == 0:
		if finished == 0:
			Obj.map += 1
			finished = 1
			$Label.modulate = Color(1, 1, 1, 0)
			if Obj.e_counter < 0:
				Obj.e_counter = 0
			

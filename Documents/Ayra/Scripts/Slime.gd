extends KinematicBody2D

var Status = preload("res://Resources/Status.tres")
var Objective = preload("res://Resources/Objectives.tres")

var HP = Status.Slime_HP
var DEF = Status.Slime_DEF

export var speed = 35
var velocity = Vector2.ZERO

var timer = 3.4
var timer_rush = 3.2

var attack = false

var attack_delay = 3
var rush_delay = 3

var path: Array = []
var LevelNavigation: Navigation2D = null

var player = null
var player_spotted = false
var Player_spotted_forDMG = false

var can_move = false
var idle = true

onready var line2d = $Line2D
onready var los = $LineOfSight
onready var los_DMG = $LineOfSight_DMG
onready var ATK_Timer = $ATK_Countdown
onready var ATK_Couter = $ATK_Label


func _ready():
	if idle == true:
		$AnimationPlayer.play("Idle")
	
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		LevelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

	ATK_Timer.start()

func _physics_process(delta):
	Counter_Labels()
	
	if Status.Player_HP <= 0:
		speed = 0
	
	line2d.global_position = Vector2.ZERO
	if player:
		los.look_at(player.global_position)
		los_DMG.look_at(player.global_position)

	if velocity.x > 0:
		$Milo.scale.x = -1
	if velocity.x < 0:
		$Milo.scale.x = 1
	check_player_in_line_of_sight()
	check_player_in_line_of_sightDMG()
	
	if player_spotted:
		can_move = true
		generate_path()
		navigate()
		
	_on_ATK_Countdown_timeout()
	if attack == true:
		if Player_spotted_forDMG:
			speed = 0
			attack_delay += delta
			
			if attack_delay >= timer:
				attack = false
				speed = 120
				rush_delay += delta
			if rush_delay >= timer_rush:
				rush_delay = 3
				speed = 35
				attack = false
				attack_delay += delta
				
				if attack == false:
					_ready()
	if can_move == true:
		move()

func check_player_in_line_of_sightDMG() -> bool:
	var collider_DMG = los_DMG.get_collider()
	if collider_DMG:
		Player_spotted_forDMG = true
		
		return true
	return false
	
func check_player_in_line_of_sight() -> bool:
	var collider = los.get_collider()
	if collider != null:
		var layer = collider.get_collision_layer()
		if layer == 2:
			player_spotted = true
			return true
	return false
		
func navigate():
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * speed
		
		if global_position == path[0]:
			path.pop_front()
	
func generate_path():
	if LevelNavigation != null and player != null:
		path = LevelNavigation.get_simple_path(global_position, player.global_position, false)
		line2d.points = path
		
func move():
	if HP > 0:
		idle = false
		
		if idle == false:
			velocity = move_and_slide(velocity)
			$AnimationPlayer.play("Walk")
		
func _on_Hurtbox_area_entered(Hitbox):
	if Hitbox is Area2D:
		var collision_name = Hitbox.name
		if collision_name == "Hitbox_SingleBullet":
			HP -= Status.P_SingleBullet_DMG - DEF
			printerr("Slime HP - ", HP)
			if HP == 1:
				$HP.set_frame(38)
			if HP <= 0:
				objective()
				can_move = false
				$HP.set_frame(39)
				$AnimationPlayer.play("Death")
#				Life_drop()

func _on_AnimationPlayer_animation_finished(current_animation):
	if current_animation == "Death":
		queue_free()

func _on_ATK_Countdown_timeout():
	if los_DMG.is_colliding():
		if ATK_Timer.get_time_left() == 0:
			attack = true
		else:
			attack = false

func Counter_Labels():
	var time_left_atk = round(ATK_Timer.get_time_left())
	ATK_Couter.text = str(time_left_atk)

func get_animation_name():
	var current_animation = $AnimationPlayer.get_current_animation()
	printerr (current_animation)
	return current_animation

func objective():
	Objective.e_counter -= 1
	printerr (Objective.e_counter)

#func Life_drop():
#	var Life = load("res://Scenes/Drops/Life.tscn")
#	Life = Life.instance()
#	
#	Life.global_position = $Drop.global_position
#	get_parent().add_child(Life)

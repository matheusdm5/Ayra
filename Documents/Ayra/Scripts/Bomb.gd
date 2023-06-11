extends KinematicBody2D

var Status = preload("res://Resources/Status.tres")
var Objective = preload("res://Resources/Objectives.tres")

export (String, "loop", "linear") var patrol_type = "linear"
onready var pathfollow = get_parent()

var HP = Status.Bomb_HP
var DEF = Status.Bomb_DEF

export var speed = 35
var velocity = Vector2.ZERO

var path: Array = []
var LevelNavigation: Navigation2D = null

var player = null
var player_spotted = false
var Player_spotted_forExplode = false

var can_patrol = true
var can_follow = false
var can_move = true

var opacity_on_Alarm = false
var opacity_on_AOE = false
var opacity_on_AOE_Ver = false

onready var line2d = $Line2D
onready var los = $LineOfSight
onready var los_AOE = $LineOfSight_AOE
onready var AOE = $Hitbox_Bomb/CollisionShape2D
onready var Sprite = $Bomb_Sprite

func _ready():
	$Alarm.modulate = Color(1, 1, 1, 0)
	$Explosion.modulate = Color(1, 1, 1, 0)
	$AnimationPlayer.play("Walk")
	
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		LevelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	
func patrol(delta):
	if patrol_type == 'loop':
		pathfollow.offset += speed * delta
	else:
		pass

func _physics_process(delta):
	if can_patrol == true and can_move == true and HP > 0:
		patrol(delta)
	
	line2d.global_position = Vector2.ZERO
	if player:
		los.look_at(player.global_position)
		los_AOE.look_at(player.global_position)
	
	if velocity.x > 0:
		Sprite.scale.x = -1
	if velocity.x < 0:
		Sprite.scale.x = 1
		
	check_player_in_line_of_sight()
	check_player_in_line_of_sightAOE()
	
	if player_spotted:
		can_patrol = false
		can_move = true
		generate_path()
		navigate()
		move()
		
	Player_Sportted_AOE()
		
func check_player_in_line_of_sight() -> bool:
	var collider = los.get_collider()
	if collider != null:
		var layer = collider.get_collision_layer()
		if layer == 2:
			player_spotted = true
			return true
	return false

func check_player_in_line_of_sightAOE() -> bool:
	var collider_DMG = los_AOE.get_collider()
	if collider_DMG:
		Player_spotted_forExplode = true
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
		can_patrol = false

		if can_patrol == false:
			if opacity_on_Alarm == false:
				opacity()
				opacity_on_Alarm = true
			$AnimationPlayer.play("Follow")
			speed = 60
			velocity = move_and_slide(velocity)

func opacity():
	if opacity_on_Alarm == false:
		$Alarm.modulate = Color(1, 1, 1, 1)
		$AnimationAlarm.play("Alarm")
	if opacity_on_AOE == true:
		if opacity_on_AOE_Ver == false:
			$Explosion.modulate = Color(1, 1, 1, 1)
			$AnimationAlarm.play("Explosion")
			Sprite.modulate = Color (1, 1, 1, 0)
			$Alarm.modulate = Color(1, 1, 1, 0)
			opacity_on_AOE_Ver = true

func Player_Sportted_AOE():
	if Player_spotted_forExplode:
		speed = 0
		AOE.disabled = false
		opacity_on_AOE = true
		opacity()
	
	if HP <= 0:
		speed = 0
		AOE.disabled = false
		opacity_on_AOE = true
		opacity()

func _on_AnimationAlarm_animation_finished(Explosion):
	objective()
	queue_free()

func _on_Hurtbox_area_entered(Hitbox):
	if Hitbox is Area2D:
		var collision_name = Hitbox.name
		if collision_name == "Hitbox_SingleBullet":
			HP -= Status.P_SingleBullet_DMG - DEF
			if HP <= 0:
				can_move = false
				Player_Sportted_AOE()

func objective():
	Objective.e_counter -= 1
	printerr (Objective.e_counter)

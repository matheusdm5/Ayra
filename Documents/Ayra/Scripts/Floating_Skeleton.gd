extends KinematicBody2D

var Status = preload("res://Resources/Status.tres")
var Objective = preload("res://Resources/Objectives.tres")

var facing_right = true

var HP = Status.F_Skeleton_HP
var DEF = Status.F_Skeleton_DEF
var speed = 30
var fire_timer = 0.0
const fire_rate = 1

var player = null
var player_spotted = false
var Player_spotted_forDMG = false

var fire_on = false
var opacity_on = false

onready var los = $LineOfSight
onready var los_DMG = $LineOfSight_DMG
onready var sprite = $FS_Sprite
onready var hurtbox = $Hurtbox/CollisionShape2D
onready var spotted = $Invisibility

func _ready():
	sprite.modulate = Color(1, 1, 1, 0)
	$HP.modulate = Color (1, 1, 1, 0)
	spotted.text = "P not spotted"
	
	var tree = get_tree()
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

func _physics_process(delta):
	if player:
		los.look_at(player.global_position)
		los_DMG.look_at(player.global_position)
	
	check_player_in_line_of_sight()
	
	if Status.Player_HP == 0:
		fire_on = false
	
	if player_spotted:
		if opacity_on == false:
			opacity()
			opacity_on = true
		face()
		if fire_on == true:
			fire_timer += delta
			fire_rate()
	else:
		face()
		
func check_player_in_line_of_sight() -> bool:
	var collider = los.get_collider()
	if collider != null:
		var layer = collider.get_collision_layer()
		if layer == 2:
			player_spotted = true
			return true
		else:
			player_spotted = false
			face()
			return false
	else:
		player_spotted = false
		face()
		return false
	return false

func face():
	if $LineOfSight.get_global_position().x > global_position.x:
		facing_right = true
	elif $LineOfSight.get_global_position().x < global_position.x:
		facing_right = false
	
	if facing_right == true:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1

func shoot():
	var bullet = load("res://Scenes/Weapons/Bullets/E_Bullet.tscn")
	bullet = bullet.instance()
	
	$AnimationBullet.play("Bullet_Spawn")
	
	bullet.direction = $LineOfSight_DMG/Position2D.global_position - global_position
	bullet.global_position = $LineOfSight_DMG/Position2D.global_position
	get_parent().add_child(bullet)

	fire_on = false
	var bullet2 = load("res://Scenes/Weapons/Bullets/E_Bullet.tscn")
	bullet2 = bullet2.instance()

	bullet2.direction = $LineOfSight_DMG/Position2D2.global_position - global_position
	bullet2.global_position = $LineOfSight_DMG/Position2D2.global_position
	get_parent().add_child(bullet2)
	
	fire_on = false
	var bullet3 = load("res://Scenes/Weapons/Bullets/E_Bullet.tscn")
	bullet3 = bullet3.instance()

	bullet3.direction = $LineOfSight_DMG/Position2D3.global_position - global_position
	bullet3.global_position = $LineOfSight_DMG/Position2D3.global_position
	get_parent().add_child(bullet3)
	
	fire_on = true
	

func fire_rate():
	if fire_timer >= fire_rate:
		shoot()
		fire_timer = 0.0

func opacity():
	sprite.modulate = Color(1, 1, 1, 1)
	$HP.modulate = Color (1, 1, 1, 1)
	$AnimationPlayer.play("Spawn")

func _on_AnimationPlayer_animation_finished(current_animation):
	if current_animation == ("Spawn"):
		$AnimationPlayer.play("Idle")
		hurtbox.disabled = false
		spotted.text = "Spotted"
		fire_on = true
		fire_rate()
	if current_animation == ("Death"):
		objective()
		queue_free()

func _on_Hurtbox_area_entered(Hitbox):
	if Hitbox is Area2D:
		var collision_name = Hitbox.name
		if collision_name == "Hitbox_SingleBullet":
			HP -= Status.P_SingleBullet_DMG - DEF
			printerr("Floating Skeleton - ", HP)
			if HP == 3:
				$HP.set_frame(45)
			if HP == 2:
				$HP.set_frame(46)
			if HP == 1:
				$HP.set_frame(47)
			if HP <= 0:
				fire_on = false
				$HP.set_frame(48)
				$AnimationPlayer.play("Death")

func get_animation_name():
	var current_animation = $AnimationPlayer.get_current_animation()
	printerr (current_animation)
	return current_animation

func objective():
	Objective.e_counter -= 1
	printerr (Objective.e_counter)

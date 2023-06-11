extends KinematicBody2D

func _ready():
	$AnimationPlayer.play("Idle")

func _physics_process(delta):
	var motion = Vector2.ZERO
	var speed = 0  # Definindo speed como 0 para tornar o objeto estático
	
	var collision = move_and_collide(motion)
	if collision:
		var collider_name = collision.collider.name
		print("Colisão detectada com:", collider_name)
		if collider_name == "Hurtbox_Ayra":
			print("Colisão com jogador detectada!")

#func _on_Life_Area_area_entered(Hitbox):
#	if Hitbox is Area2D:
#		var collision_name = Hitbox.name
#		if collision_name == "Hurtbox_Ayra":
#			queue_free()

extends Area2D

var direction = Vector2.RIGHT
var speed = 150

var On_collision = false

func _process(delta):
	translate(direction.normalized() * speed * delta)
	if On_collision == false:
		$AnimationPlayer.play("Object_in_Air")
	
func Collide():
	$AnimationPlayer.play("Object_Colide")
	speed = 0
	$Hitbox_SingleBullet/CollisionShape2D.disabled = true
	
func On_Collision():
	On_collision = true
	if On_collision == true:
		Collide()

func _on_AnimationPlayer_animation_finished(Object_Colide):
	queue_free()

func _on_Node2D_area_entered(area):
	On_Collision()

func _on_Node2D_body_entered(body):
	On_Collision()


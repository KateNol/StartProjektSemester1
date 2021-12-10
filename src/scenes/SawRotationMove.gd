extends Sprite


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(10)


func _process(delta):
	rotation +=5*delta
	pass

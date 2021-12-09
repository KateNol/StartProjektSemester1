extends Area2D




func _on_shards_body_entered(body):
	queue_free()

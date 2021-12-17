extends Area2D

signal shard_collected 


func _on_shards_body_entered(body):
	queue_free()
	emit_signal("shard_collected")



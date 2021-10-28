extends KinematicBody2D


const move_speed : int = 500
var direction : Vector2


func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	var collision = move_and_collide(direction*move_speed*delta)
	pass
	#if(collision != null):
	#	#print("I collided with ", collision.collider.name)
	#	if(collision.collider.has_method("on_stomp")):
	#		#print("killing enemy")
	#		collision.collider.on_stomp()
	#	queue_free()

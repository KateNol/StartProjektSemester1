extends KinematicBody2D


const move_speed : int = 500
var direction : Vector2


func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	move_and_collide(direction*move_speed*delta)

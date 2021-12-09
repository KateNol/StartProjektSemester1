extends KinematicBody2D


const move_speed : int = 500
var direction : Vector2


func _ready():
	add_to_group("PlayerWeapon")

func _process(delta):
	pass

func _physics_process(delta):
	var collision = move_and_collide(direction*move_speed*delta)


func _on_Area2D_body_entered(body : Node):
	if body.is_in_group("enemy"):
		body.take_damage(1)
		queue_free()
	if body.is_in_group("enemyweapon"):
		print("blocked")
		queue_free()
	if body.is_class("TileMap"):
		queue_free()
	#print("collided with " + str(body.name) + " - " + str(body.get_class()) + " - " +  str(body.get_groups()))


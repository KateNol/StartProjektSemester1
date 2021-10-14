extends KinematicBody2D

var direction : Vector2
var velocity : Vector2

# speeds in pixels / time
var move_speed : int = 32*6/.8
var jump_speed : int = -960
var gravity : int = 2400

var jump_timer : Timer


func input_process():
	direction = Vector2()
	
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	if Input.is_action_just_pressed("jump"):
		direction.y = -1
	

func _ready():
	velocity = Vector2()
	print("ready")

func _process(delta):
	pass
	

func _physics_process(delta):
	input_process()
	
	velocity.x = direction.x * move_speed
	velocity.y += gravity * delta
	
	if direction.y == -1 and is_on_floor():
		print("jump")
		velocity.y = jump_speed
		
	#check_for_stomp()

	velocity = move_and_slide(velocity, Vector2.UP)

func on_timer_timeout():
	pass

#func check_for_stomp():
	#for body in $Hitbox.get_overlapping_bodies():
		#if body.has_method("on_stomp") and body.is_alive:
			#body.on_stomp()
			#direction.y = -jump_speed

extends KinematicBody2D

var direction : Vector2
var velocity : Vector2

# speeds in pixels / time
var move_speed : int = 400 / 1
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
	
	


	velocity = move_and_slide(velocity, Vector2.UP)

func on_timer_timeout():
	pass

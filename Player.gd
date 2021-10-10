extends KinematicBody2D

var direction : Vector2
var velocity : Vector2

# speeds in pixels / time
var move_speed : int = 400 / 1
var jump_speed : int = -1300
var gravity : int = 100

var jump_timer : Timer


func input_process():
	direction = Vector2()
	
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	if Input.is_action_just_pressed("jump"):
		direction.y = -1
		jump_timer.start()

func _ready():
	velocity = Vector2()
	jump_timer = Timer.new()
	add_child(jump_timer)
	print("ready")

func _process(delta):
	pass

func _physics_process(delta):
	input_process()
	
	velocity.x = direction.x * move_speed
	
	
	if direction.y == -1 and is_on_floor():
		print("jump")
		velocity.y = jump_speed
	
	
	velocity.y += gravity

	velocity = move_and_slide(velocity, Vector2.UP)

func on_timer_timeout():
	pass

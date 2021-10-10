extends KinematicBody2D

var direction : Vector2
var velocity : Vector2

# speeds in pixels / time
var move_speed : int = 32*6/.8
var jump_speed : int = -960
var gravity : int = 2400

var jump_edge_tolerance : float = .1
var time_since_last_grounded : float

var jump_fall_tolerance : float = .2
var time_since_last_jump_input : float


var terminate_jump : bool


func input_process(delta):
	direction = Vector2()
	terminate_jump = false
	
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	if Input.is_action_just_pressed("jump"):
		direction.y = -1
		time_since_last_jump_input = 0
	if Input.is_action_just_released("jump"):
		terminate_jump = true
	if direction.y != -1:
		time_since_last_jump_input += delta

func _ready():
	velocity = Vector2()
	print("ready")

func _process(delta):
	pass

func _physics_process(delta):
	input_process(delta)
	
	velocity.x = direction.x * move_speed
	velocity.y += gravity * delta
	
	if is_on_floor():
		time_since_last_grounded = 0
		# jump even if jump input was when player was still in air
		if time_since_last_jump_input < jump_fall_tolerance:
			print("air-jump with tolerance time: ", str(time_since_last_jump_input))
			velocity.y = jump_speed
	else:
		time_since_last_grounded += delta
	# jump, normal
	if direction.y == -1 and is_on_floor():
		velocity.y = jump_speed
	# jump even if player is not on floor
	if direction.y == -1 and time_since_last_grounded < jump_edge_tolerance and not is_on_floor():
		print("edge-jump with tolerance time: ", str(time_since_last_grounded))
		velocity.y = jump_speed
	# terminate jump early
	if terminate_jump:
		# 1: velocity reset
		# if we're still ascending, set reset velocity.
		# jump only "cancelable" during ascend
		if velocity.y < 0:
			velocity.y = 0

	
	velocity = move_and_slide(velocity, Vector2.UP)

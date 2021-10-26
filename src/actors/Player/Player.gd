extends KinematicBody2D
const FireBall = preload("res://src/actors/Player/FireBall.tscn")


""" SECTION VARIABLE DEFINITIONS """

enum ANIMATION_STATES { IDLE, RUN, HURT, JUMP, DEATH, ATTACK }
var animation_state  = ANIMATION_STATES.IDLE

var is_jumping : bool
var is_attacking : bool
var is_moving : bool

var hitpoints : int
var is_alive : bool
var is_stompable : bool = false

var direction : Vector2
var velocity : Vector2
var last_look_direction : Vector2

# speeds in pixels / time
const move_speed : float = 32*6/.8
const jump_speed : int = -640
const gravity : int = 1600

# keep these values between 0-1
const friction : float = 0.25
const acceleration : float = 0.4

const jump_edge_tolerance : float = .1
var time_since_last_grounded : float

const jump_fall_tolerance : float = .2
var time_since_last_jump_input : float
var time_since_last_air_jump : float

var terminate_jump : bool
var double_jump : bool

var attack : bool = false

const stomp_velocity : int = -300


""" SECTION OVERRIDE FUNCTIONS """

func _ready():
	velocity = Vector2()
	last_look_direction = Vector2(1, 0)
	
	hitpoints = 10
	is_alive = true
	
	print("ready")

func _process(delta):
	input_process(delta)
	attack_process()
	
	if direction.y != -1:
		time_since_last_jump_input += delta
	time_since_last_grounded += delta
	time_since_last_air_jump += delta

func _physics_process(delta):
	jump_process()
	
	# update horizontal velocity
	# horizontal movement linear interpolation
	# velocity.x = direction.x * move_speed
	if direction.x != 0:
		velocity.x = lerp(velocity.x, direction.x * move_speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)
	
	# update vertical velocity
	velocity.y += gravity * delta
	
	update_animation()
	
	
	animation_state = ANIMATION_STATES.IDLE if direction.x == 0 else ANIMATION_STATES.RUN
	animation_state = animation_state if is_on_floor() else ANIMATION_STATES.JUMP
	if attack:
		animation_state = ANIMATION_STATES.ATTACK
	is_jumping = false if is_on_floor() else true
	
	velocity = move_and_slide(velocity, Vector2.UP)


""" SECTION CUSTOM FUNCTIONS """

func input_process(delta):
	direction = Vector2()
	terminate_jump = false
	attack = false
	
	if Input.is_action_pressed("move_left"):
		direction.x = -1
		last_look_direction.x = -1
		#$AnimatedSprite.flip_h = true
		#$AnimatedSprite.offset.x = -20
	if Input.is_action_pressed("move_right"):
		direction.x = 1
		last_look_direction.x = 1
		#$AnimatedSprite.flip_h = false
		#$AnimatedSprite.offset.x = 0
	if Input.is_action_just_pressed("jump"):
		direction.y = -1
	if Input.is_action_just_released("jump"):
		terminate_jump = true
	if Input.is_action_just_pressed("attack"):
		attack = true
	
	if direction.length() == 0:
		last_look_direction.y = 0

func jump_process():
	# jump, normal
	if direction.y == -1 and is_on_floor():
		print("normal")
		velocity.y = jump_speed
		direction.y = 0
	elif is_on_floor():
		double_jump = false
		time_since_last_grounded = 0
		# jump even if jump input was when player was still in air
		if (time_since_last_jump_input < jump_fall_tolerance) and (time_since_last_air_jump > 1):
			print("air-jump")
			velocity.y = jump_speed
			direction.y = 0
			time_since_last_air_jump = 0
	# jump even if player is not on floor
	elif direction.y == -1 and time_since_last_grounded < jump_edge_tolerance and not is_on_floor():
		print("edge-jump with tolerance time: ", str(time_since_last_grounded))
		velocity.y = jump_speed
		direction.y = 0
	# double jump
	elif direction.y == -1 and not double_jump and not is_on_floor():
		print("double-jump")
		velocity.y = jump_speed
		direction.y = 0
		double_jump = true
	# terminate jump early
	elif terminate_jump:
		# 1: velocity reset
		# if we're still ascending, set reset velocity.
		# jump only "cancelable" during ascend
		if velocity.y < 0:
			velocity.y = 0

func attack_process():
	if attack:
		var b = FireBall.instance()
		b.position = self.position
		b.direction = self.last_look_direction
		b.add_to_group("PlayerWeapon")
		get_tree().current_scene.add_child(b)

func die():
	queue_free()

func take_damage(n : int):
	pass

func on_stomp():
	pass

func update_animation():
	match animation_state:
		ANIMATION_STATES.IDLE:
			$AnimatedSprite.play("idle")
		ANIMATION_STATES.RUN:
			$AnimatedSprite.play("move")
		ANIMATION_STATES.JUMP:
			$AnimatedSprite.play("jump")
		ANIMATION_STATES.ATTACK:
			print("animation attack")
			is_attacking = true
			$AnimatedSprite.play("attack1")
	
	if direction.x == -1:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -20
	if direction.x == 1:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
	
	$Camera2D/InfoLabel.text = "is_moving: " + str(is_moving) + "\nis_jumping: " + str(is_jumping) + "\nis_attacking: " + str(is_attacking)
	


""" SECTION SIGNAL FUNCTIONS """

func _on_EnemyDetector_body_entered(body):
	print(body.name, " entered player body")
	# die()

func _on_StompDetector_area_entered(area):
	print("stomping ", area.name)
	# velocity.y = stomp_velocity

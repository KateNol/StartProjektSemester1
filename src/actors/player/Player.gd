extends KinematicBody2D
const FireBall = preload("res://src/actors/player/FireBall.tscn")

const TYPE = "player"

""" SECTION VARIABLE DEFINITIONS """

enum ANIMATION_STATES { IDLE, RUN, HURT, JUMP, DEATH, ATTACK_MELEE, ATTACK_RANGED }
var animation_state  = ANIMATION_STATES.IDLE

enum ATTACK_STATES { MELEE, RANGED }
var attack_state = null

var is_jumping : bool
var is_attacking : bool
var is_moving : bool
var is_hurt : bool

var hitpoints : int
var is_alive : bool
var is_stompable : bool = false

var direction : Vector2
var velocity : Vector2
var last_look_direction : Vector2

# speeds in pixels / time
const move_speed : float = 32*7/.8
const jump_speed : int = -720
const gravity : int = 1800
export var velocity_cap_v : int = 1000

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

const attack_cooldown : float = .7
var attack : bool = false
var attack_timer : Timer

var hurt_timer : Timer
const invincible_cooldown : float = .2

const stomp_velocity : int = -300

export var grey_scale: bool = false

""" SECTION OVERRIDE FUNCTIONS """

func _ready():
	velocity = Vector2()
	last_look_direction = Vector2(1, 0)
	
	hitpoints = 10
	is_alive = true
	
	$Control/HealthBar.max_value = hitpoints
	$Control/HealthBar.value = hitpoints
	$Control/HealthBar.tint_progress = Color.green
	$MeleeDetector.monitoring = false
	
	set_black_white(grey_scale)
	print("ready")


func _process(delta):
	if not is_alive:
		return
		
	input_process(delta)
	attack_process()
	
	if direction.y != -1:
		time_since_last_jump_input += delta
	time_since_last_grounded += delta
	time_since_last_air_jump += delta

func _physics_process(delta):
	if not is_alive:
		return
	
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
	if velocity.y > velocity_cap_v:
		print("velocity cap")
		velocity.y = velocity_cap_v
	
	update_animation()
	
	if !is_hurt and !is_attacking:
		animation_state = ANIMATION_STATES.IDLE if direction.x == 0 else ANIMATION_STATES.RUN
		animation_state = animation_state if is_on_floor() else ANIMATION_STATES.JUMP
	if attack:
		if attack_state == ATTACK_STATES.MELEE:
			print("set state melee")
			animation_state = ANIMATION_STATES.ATTACK_MELEE
		elif attack_state == ATTACK_STATES.RANGED:
			print("set state ranged")
			animation_state = ANIMATION_STATES.ATTACK_RANGED
	is_jumping = false if is_on_floor() else true
	
	is_moving = direction.length() != 0
	
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
		if !is_attacking:
			attack = true
			$Sound_fire.play()
			attack_state = ATTACK_STATES.RANGED
	if Input.is_action_just_pressed("melee"):
		if !is_attacking:
			attack = true
			$Sound_attack.play()
			attack_state = ATTACK_STATES.MELEE
			
	if Input.is_action_just_pressed("hit_self"):
		print("ow")
		take_damage(1)
	
	if direction.length() == 0:
		last_look_direction.y = 0

func jump_process():
	# jump, normal
	if direction.y == -1 and is_on_floor():
		print("normal")
		$Sound_jump.play()
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
		$Sound_jump2.play()
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
	if is_attacking:
		return
	
	if attack:
		is_attacking = true
		attack_timer = Timer.new()
		attack_timer.one_shot = true
		attack_timer.wait_time = attack_cooldown
		attack_timer.connect("timeout", self, "attack_timer_timeout")
		add_child(attack_timer)
		attack_timer.start()
		
		if attack_state == ATTACK_STATES.RANGED:
			var b = FireBall.instance()
			b.position = self.position
			b.set_direction(self.last_look_direction) 
			get_tree().current_scene.add_child(b)
		if attack_state == ATTACK_STATES.MELEE:
			print("melee")
			$MeleeDetector.monitoring = true

func die():
	queue_free()

func take_damage(n : int):
	if is_hurt:
		return
		
	is_hurt = true
	hurt_timer = Timer.new()
	hurt_timer.one_shot = true
	hurt_timer.wait_time = invincible_cooldown
	hurt_timer.connect("timeout", self, "hurt_timer_timeout")
	add_child(hurt_timer)
	hurt_timer.start()
	$Sound_hurt.play()
	animation_state = ANIMATION_STATES.HURT
	hitpoints -= n
	if hitpoints >= 7:
		$Control/HealthBar.tint_progress = Color.green
	elif hitpoints >= 3:
		$Control/HealthBar.tint_progress = Color.orange
	else:
		$Control/HealthBar.tint_progress = Color.red
	$Control/HealthBar.value = hitpoints
	
	if hitpoints <= 0:
		print("dying")
		$Sound_die.play()
		animation_state = ANIMATION_STATES.DEATH
		is_alive = false
		update_animation()

func take_damage_player(n : int):
	take_damage(n)

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
		ANIMATION_STATES.ATTACK_RANGED:
			$AnimatedSprite.play("attack1")
		ANIMATION_STATES.ATTACK_MELEE:
			$AnimatedSprite.play("melee")
		ANIMATION_STATES.HURT:
			$AnimatedSprite.play("hurt")
		ANIMATION_STATES.DEATH:
			print("play death animation")
			$AnimatedSprite.play("death")
	
	if direction.x == -1:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -20
		$MeleeDetector/CollisionShape2D.position.x = -1 * abs($MeleeDetector/CollisionShape2D.position.x)
	if direction.x == 1:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
		$MeleeDetector/CollisionShape2D.position.x = abs($MeleeDetector/CollisionShape2D.position.x)
	
	$InfoLabel.text = "" # "is_moving: " + str(is_moving) + "\nis_jumping: " + str(is_jumping) + "\nis_attacking: " + str(is_attacking) + "\nvh: " + str(velocity.x) + "\nvv" + str(velocity.y) + "\nhp: " + str(hitpoints)
	
func set_black_white(boolean: bool):
	if boolean:
		$AnimatedSprite.material = load("res://src/actors/player/PlayerShader.tres")
	else:
		$AnimatedSprite.material = null

""" SECTION SIGNAL FUNCTIONS """

func attack_timer_timeout():
	is_attacking = false
	$MeleeDetector.monitoring = false

func hurt_timer_timeout():
	print("hurt finished")
	is_hurt = false

func _on_EnemyDetector_body_entered(body):
	print(body.name, " entered player body")
	# die()

func _on_EnemyDetector_area_entered(area):
	print(area.name, " area entered")


func _on_AnimatedSprite_animation_finished():
	if animation_state == ANIMATION_STATES.DEATH:
		get_tree().reload_current_scene()


func _on_StompDetector_body_entered(body):
	if body.is_in_group("enemy"):
		print(body.name)
		if body.is_stompable:
			body.on_stomp()
			velocity.y = stomp_velocity
		else:
			take_damage(1)
			velocity.y = stomp_velocity


func _on_MeleeDetector_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(3)


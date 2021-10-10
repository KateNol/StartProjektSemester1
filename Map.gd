extends Node2D


export var target_fps : int = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str(Engine.get_frames_per_second())
	Engine.target_fps = target_fps
	if Input.is_action_just_pressed("change_fps"):
		target_fps = 30 if target_fps == 60 else 60
	if Input.is_action_pressed("quit"):
		get_tree().quit()

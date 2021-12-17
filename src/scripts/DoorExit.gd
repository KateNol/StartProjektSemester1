extends Node2D

signal enter_door

export(int) var level_number
export(String) var door_name

onready var area = $Area2D

func _ready():
	pass 
	
func _physics_process(delta):
	for body in area.get_overlapping_bodies():
		if body.name == "Player" and Input.is_action_just_pressed("move_up"):
			get_tree().change_scene("res://src/scenes/Menu.tscn")

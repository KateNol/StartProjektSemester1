extends Control

func _ready():
		pass

func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().change_scene("res://src/levels/Menu.tscn")

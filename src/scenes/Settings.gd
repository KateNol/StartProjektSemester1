extends Control

func _ready():
		pass

func _input(event):
	if event.is_action_pressed("quit"):
		$buttonSound.play()
		yield($buttonSound, "finished")
		get_tree().change_scene("res://src/scenes/Menu.tscn")

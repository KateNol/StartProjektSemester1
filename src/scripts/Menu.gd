extends Control


func _ready():
	pass # Replace with function body.


func _on_Start_pressed():
	$buttonSound.play()
	yield($buttonSound, "finished")
	get_tree().change_scene("res://src/scenes/Game.tscn")
	
	


func _on_Einstellungen_pressed():
	$buttonSound.play()
	yield($buttonSound, "finished")
	get_tree().change_scene("res://src/scenes/Settings.tscn")
	


func _on_ENDE_pressed():
	$buttonSound.play()
	yield($buttonSound, "finished")
	get_tree().quit()
	

func _on_buttonSound_finished():
	pass # Replace with function body.

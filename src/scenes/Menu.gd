extends Control


func _ready():
	pass # Replace with function body.


func _on_Start_pressed():
	get_tree().change_scene("res://src/scenes/levels/Level0.tscn")
	


func _on_Einstellungen_pressed():
	get_tree().change_scene("res://src/scenes/Settings.tscn")
	


func _on_ENDE_pressed():
	get_tree().quit()

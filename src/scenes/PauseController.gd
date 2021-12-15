extends Node

export(bool) var can_toggle_pause: bool = true


func _ready():
	print("loaded pause controller")


func _process(delta):
	if Input.is_action_just_pressed("menu_pause"):
		print("action pause")
		if !get_tree().paused:
			$CanvasLayer/PauseBackground.visible = true
			$CanvasLayer2/pauseText.visible = true
			
			pause()
		else:
			$CanvasLayer/PauseBackground.visible = false
			$CanvasLayer2/pauseText.visible = false
			
			resume()	
	
		
func pause():
	if can_toggle_pause:
		get_tree().set_deferred("paused", true)	
		
		

func resume():
	if can_toggle_pause:
		get_tree().set_deferred("paused", false)
	

		

		

		




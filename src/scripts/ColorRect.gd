extends ColorRect


func _ready():
	pass
	
func fade_in():
	$AnimationPlayer.play("fade_in")
	return $AnimationPlayer

func fade_out():
	$AnimationPlayer.play_backwards("fade_in")
	return $AnimationPlayer

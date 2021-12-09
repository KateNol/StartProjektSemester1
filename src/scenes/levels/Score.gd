extends CanvasLayer

var coins = 0
func _ready():
	$CoinScore.text = String(coins)


func _on_coin_collected():
	coins = coins + 10
	$coinSound.play()
	_ready()

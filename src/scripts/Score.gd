extends CanvasLayer

var coins = 0
func _ready():
	$CoinScore.text = String(coins)


func _on_coin_collected():
	coins = coins + 10
	if $coinSound != null:
		$coinSound.play()
	_ready()

func _on_shard_collected():
	coins = coins + 50
	$shardSound.play()
	_ready()


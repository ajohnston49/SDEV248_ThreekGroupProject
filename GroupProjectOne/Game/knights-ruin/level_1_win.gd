extends CanvasLayer



func _ready():
	# Configure the Timer in the Inspector:
	#   - Wait Time = 10.0
	#   - One Shot = true
	#   - Autostart = true
	
	$WinTimer.timeout.connect(_on_WinTimer_timeout)

func _on_WinTimer_timeout():
	print("WinTimer finished, loading Level2...")
	get_tree().change_scene_to_file("res://level_2.tscn")
	queue_free()

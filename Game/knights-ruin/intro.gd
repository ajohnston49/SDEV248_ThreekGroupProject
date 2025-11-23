extends CanvasLayer

func _ready():
	# Configure the Timer in the Inspector:
	#   - Wait Time = 10.0
	#   - One Shot = true
	#   - Autostart = true
	$IntroTimer.timeout.connect(_on_IntroTimer_timeout)

func _on_IntroTimer_timeout():
	print("Intro finished, loading Level1...")
	get_tree().change_scene_to_file("res://level_1.tscn")
	queue_free()

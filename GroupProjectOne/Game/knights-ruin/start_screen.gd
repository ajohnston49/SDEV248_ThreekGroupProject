extends Control

func _on_start_button_pressed():
	print("Start button pressed")
	var scene: PackedScene = load("res://Intro.tscn")  # exact filename/case
	if scene == null:
		push_error("Failed to load res://Intro.tscn")
		return

	var intro = scene.instantiate()
	print("Intro instantiated:", intro)

	# Add to the root so it always appears, regardless of current scene parenting
	get_tree().root.add_child(intro)

	# Optional: remove start screen AFTER confirming intro is visible
	queue_free()

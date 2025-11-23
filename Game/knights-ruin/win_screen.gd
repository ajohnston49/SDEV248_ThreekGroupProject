extends Control

func _on_start_button_pressed():
	print("Start button pressed")
	var scene: PackedScene = load("res://start_screen.tscn")  # must be .tscn
	if scene == null:
		push_error("Failed to load res://start_screen.tscn")
		return
	get_tree().change_scene_to_packed(scene)

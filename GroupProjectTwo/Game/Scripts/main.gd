extends Node2D

func check_win_condition():
	var enemies_alive = false
	for child in get_children():
		if child.has_method("take_damage"):
			enemies_alive = true
			break
	if not enemies_alive:
		$UI/Label.text = "YOU WIN!"
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://win_menu.tscn")

extends Area2D

var interactable: bool = false

func set_interactable(state: bool) -> void:
	interactable = state

func interact() -> void:
	if interactable:
		print("Artifact taken! Rolling credits...")
		get_tree().change_scene_to_file("res://credits.tscn")
	else:
		# Trigger Red's hostile path if player tries to interact before dialog
		var red = get_tree().get_first_node_in_group("Red")
		if red and red.has_method("on_artifact_taken_without_talking"):
			red.on_artifact_taken_without_talking()

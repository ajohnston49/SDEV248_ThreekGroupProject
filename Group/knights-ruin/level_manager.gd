extends Node

var skeleton_count: int = 4   # start with 4 skeletons in Level 1

func skeleton_died():
	skeleton_count -= 1
	print("Skeletons left:", skeleton_count)
	if skeleton_count <= 0:
		# Find blockade and trigger explode
		var blockade = get_tree().get_nodes_in_group("Blockade")
		if blockade.size() > 0:
			blockade[0].trigger_explode()

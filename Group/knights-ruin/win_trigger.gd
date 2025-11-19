extends Area2D

func _ready():
	monitoring = true   # optional: keep disabled until blockade explodes

func enable_trigger():
	monitoring = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered win trigger")
		# Spawn the Level1Win cutscene overlay
		var win_overlay = load("res://level_1_win.tscn").instantiate()
		get_tree().root.add_child(win_overlay)
		queue_free()  # remove trigger so it doesn't fire again

extends Area2D

@export var win_scene: String = "res://level_1_win.tscn"
# 👆 You can set this in the Inspector per level (Level 1 → level_1_win.tscn, Level 2 → level_2_win.tscn)

func _ready():
	monitoring = true   # optional: keep disabled until blockade explodes

func enable_trigger():
	monitoring = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered win trigger")
		# Spawn the configured win cutscene overlay
		var win_overlay = load(win_scene).instantiate()
		get_tree().root.add_child(win_overlay)
		queue_free()  # remove trigger so it doesn't fire again

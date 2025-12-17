extends CharacterBody2D

@export var message: String = "You Must Defeat The Beasts Before Moving Forward...."
var label_timer: Timer

func _ready():
	$AnimatedSprite2D.play("idle")
	$Label.visible = false
	$InteractIcon.visible = false

	# Timer to hide the label after a short period
	label_timer = Timer.new()
	label_timer.wait_time = 3.0   # how long the label stays visible
	label_timer.one_shot = true
	label_timer.connect("timeout", Callable(self, "_hide_label"))
	add_child(label_timer)

# ✅ Show the interact icon when Player enters the Area2D
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		$InteractIcon.visible = true

# ✅ Hide the interact icon when Player leaves
func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		$InteractIcon.visible = false

# ✅ Called when Player presses the "interact" key
func interact():
	if $InteractIcon.visible:   # only if Player is nearby
		# Check if any enemies remain
		var enemies_left = get_tree().get_nodes_in_group("enemies")
		if enemies_left.size() == 0:
			# ✅ All enemies defeated → go to win menu
			get_tree().change_scene_to_file("res://Scenes/win_menu.tscn")
		else:
			# Show message if enemies still alive
			$Label.text = message
			$Label.visible = true
			label_timer.start()

func _hide_label():
	$Label.visible = false

extends StaticBody2D   # or Area2D if you kept it that way

var skeleton_count: int = 4   # how many skeletons must die

func _ready():
	$Animation.play("sparkle")

func skeleton_died():
	skeleton_count -= 1
	print("Skeletons left:", skeleton_count)
	if skeleton_count <= 0:
		trigger_explode()

func trigger_explode():
	$Animation.play("splode")
	await $Animation.animation_finished
	queue_free()

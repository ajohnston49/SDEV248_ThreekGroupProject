extends StaticBody2D   # or Area2D if you prefer

@export var skeleton_count: int = 4    # how many skeletons must die
@export var boss_count: int = 1        # how many bosses must die (usually 1)

func _ready():
	$Animation.play("sparkle")

func skeleton_died():
	skeleton_count -= 1
	print("Skeletons left:", max(0, skeleton_count))
	_check_conditions()

func boss_died():
	boss_count -= 1
	print("Bosses left:", max(0, boss_count))
	_check_conditions()

func _check_conditions():
	# ✅ Explode if skeletons are all gone OR bosses are all gone
	if skeleton_count <= 0 or boss_count <= 0:
		trigger_explode()

func trigger_explode():
	print("Blockade explodes!")
	$Animation.play("splode")
	await $Animation.animation_finished
	queue_free()

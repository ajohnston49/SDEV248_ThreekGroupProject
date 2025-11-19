extends CharacterBody2D

@export var speed: float = 40.0
@export var health: int = 3

func _ready():
	$AnimatedSprite2D.play("skull_idle")

func _physics_process(delta):
	if health <= 0:
		_die()
		return

	# Just idle for now
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimatedSprite2D.play("skull_idle")

func _die():
	queue_free()

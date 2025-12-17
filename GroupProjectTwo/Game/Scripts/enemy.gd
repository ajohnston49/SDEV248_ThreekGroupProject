extends CharacterBody2D

@export var speed: float = 120.0
@export var attack_range: float = 40.0
@export var pause_time: float = 0.5
@export var max_health: int = 3
@export var knock_strength: float = 120.0

var health: int = max_health
var player_ref: Node = null

# States: idle → chase → attack → pause
var state: String = "idle"
var pause_left: float = 0.0
var fling_velocity: Vector2 = Vector2.ZERO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if get_parent().has_node("Player"):
		player_ref = get_parent().get_node("Player")
	add_to_group("enemies")
	anim.play("idle")

func _physics_process(delta):
	if not player_ref or not is_instance_valid(player_ref): return

	# Handle fling knockback first
	if fling_velocity != Vector2.ZERO:
		velocity = fling_velocity
		fling_velocity = fling_velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return

	var to_player = player_ref.global_position - global_position
	var dist = to_player.length()

	# Stable facing
	anim.flip_h = player_ref.global_position.x < global_position.x

	match state:
		"idle":
			# Do nothing until provoked
			velocity = Vector2.ZERO
			move_and_slide()
			if anim.animation != "idle": anim.play("idle")

		"chase":
			if dist > attack_range:
				velocity = to_player.normalized() * speed
				move_and_slide()
				if anim.animation != "run": anim.play("run")
			else:
				velocity = Vector2.ZERO
				move_and_slide()
				if anim.animation != "idle": anim.play("idle")
				# Attack only once in range
				state = "attack"

		"attack":
			velocity = Vector2.ZERO
			move_and_slide()
			if anim.animation != "attack": anim.play("attack")
			# Damage once per attack
			if _player_in_range(attack_range) and player_ref.has_method("take_damage"):
				var knock = to_player.normalized() * knock_strength
				player_ref.take_damage(1, knock)
			# Then pause
			state = "pause"
			pause_left = pause_time

		"pause":
			velocity = Vector2.ZERO
			move_and_slide()
			if anim.animation != "idle": anim.play("idle")
			pause_left -= delta
			if pause_left <= 0.0:
				state = "chase"

func take_damage(amount: int = 1):
	health -= amount
	if health > 0:
		# Bounce away
		var away = (global_position - player_ref.global_position).normalized()
		fling_velocity = away * 900.0
		# ✅ Wake up from idle → chase
		if state == "idle":
			state = "chase"
		else:
			state = "attack"
	else:
		queue_free()

func _player_in_range(dist: float) -> bool:
	return global_position.distance_to(player_ref.global_position) <= dist

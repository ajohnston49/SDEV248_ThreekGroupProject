extends CharacterBody2D

@export var speed: float = 140.0
@export var health: int = 5
var attacking: bool = false
var attack_cooldown: float = 0.0
var knockback: Vector2 = Vector2.ZERO
var knockback_time: float = 0.0

func _physics_process(delta):
	if health <= 0:
		_die()
		return

	# Movement preserved
	var dir = Vector2(
		Input.get_action_strength("move_right") + Input.get_action_strength("ui_right")
		- Input.get_action_strength("move_left") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("move_down") + Input.get_action_strength("ui_down")
		- Input.get_action_strength("move_up") - Input.get_action_strength("ui_up")
	).normalized()

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	# ✅ Only apply knockback when actually hurt
	if knockback_time > 0.0:
		knockback_time -= delta
		velocity = knockback
	else:
		# Normal movement unless attacking
		if not attacking:
			velocity = dir * speed
		else:
			velocity = Vector2.ZERO  # freeze during attack

	move_and_slide()

	if dir.x != 0:
		$AnimatedSprite2D.flip_h = dir.x < 0

	if attacking:
		if $AnimatedSprite2D.animation != "attack":
			$AnimatedSprite2D.play("attack")
	elif dir.length() > 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

	if Input.is_action_just_pressed("attack") and not attacking and attack_cooldown <= 0.0:
		_start_attack()

func _start_attack():
	attacking = true
	attack_cooldown = 0.2
	$AnimatedSprite2D.play("attack")

	for body in $HitDetector.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			body.take_damage(1, self)

	await $AnimatedSprite2D.animation_finished
	attacking = false

func take_damage(amount: int, attacker: Node2D):
	health -= amount
	if health <= 0:
		_die()
	else:
		# ✅ Knockback only when attacked
		var dir = (global_position - attacker.global_position).normalized()
		knockback = dir * 200
		knockback_time = 0.2

func _die():
	queue_free()

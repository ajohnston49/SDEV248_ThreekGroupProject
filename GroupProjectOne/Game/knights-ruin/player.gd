extends CharacterBody2D

@export var skeleton_count: int = 4
@export var boss_count: int = 1
@export var speed: float = 140.0
@export var health: int = 5

var attacking: bool = false
var attack_cooldown: float = 0.0
var knockback: Vector2 = Vector2.ZERO
var knockback_time: float = 0.0

func _ready() -> void:
	if not is_in_group("Player"):
		add_to_group("Player")

	# Reset sprite orientation
	scale.x = abs(scale.x)
	$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x)
	$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.play("idle")

	# Initialize local health bar
	if has_node("CanvasLayer/PlayerHealthBar"):
		var bar = $CanvasLayer/PlayerHealthBar
		bar.min_value = 0
		bar.max_value = health
		bar.value = health

func _physics_process(delta: float) -> void:
	if health <= 0:
		_die()
		return

	_handle_movement(delta)
	_handle_animation()
	_handle_inputs()

# --- Movement ---
func _handle_movement(delta: float) -> void:
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	# Attack cooldown
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	# Knockback logic
	if knockback_time > 0.0:
		knockback_time -= delta
		velocity = knockback
	else:
		velocity = Vector2.ZERO if attacking else dir * speed

	move_and_slide()

	# Sprite orientation
	if dir.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif dir.x < 0:
		$AnimatedSprite2D.flip_h = true

# --- Animation ---
func _handle_animation() -> void:
	if attacking:
		if $AnimatedSprite2D.animation != "attack":
			$AnimatedSprite2D.play("attack")
	elif velocity.length() > 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

# --- Inputs ---
func _handle_inputs() -> void:
	if Input.is_action_just_pressed("attack") and not attacking and attack_cooldown <= 0.0:
		_start_attack()

	if Input.is_action_just_pressed("interact"):
		_try_interact()

# --- Attack ---
func _start_attack() -> void:
	attacking = true
	attack_cooldown = 0.2
	$AnimatedSprite2D.play("attack")

	# Play hit sound (woosh)
	if $HitSound:
		$HitSound.play()

	for body in $HitDetector.get_overlapping_bodies():
		if body.is_in_group("Enemy") and body.has_method("take_damage"):
			body.take_damage(1, self)
			$EnemyHitSound.play()
		elif body.is_in_group("Boss") and body.has_method("take_damage"):
			body.take_damage(1, self)
			$BossHitSound.play()
		elif body.is_in_group("Red") and body.has_method("take_damage"):
			body.take_damage(1, self)
			$BossHitSound.play()

	await $AnimatedSprite2D.animation_finished
	attacking = false

# --- Interaction ---
func _try_interact() -> void:
	for body in $InteractionDetector.get_overlapping_bodies():
		if body.is_in_group("Red") and body.has_method("talk_to_player"):
			body.talk_to_player()
		elif body.is_in_group("Artifact") and body.has_method("interact"):
			body.interact()

# --- Damage ---
func take_damage(amount: int, attacker: Node2D) -> void:
	health -= amount
	print("Player took damage, health:", health)

	if has_node("CanvasLayer/PlayerHealthBar"):
		$CanvasLayer/PlayerHealthBar.value = health

	if health <= 0:
		_die()
	else:
		# Play hurt sound
		if $HurtSound:
			$HurtSound.play()

		var dir = (global_position - attacker.global_position).normalized()
		knockback = dir * 200
		knockback_time = 0.2

# --- Death ---
func _die() -> void:
	print("Player defeated!")

	# Play die sound
	if $DieSound:
		$DieSound.play()

	get_tree().change_scene_to_file("res://death_scene.tscn")

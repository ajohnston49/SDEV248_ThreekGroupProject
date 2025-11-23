extends CharacterBody2D

@export var speed: float = 40.0
@export var health: int = 3
var aggro: bool = false
var attacking: bool = false
var target: Node2D = null
var stun_time: float = 0.0
var knockback: Vector2 = Vector2.ZERO
var knockback_time: float = 0.0

# wandering timers
var wander_timer: float = 0.0
var wander_duration: float = 3.0
var wander_cooldown: float = 10.0
var wander_dir: Vector2 = Vector2.ZERO

func _ready():
	$AnimatedSprite2D.play("skull_idle")

func _physics_process(delta):
	if health <= 0:
		_die()
		return

	# Apply knockback if active
	if knockback_time > 0.0:
		knockback_time -= delta
		velocity = knockback
		move_and_slide()
		return

	if stun_time > 0.0:
		stun_time -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if aggro and target:
		var dist = global_position.distance_to(target.global_position)
		if dist > 40 and not attacking:
			var dir = (target.global_position - global_position).normalized()
			velocity = dir * speed
			move_and_slide()
			$AnimatedSprite2D.flip_h = dir.x < 0
			if $AnimatedSprite2D.animation != "skull_run":
				$AnimatedSprite2D.play("skull_run")
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			if not attacking and $AnimatedSprite2D.animation != "skull_idle":
				$AnimatedSprite2D.play("skull_idle")
	else:
		_wander_logic(delta)

func _wander_logic(delta):
	if wander_timer > 0.0:
		wander_timer -= delta
		velocity = wander_dir * speed
		move_and_slide()
		if $AnimatedSprite2D.animation != "skull_run":
			$AnimatedSprite2D.play("skull_run")
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		if $AnimatedSprite2D.animation != "skull_idle":
			$AnimatedSprite2D.play("skull_idle")

		wander_cooldown -= delta
		if wander_cooldown <= 0.0:
			wander_dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
			wander_timer = wander_duration
			wander_cooldown = 10.0

func take_damage(amount: int, attacker: Node2D):
	health -= amount
	if health > 0:
		aggro = true
		target = attacker
		# ✅ Knockback away from attacker
		var dir = (global_position - attacker.global_position).normalized()
		knockback = dir * 150   # tweak strength
		knockback_time = 0.2
		_start_attack()
	else:
		_die()

func _start_attack():
	if attacking: return
	attacking = true
	$AnimatedSprite2D.play("skull_attack")

	for body in $AttackDetector.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.take_damage(1, self)

	await $AnimatedSprite2D.animation_finished
	attacking = false

func _die():
	
	queue_free()

	# Tell the blockade one skeleton has died
	var blockade = get_tree().get_nodes_in_group("Blockade")
	if blockade.size() > 0:
		blockade[0].skeleton_died()

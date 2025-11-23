extends CharacterBody2D

@export var speed: float = 60.0
@export var bosshealth: int = 10   # requires 10 hits
var target: Node2D = null
var attacking: bool = false
var state: String = "idle"

func _ready():
	if not is_in_group("Boss"):
		add_to_group("Boss")
	$AnimatedSprite2D.play("min_idle")

	# Initialize boss bar
	if has_node("BossHUDLayer/BossHealthBar"):
		var bar = $BossHUDLayer/BossHealthBar
		bar.min_value = 0
		bar.max_value = bosshealth
		bar.value = bosshealth
		bar.visible = true

func _physics_process(delta):
	if bosshealth <= 0:
		_die()
		return

	if target == null:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			target = players[0]

	match state:
		"idle":
			velocity = Vector2.ZERO
			move_and_slide()
			if not attacking and target:
				_chase_player()
		"walk":
			if not attacking and target:
				_chase_player()
		"attack":
			pass
		"guard":
			pass

func _chase_player():
	if target == null: return
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	$AnimatedSprite2D.flip_h = dir.x < 0
	if $AnimatedSprite2D.animation != "min_walk":
		$AnimatedSprite2D.play("min_walk")

	if global_position.distance_to(target.global_position) < 80 and not attacking:
		_start_attack()

func take_damage(amount: int, attacker: Node2D):
	bosshealth -= amount
	print("Minotaur took damage, health:", bosshealth)

	# Update local boss bar
	if has_node("BossHUDLayer/BossHealthBar"):
		$BossHUDLayer/BossHealthBar.value = bosshealth

	if bosshealth <= 0:
		_die()

func _die():
	print("Minotaur defeated!")

	# Notify blockade(s)
	for blockade in get_tree().get_nodes_in_group("Blockade"):
		if blockade.has_method("boss_died"):
			blockade.boss_died()

	# Hide boss bar
	if has_node("BossHUDLayer/BossHealthBar"):
		$BossHUDLayer/BossHealthBar.visible = false

	queue_free()

func _start_attack():
	if attacking: return
	attacking = true
	state = "attack"
	$AnimatedSprite2D.play("min_attack")

	for body in $AttackDetector.get_overlapping_bodies():
		print("Minotaur attack hit:", body.name, "groups:", body.get_groups())
		if body.is_in_group("Player") and body.has_method("take_damage"):
			body.take_damage(1, self)

	await $AnimatedSprite2D.animation_finished
	_guard_after_attack()

func _guard_after_attack():
	state = "guard"
	$AnimatedSprite2D.play("min_block")
	await get_tree().create_timer(2.0).timeout
	_idle_after_guard()

func _idle_after_guard():
	state = "idle"
	$AnimatedSprite2D.play("min_idle")
	await get_tree().create_timer(5.0).timeout
	attacking = false
	state = "walk"

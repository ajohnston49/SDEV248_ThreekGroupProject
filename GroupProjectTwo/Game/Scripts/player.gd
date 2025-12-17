extends CharacterBody2D

@export var speed: int = 200
@export var max_health: int = 5
var health: int = max_health
var attacking: bool = false

func _ready():
	add_to_group("player")
	$AnimatedSprite2D.play("idle")

	# ✅ Initialize HUD health bar if present
	if get_parent().has_node("HUD"):
		var hud = get_parent().get_node("HUD")
		if hud.has_node("HealthBar"):
			hud.get_node("HealthBar").max_value = max_health
			hud.get_node("HealthBar").value = health

func _physics_process(delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("walk_up"): dir.y -= 1
	if Input.is_action_pressed("walk_down"): dir.y += 1
	if Input.is_action_pressed("walk_left"): dir.x -= 1
	if Input.is_action_pressed("walk_right"): dir.x += 1

	velocity = dir.normalized() * speed
	move_and_slide()

	if velocity.x < 0: $AnimatedSprite2D.flip_h = true
	elif velocity.x > 0: $AnimatedSprite2D.flip_h = false

	if not attacking:
		if velocity.length() > 0:
			if $AnimatedSprite2D.animation != "run": $AnimatedSprite2D.play("run")
		else:
			if $AnimatedSprite2D.animation != "idle": $AnimatedSprite2D.play("idle")

	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		$AnimatedSprite2D.play("attack")
		for body in $AttackRange.get_overlapping_bodies():
			if body.is_in_group("enemies"):
				body.take_damage(1)

	if Input.is_action_just_pressed("interact"):
		for area in $AttackRange.get_overlapping_areas():
			var npc = area.get_parent()
			if npc and npc.has_method("interact"):
				npc.interact()

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		attacking = false

func take_damage(amount: int = 1, knockback: Vector2 = Vector2.ZERO) -> void:
	health -= amount
	if knockback != Vector2.ZERO:
		global_position += knockback

	# ✅ Update HUD health bar
	if get_parent().has_node("HUD"):
		var hud = get_parent().get_node("HUD")
		if hud.has_node("HealthBar"):
			hud.get_node("HealthBar").value = health

	if health <= 0:
		get_tree().change_scene_to_file("res://lose_menu.tscn")

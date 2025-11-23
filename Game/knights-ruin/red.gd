extends CharacterBody2D

@export var health: int = 5
var hostile: bool = false
var attacking: bool = false

func _ready() -> void:
	if not is_in_group("Red"):
		add_to_group("Red")
	$AnimatedSprite2D.play("red_idle")


# --- Peaceful path ---
func _on_dialog_trigger(body: Node) -> void:
	if body.is_in_group("Player") and not hostile:
		talk_to_player()

func talk_to_player() -> void:
	if not hostile:
		var dialog_box = get_tree().get_first_node_in_group("DialogBox")
		if dialog_box and dialog_box.has_method("show_peace"):
			dialog_box.show_peace("You may take the artifact.")

		var artifact = get_tree().get_first_node_in_group("Artifact")
		if artifact:
			artifact.set_interactable(true)

# --- Aggressive path ---
func on_artifact_taken_without_talking() -> void:
	if not hostile:
		hostile = true
		var dialog_box = get_tree().get_first_node_in_group("DialogBox")
		if dialog_box and dialog_box.has_method("show_war"):
			dialog_box.show_war("You dare defy me!")
		$AnimatedSprite2D.play("red_attack")

func _physics_process(delta: float) -> void:
	if hostile and not attacking:
		_chase_player()

func _chase_player() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * 80
	move_and_slide()

	if $AnimatedSprite2D.animation != "red_run":
		$AnimatedSprite2D.play("red_run")

	if global_position.distance_to(player.global_position) < 60 and not attacking:
		_start_attack(player)

func _start_attack(player: Node2D) -> void:
	attacking = true
	$AnimatedSprite2D.play("red_attack")

	for body in $AttackDetector.get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("take_damage"):
			body.take_damage(body.health, self)

	await $AnimatedSprite2D.animation_finished
	attacking = false

func take_damage(amount: int, attacker: Node2D) -> void:
	if hostile:
		health -= amount
		print("Red took damage, health:", health)
		if health <= 0:
			_die()

func _die() -> void:
	print("Red defeated!")
	var artifact = get_tree().get_first_node_in_group("Artifact")
	if artifact:
		artifact.set_interactable(true)
	queue_free()

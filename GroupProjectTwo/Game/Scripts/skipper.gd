extends CharacterBody2D

@export var speed: float = 120.0
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.5
var health: int = 3

var player_ref: Node = null
var attacking: bool = false
var time_since_attack: float = 0.0

func _ready():
	player_ref = get_parent().get_node("Player")
	$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if not player_ref or not is_instance_valid(player_ref):
		return

	time_since_attack += delta
	var dir = (player_ref.global_position - global_position)
	var dist = dir.length()

	if attacking:
		return

	if dist > attack_range:
		velocity = dir.normalized() * speed
		move_and_slide()
		$AnimatedSprite2D.flip_h = velocity.x < 0
		if $AnimatedSprite2D.animation != "run":
			$AnimatedSprite2D.play("run")
	else:
		velocity = Vector2.ZERO
		if time_since_attack >= attack_cooldown:
			attack()
		elif $AnimatedSprite2D.animation != "idle":
			$AnimatedSprite2D.play("idle")

func attack():
	attacking = true
	time_since_attack = 0.0
	$AnimatedSprite2D.play("attack")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		attacking = false
		$AnimatedSprite2D.play("idle")
		if player_ref and global_position.distance_to(player_ref.global_position) <= attack_range:
			if player_ref.has_method("take_damage"):
				player_ref.take_damage(1)

func take_damage(amount: int = 1) -> void:
	health -= amount
	print("Skipper took damage. Health =", health)
	if health <= 0:
		queue_free()

extends Node2D

@export var speed: int
@onready var snowman: CharacterBody2D = get_tree().get_first_node_in_group("snowman")
@onready var p = get_parent()

var direction: float
const GRAVITY = 1200

func _physics_process(delta: float) -> void:
	# Follow snowman
	if snowman.global_position.x - p.global_position.x <= 0:
		direction = lerp(direction, -1.0, 0.02)
	if snowman.global_position.x - p.global_position.x >= 0:
		direction = lerp(direction, 1.0, 0.02)
	p.velocity.x = direction * speed
	p.move_and_slide()

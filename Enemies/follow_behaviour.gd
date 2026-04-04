extends Node2D

@export var speed: int
@export var lerp_weight: float
@onready var snowman: CharacterBody2D = get_tree().get_first_node_in_group("snowman")
@onready var p = get_parent()

var direction: float
const GRAVITY = 1200

func _physics_process(delta: float) -> void:
	# Follow snowman
	if snowman.global_position.x - p.global_position.x <= 0:
		direction = lerp(direction, -1.0, lerp_weight)
	if snowman.global_position.x - p.global_position.x >= 0:
		direction = lerp(direction, 1.0, lerp_weight)
	p.velocity.x = lerp(p.velocity.x, direction * speed, 0.1)
	p.move_and_slide()

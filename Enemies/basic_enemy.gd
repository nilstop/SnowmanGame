extends CharacterBody2D

@export var health_node: Node2D
@export var physics_node: Node2D

@onready var snowman = get_tree().get_first_node_in_group("snowman")

func _ready() -> void:
	snowman.connect("ice_land", bounce)

func take_damage(damage):
	health_node.take_damage(damage)

func bounce(force: int = 0):
	physics_node.bounce(force)

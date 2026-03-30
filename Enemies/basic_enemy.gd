extends CharacterBody2D

@export var health_node: Node2D

func take_damage(damage):
	health_node.take_damage(damage)

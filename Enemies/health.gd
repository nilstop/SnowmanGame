extends Node2D

@export var health: int

func take_damage(damage):
	health -= damage
	if health <= 0:
		get_parent().queue_free()

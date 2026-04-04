extends Node2D

@export var touch_damage: int
@export var knockback: int
@export var physics_node: Node2D

func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("snowman_damage_area"):
		area.get_parent().hit(self, touch_damage, knockback)
		physics_node.knockback(area.get_parent())

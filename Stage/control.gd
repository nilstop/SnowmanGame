extends Control

@export var camera_node: Camera2D

func _process(delta: float) -> void:
	global_position = camera_node.offset

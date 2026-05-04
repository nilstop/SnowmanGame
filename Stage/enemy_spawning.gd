extends Node2D

@onready var area: Area2D = $SpawnCollideCheck

var map_size := Vector2(1150, 650)

func _ready() -> void:
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	# Ground enemy spawn algorithm
	area.global_position = Vector2(randi_range(0, map_size.x), randi_range(0, map_size.y))
	while !area.get_overlapping_bodies():
		await get_tree().process_frame
		print("until no touch")
		area.global_position = Vector2(randi_range(0, map_size.x), randi_range(0, map_size.y))
	while area.get_overlapping_bodies():
		print("until touch")
		await get_tree().process_frame
		area.global_position.y += 20
	print(area.get_overlapping_bodies())

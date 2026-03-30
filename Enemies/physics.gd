extends Node2D

@onready var p = get_parent()

# Applied to the bounce force
@export var weight_multiplier: float

const GRAVITY = 1200

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not p.is_on_floor():
		p.velocity.y += GRAVITY * delta
		if p.velocity.y >= -200:
			p.velocity.y += GRAVITY * 1.1 * delta
		#p.move_and_slide()

# Bounce when snowman ground pounds
func bounce(force):
	if p.is_on_floor():
		p.velocity.y = -force * weight_multiplier
		p.move_and_slide()

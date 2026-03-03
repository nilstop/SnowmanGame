extends Area2D

var velocity: Vector2
var direction: int

const GRAVITY = 0.7
const SPEED = 24.0
const START_UP_VELOCITY = -5.0

func _ready() -> void:
	velocity.y = START_UP_VELOCITY

func _physics_process(delta: float) -> void:
	# Set velocity and move
	velocity.x = SPEED * direction
	velocity.y += GRAVITY
	global_position += velocity

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("floor"):
		queue_free()

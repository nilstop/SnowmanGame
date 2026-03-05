extends Area2D


var velocity: Vector2
var direction: Vector2


const GRAVITY = 0.7
const SPEED = 24.0
const START_UP_VELOCITY = -8.0

func _ready() -> void:
	# Set start velocity, extra velocity upwards if only facing right or left
	velocity = direction * SPEED
	if velocity.normalized().y >= 0:
		velocity += Vector2(0,START_UP_VELOCITY)

func _physics_process(delta: float) -> void:
	# Set velocity and move
	velocity.y += GRAVITY
	if velocity.y >= 0:
		velocity.y += GRAVITY * 0.8
	global_position += velocity

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("environment"):
		queue_free()

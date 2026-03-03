extends Area2D

var velocity: Vector2
var direction: Vector2


const GRAVITY = 0.7
const SPEED = 24.0
const START_UP_VELOCITY = -5.0

func _ready() -> void:
	velocity = direction * SPEED
	if velocity.normalized() == Vector2.LEFT or velocity.normalized() == Vector2.RIGHT:
		velocity += Vector2(0,START_UP_VELOCITY)

func _physics_process(delta: float) -> void:
	# Set velocity and move
	velocity.y += GRAVITY
	global_position += velocity

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("floor"):
		queue_free()

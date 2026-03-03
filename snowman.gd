extends CharacterBody2D

@export var snowball: PackedScene

var facing := Vector2.RIGHT
var throw_direction: Vector2

const SPEED = 400.0
const JUMP_VELOCITY = -650.0
const ACCELERATION = 0.1
const DECELERATION = 0.2
const GRAVITY = 1200
const RELEASE_VELOCITY = -350.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y >= -200:
			velocity.y += GRAVITY * 1.1 * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y <= RELEASE_VELOCITY:
		velocity.y = RELEASE_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	set_facing(direction)
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION)

	move_and_slide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		inst(snowball)

func inst(scene: PackedScene):
	var instance = scene.instantiate()
	instance.global_position = global_position
	instance.direction = get_throw_direction()
	add_sibling(instance)

func get_throw_direction():
	if Input.get_vector("left", "right", "up", "down"):
		return Input.get_vector("left", "right", "up", "down")
	else:
		return facing

func set_facing(direction):
	if direction == 1:
		facing = Vector2.RIGHT
	if direction == -1:
		facing = Vector2.LEFT

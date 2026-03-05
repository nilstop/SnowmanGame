extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var snowman_shape: CollisionShape2D = $SnowmanShape
@onready var water_shape: CollisionShape2D = $WaterShape


enum States {Snow, Water, Ice, Steam}

@export var snowball: PackedScene

var state: States = States.Snow: set = set_state
var facing := Vector2.RIGHT
var throw_direction: Vector2

const PLACEHOLDER_SNOWMAN_SIZE = Vector2(0.4, 0.578)
const PLACEHOLDER_WATER_SIZE = Vector2(0.2, 0.2)
const SPEED = 400.0
const WATER_SPEED = 600.0
const JUMP_VELOCITY = -650.0
const ACCELERATION = 0.1
const DECELERATION = 0.2
const GRAVITY = 1200
const RELEASE_VELOCITY = -350.0

func set_state(new_state):
	water_shape.disabled = true
	snowman_shape.disabled = true
	
	if new_state == States.Water:
		
		move_and_collide(Vector2.DOWN * 25)
		water_shape.disabled = false
		velocity = Vector2.ZERO
		sprite.scale = PLACEHOLDER_WATER_SIZE
		
	if new_state == States.Snow:
		
		snowman_shape.disabled = false
		
		sprite.scale = PLACEHOLDER_SNOWMAN_SIZE
		
	state = new_state

func _physics_process(delta: float) -> void:
	#region Snowman
	if state == States.Snow:
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
		var direction := Input.get_axis("left", "right")
		set_facing(direction)
		if direction:
			velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION)
		else:
			velocity.x = lerp(velocity.x, 0.0, DECELERATION)
	#endregion
	#region water
	if state == States.Water:

		var x_dir = Input.get_axis("left", "right")
		var y_dir = Input.get_axis("up", "down")
		if is_on_floor() or is_on_ceiling():
			velocity.x = x_dir * WATER_SPEED
		else:
			velocity.x = 0
		if is_on_wall():
			velocity.y = y_dir * WATER_SPEED
		else:
			velocity.y = 0
	#endregion
	move_and_slide()

func _process(_delta: float) -> void:
	if state == States.Snow:
		if Input.is_action_just_pressed("shoot"):
			inst_snowball(snowball)
		if Input.is_action_just_pressed("water") and is_on_floor():
			set_state(States.Water)
	if state == States.Water:
		if Input.is_action_just_released("water"):
			set_state(States.Snow)

func inst_snowball(scene: PackedScene):
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

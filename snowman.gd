extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var snowman_shape: CollisionShape2D = $SnowmanShape
@onready var water_shape: CollisionShape2D = $WaterShape
@onready var ice_cube_shape: CollisionShape2D = $IceCubeShape
@onready var ice_cube_drop_shape: CollisionShape2D = $IceCubeDropShape
@onready var water_environment_area: Area2D = $WaterEnvironmentArea
@onready var ice_cube_drop_timer: Timer = $IceCubeDropTimer

enum States {Snow, Water, Ice, Steam}

@export var snowball: PackedScene

var state: States = States.Snow: set = set_state
var facing := Vector2.RIGHT
var throw_direction: Vector2
var latest_water_slide: String
var latest_water_normal: Vector2

# Sprite sizes
const PLACEHOLDER_SNOWMAN_SIZE = Vector2(0.4, 0.578)
const PLACEHOLDER_WATER_SIZE = Vector2(0.2, 0.2)
const PLACEHOLDER_ICECUBE_SIZE = Vector2(0.672, 0.672)

# Shape Sizes
const ICSHAPE_GROUND_SIZE = Vector2()
const ICSHAPE_AIR_SIZE = Vector2()
const ICSHAPE_DROP_SIZE = Vector2()
const SPEED = 400.0

# Velocities
const WATER_SPEED = 660.0
const JUMP_VELOCITY = -650.0
const ACCELERATION = 0.1
const DECELERATION = 0.2
const GRAVITY = 1200
const RELEASE_VELOCITY = -350.0
const ICE_DROP_VELOCITY = 1300.0

func set_state(new_state):
	water_shape.disabled = true
	snowman_shape.disabled = true
	ice_cube_shape.disabled = true
	ice_cube_drop_shape.disabled = true
	
	if new_state == States.Water:
		
		move_and_collide(Vector2.DOWN * 25)
		water_shape.disabled = false
		velocity = Vector2.ZERO
		sprite.scale = PLACEHOLDER_WATER_SIZE
		
	if new_state == States.Snow:
		
		snowman_shape.disabled = false
		sprite.scale = PLACEHOLDER_SNOWMAN_SIZE
		
	if new_state == States.Ice:
		
		velocity = Vector2.ZERO
		ice_cube_shape.disabled = false
		sprite.scale = PLACEHOLDER_ICECUBE_SIZE
		ice_cube_drop_timer.start()
		
	
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
	#region Water

	if state == States.Water:

		var x_dir = Input.get_axis("left", "right")
		var y_dir = Input.get_axis("up", "down")
		
		if is_on_floor() or is_on_ceiling():
			velocity.x = x_dir * WATER_SPEED
			latest_water_slide = "horizontal"
			latest_water_normal = get_floor_normal()
			print(latest_water_normal)
		else:
			velocity.x = 0
		if is_on_wall():
			velocity.y = y_dir * WATER_SPEED
			latest_water_slide = "vertical"
			latest_water_normal = get_wall_normal()
		else:
			velocity.y = 0
		if !( is_on_wall() or is_on_ceiling() or is_on_floor() ):
			# Turn around corner when not touching anything
			print(latest_water_normal.normalized())
			if latest_water_slide == "vertical":
				
				# Slides on left wall
				if latest_water_normal.normalized().x > 0:
					move_and_collide(Vector2(-1, y_dir) * 10)
					move_and_collide(Vector2(-1, -y_dir) * 20)
				# Slides on right wall
				if latest_water_normal.normalized().x < 0:
					move_and_collide(Vector2(1, y_dir) * 10)
					move_and_collide(Vector2(1, -y_dir) * 20)
			if latest_water_slide == "horizontal":
				# Slides on floor
				if latest_water_normal.normalized().y < 0:
					print("floor")
					move_and_collide(Vector2(x_dir, 1) * 10)
					move_and_collide(Vector2(-x_dir, 1) * 20)
				# Slides on ceiling
				elif latest_water_normal.normalized().y >= 0:
					print("ceiling")
					move_and_collide(Vector2(x_dir, -1) * 10)
					move_and_collide(Vector2(-x_dir, -1) * 20)
	#endregion
	#region Icecube
	if state == States.Ice:
		if is_on_floor():
			sprite.scale.x = lerp(sprite.scale.x, 1.3, 0.8)
			sprite.scale.y = lerp(sprite.scale.y, 0.5, 0.8)
			
		
	#endregion
	move_and_slide()

func _process(_delta: float) -> void:
	if state == States.Snow:
		if Input.is_action_just_pressed("shoot"):
			inst_snowball(snowball)
		if Input.is_action_just_pressed("water") and is_on_floor():
			set_state(States.Water)
		if Input.is_action_just_pressed("ice") and Input.is_action_pressed("down"):
			set_state(States.Ice)
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

func _on_ice_cube_drop_timer_timeout() -> void:
	ice_drop()

func ice_drop():
	ice_cube_shape.disabled = true
	ice_cube_drop_shape.disabled = false
	sprite.scale = Vector2(PLACEHOLDER_ICECUBE_SIZE.x * 0.8, PLACEHOLDER_ICECUBE_SIZE.y * 1.2)
	velocity = Vector2.DOWN * ICE_DROP_VELOCITY

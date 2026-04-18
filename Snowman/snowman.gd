extends CharacterBody2D

signal ice_land(force)

# Sprite Pivot references
@onready var snow_sprite_pivot: Node2D = $Sprites/SnowSpritePivot
@onready var ice_sprite_pivot: Node2D = $Sprites/IceSpritePivot
@onready var water_sprite_pivot: Node2D = $Sprites/WaterSpritePivot

# Node references
@onready var snowman_shape: CollisionShape2D = $SnowmanShape
@onready var water_shape: CollisionShape2D = $WaterShape
@onready var ice_cube_shape: CollisionShape2D = $IceCubeShape
@onready var water_environment_area: Area2D = $WaterEnvironmentArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var phealth_label: Label = %phealth_label

#@onready var camera_2d: Camera2D = $Camera2D
@onready var camera_2d: Camera = $"../Camera2D"

# States
enum States {Snow, Water, Ice, Steam}
var invis := false

@export var snowball: PackedScene

# States
var state: States = States.Snow: set = set_state
var facing := Vector2.RIGHT
var throw_direction: Vector2
var latest_water_slide: String
var latest_water_normal: Vector2
var ice_force := 0

# Sprite sizes
const PLACEHOLDER_SNOWMAN_SIZE = Vector2(0.4, 0.578)
const PLACEHOLDER_WATER_SIZE = Vector2(0.2, 0.2)
const PLACEHOLDER_ICECUBE_SIZE = Vector2(0.672, 0.672)

# Velocities
const SPEED = 400.0
const WATER_SPEED = 660.0
const JUMP_VELOCITY = -650.0
const ACCELERATION = 0.1
const DECELERATION = 0.2
const GRAVITY = 1200
const RELEASE_VELOCITY = -350.0
const ICE_DROP_VELOCITY = 1500.0

func set_state(new_state):
	water_shape.disabled = true
	snowman_shape.disabled = true
	ice_cube_shape.disabled = true
	water_sprite_pivot.hide()
	snow_sprite_pivot.hide()
	ice_sprite_pivot.hide()
	
	if new_state == States.Water:
		
		water_sprite_pivot.show()
		move_and_collide(Vector2.DOWN * 25)
		water_shape.disabled = false
		velocity = Vector2.ZERO
		
	if new_state == States.Snow:
		
		snow_sprite_pivot.show()
		snowman_shape.disabled = false
		if state == States.Ice:
			snow_sprite_pivot.scale = Vector2(3.0,0.4)
		# Ice to Snow
	if new_state == States.Ice:
		
		ice_sprite_pivot.show()
		ice_force = 0
		velocity = Vector2.ZERO
		ice_cube_shape.disabled = false
		velocity = Vector2.DOWN * ICE_DROP_VELOCITY
	
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
		
		#region Squash & stretch based on y velocity
		if is_on_floor():
			#sprite.scale = PLACEHOLDER_SNOWMAN_SIZE
			snow_sprite_pivot.scale.y = lerp(snow_sprite_pivot.scale.y, 1.0, 0.1)
			snow_sprite_pivot.scale.x = lerp(snow_sprite_pivot.scale.x, 1.0, 0.1)
		else:
			snow_sprite_pivot.scale.y = 1.0 + -velocity.y / 6000
			snow_sprite_pivot.scale.x = 1.0 + velocity.y / 6000
		
		#endregion
	#endregion
	#region Water

	if state == States.Water:

		var x_dir = Input.get_axis("left", "right")
		var y_dir = Input.get_axis("up", "down")
		
		if is_on_floor() or is_on_ceiling():
			velocity.x = x_dir * WATER_SPEED
			latest_water_slide = "horizontal"
			latest_water_normal = get_floor_normal()
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
					move_and_collide(Vector2(x_dir, 1) * 10)
					move_and_collide(Vector2(-x_dir, 1) * 20)
				# Slides on ceiling
				elif latest_water_normal.normalized().y >= 0:
					move_and_collide(Vector2(x_dir, -1) * 10)
					move_and_collide(Vector2(-x_dir, -1) * 20)
	#endregion
	#region Icecube
	if state == States.Ice:
		# Reset ice to snowman + some fx
		ice_force += 25
		if is_on_floor():
			emit_signal("ice_land", ice_force)
			snow_sprite_pivot.scale = Vector2(1.0, 0.3)
			ice_cube_shape.scale = Vector2(1.0, 0.3)
			move_and_collide(Vector2.DOWN * 10)
			camera_2d.screen_shake(float(ice_force) * 0.1, Vector2(1.0, 3.0))
			set_state(States.Snow)
			ice_cube_shape.scale = Vector2.ONE
		
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

# Damage ground-pounded enemies
func _on_ice_damage_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and state == States.Ice:
		body.take_damage(100)

# Take damage & apply knockback when colliding with enemies
func hit(enemy, damage, knockback):
	if state == States.Snow:
		if invis == false:
			camera_2d.screen_shake(20)
			Global.player_health -= damage
			phealth_label.text = "Health: " + str(Global.player_health)
			if Global.player_health <= 0:
				die()
		velocity = global_position.direction_to(enemy.global_position) * -Vector2(knockback, knockback * 0.4)
		move_and_slide()
		animation_player.play("invisframes")
		invis = true
		await animation_player.animation_finished
		invis = false

func die():
	queue_free()

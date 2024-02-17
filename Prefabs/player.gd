extends Node2D

var grid_size = 128 # Size of the grid step
var move_speed = 5.0 # How fast the character moves
var is_moving = false # Track if movement is happening
var start_pos = Vector2() # Start position of movement
var target_pos = Vector2() # Target position of movement
var move_timer = 0.4 # Timer to control the lerp and arc calculation
var jump_height = 40.0 # Max height of the parabolic arc
var double_jump_height = 120.0
var gravity = 10.0
var fall_speed = 0.0
var is_in_air = false


@onready var ray_cast_left = $LeftRay
@onready var ray_cast_right = $RightRay
@onready var ray_cast_down = $GroundCheck

func _process(delta):
	print("x: ",position.x, " y: ", position.y)
	if !is_moving:
		if Input.is_action_just_pressed("ui_right"):
			start_movement(Vector2(grid_size, 0))
		elif Input.is_action_just_pressed("ui_left"):
			start_movement(Vector2(-grid_size, 0))

	if is_moving:
		move_character(delta)
	elif is_in_air:
		apply_gravity(delta)
	
	if ray_cast_down.is_colliding():
		is_in_air = false
		fall_speed = 0.0
	else:
		is_in_air = true
func start_movement(direction):
	if is_in_air:
		return
	
	start_pos = position
	target_pos = start_pos + direction
	move_timer = 0.0
	is_moving = true
	
	var obstacle_detected = false
	if direction.x > 0 and ray_cast_right.enabled and ray_cast_right.is_colliding():
		obstacle_detected = true
	elif direction.x < 0 and ray_cast_left.enabled and ray_cast_left.is_colliding():
		obstacle_detected = true
		
	if obstacle_detected:
		jump_height = double_jump_height
	else:
		jump_height = 40.0
func move_character(delta):
	move_timer += delta * move_speed
	if move_timer > 1.0:
		move_timer = 1.0
		is_moving = false

	var horizontal_pos = lerp(start_pos.x, target_pos.x, move_timer)
	# Parabolic arc calculation for vertical position. Adjust `jump_height` for a more pronounced arc.
	var t = move_timer * 2 - 1 # Normalize time to -1 to 1 for the parabolic formula
	var vertical_pos = -jump_height * t * t + jump_height
	position.x = horizontal_pos
	position.y = start_pos.y - vertical_pos# Subtract because y is down in Godot

	if move_timer >= 1.0: # Reset movement
		position = target_pos
		is_moving = false
		
func apply_gravity(delta):
	fall_speed += gravity * delta
	position.y += fall_speed

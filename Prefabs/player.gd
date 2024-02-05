extends Node2D

var grid_size = 64 # Size of the grid step
var move_speed = 5.0 # How fast the character moves
var is_moving = false # Track if movement is happening
var start_pos = Vector2() # Start position of movement
var target_pos = Vector2() # Target position of movement
var move_timer = 0.0 # Timer to control the lerp and arc calculation
var jump_height = 40.0 # Max height of the parabolic arc
func _process(delta):
	if !is_moving:
		if Input.is_action_just_pressed("ui_right"):
			start_movement(Vector2(grid_size, 0))
		elif Input.is_action_just_pressed("ui_left"):
			start_movement(Vector2(-grid_size, 0))

	if is_moving:
		move_character(delta)

func start_movement(direction):
	start_pos = position
	target_pos = start_pos + direction
	move_timer = 0.0
	is_moving = true
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
	position.y = start_pos.y - vertical_pos # Subtract because y is down in Godot

	if move_timer >= 1.0: # Reset movement
		position = target_pos
		is_moving = false

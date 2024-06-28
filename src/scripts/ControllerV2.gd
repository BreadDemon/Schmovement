extends CharacterBody3D
class_name Player

# Airborne vars
@export_category("Jump Settings")
@export_range(0.1, 10, 0.1) var gravity_force: float = 1.0 # (1.2)
@export var remove_air_penalty_offset: bool = false
@export_range(0, 4, 0.1) var air_penalty: float = 0.0 # (1.3)
@export_range(0, 10) var jump_velocity: float = 4.7 # (4.5)
var air_penalty_offset: float = 12 # (17) Maybe disponibilize this for edits
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var has_jumped: bool = false
var set_coyote: bool = false
var coyote_timer: float = 0.0
@export_range(0, 3, 0.1) var coyote_timer_max: float = 0.2
var jump_buffer_timer: float = 0.0
@export_range(0, 3, 0.1) var jump_buffer_timer_max: float = 0.2
var has_wall_jump: bool = true
var wall_jump_wait: float = 0.0
@export_range(0, 2, 0.01) var wall_jump_wait_max = 0.21
@export var use_jump_buffer_for_wall_jumps: bool = true

# Only for textual display
var grounded: bool

# Speed vars
@export_category("Speed Variables")
@export_range(0, 20, 0.1) var crouched_speed: float = 3.0
@export_range(0, 20, 0.1) var walk_speed: float = 5.0
@export_range(0, 20, 0.1) var run_speed: float = 7.0
var current_speed:float = walk_speed
@export var air_speed_penalty: bool = false
@export_range(0, 1, 0.01) var air_speed_penalty_amount: float = 0.9

@export_category("Controller settings")
# Controller States
enum States { WALKING, RUNNING, CROUCHING, SLIDING }
var current_state: States = States.WALKING
var previous_state: States = States.WALKING
@export var scene_return: ReturnNode

# Mouse Vars
@export_category("Mouse Settings")
@export_range(0, 1, 0.01) var sensitivity: float = 0.1

# Movement vars
var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO

# Lerp vars
@export_category("Lerp Settings")
var lerp_accel: float = 15 # (20)
@export_range(0, 5, 0.1) var speed_lerp_factor: float = 2.0
@export_range(0, 5, 0.1) var crouch_camera_lerp_factor = 3.0

# Slide vars
@export_category("Slide Settings")
var slide_timer: float = 0.0
var slide_vector: Vector2 = Vector2.ZERO
var slide_direction = Vector3.ZERO
@export_range(0, 5, 0.1) var slide_timer_max: float = 1.0
@export_range(0, 10, 0.1) var slide_speed: float = 5.0

# Ramp vars
@export_category("Ramp Vars")
@export_range(0, 30, 1) var MAX_ANGLE_VARIANCE: float = 15.0
var TOLERANCE: float = 0.1 # Tolerance for angle checking
var is_on_ramp: bool
var is_looking_down_ramp: bool
var ramp_inclination: float
var ramp_modifier: float = 0.0
@export_range(0, 2, 0.1) var ramp_modifier_base: float = 0.5

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("Pause"):
		pause_menu.pause()
	elif event.is_action_pressed("Reset"):
		reset()
	elif event.is_action_pressed("Return"):
		reset_pos()

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
			camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) 

func _process(_delta):
	var debug_vars: Label = get_node("Debug/PanelContainer/VBoxContainer/Variables")
	var text = "CurrSpeed: %.2f\n" % current_speed
	text += "Vel.X: %.2f\n" % velocity.x
	text += "Vel.Z: %.2f\n" % velocity.z
	text += "State: " + str(States.keys()[current_state]) + "\n"
	text += "PrevState: " + str(States.keys()[previous_state]) + "\n"
	text += "SlideTimer: %.2f\n" % slide_timer
	text += "CoyoteTimer: %.2f\n" % coyote_timer
	text += "JumpBuffer: %.2f\n" % jump_buffer_timer
	text += "WallJumpWait: %.2f\n" % wall_jump_wait
	text += "Grounded: " + str(grounded) + "\n"
	text += "Has_wall_jump: " + str(has_wall_jump) + "\n"
	text += "Can_wall_jump: " + str(can_wall_jump()) + "\n"
	text += "Is_on_ramp: " + str(is_on_ramp) + "\n"
	text += "Is_looking_down_ramp: " + str(is_looking_down_ramp) + "\n"
	text += "Ramp_angle: %.2f\n" % ramp_inclination  
	text += "Ramp_modifier: %.2f\n" % ramp_modifier  
	debug_vars.text = text
	
	if position.y < -100:
		transform.origin = scene_return.transform.origin

# Controller parts
@onready var standing_cylinder = $StandingCylinder
@onready var crouching_cylinder = $CrouchingCylinder
@onready var crouched_view = $CrouchedView
@onready var standing_view = $StandingView
@onready var inside_object = $InsideObject
@onready var neck = $Neck
@onready var interact = $Neck/Interact
@onready var eyes = $Neck/Eyes
@onready var camera = $Neck/Eyes/Camera3D
@onready var pause_menu = $PauseMenu
@onready var timer = $Timer
@onready var debug = $Debug
@onready var ramp_cast = $RampCast

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	standing_cylinder.disabled = false
	crouching_cylinder.disabled = true
	var global_return = get_parent().get_node("Scene_return")
	scene_return = global_return
	var keybindings = ConfigFileHandler.load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])

func handle_timers(delta):
	if !is_on_ramp || is_on_ramp and !is_looking_down_ramp:
		slide_timer -= delta
	if slide_timer < 0.0:
		slide_timer = 0.0
	
	coyote_timer -= delta
	if coyote_timer < 0.0:
		coyote_timer = 0.0
	
	jump_buffer_timer -= delta
	if jump_buffer_timer < 0.0:
		jump_buffer_timer = 0.0
	
	wall_jump_wait -= delta
	if wall_jump_wait < -1.0:
		wall_jump_wait = -1.0

func toggle_crouch_cylinder():
	standing_cylinder.disabled = true
	crouching_cylinder.disabled = false
func toggle_standing_cylinder():
	standing_cylinder.disabled = false
	crouching_cylinder.disabled = true
func can_slide() -> bool:
	var is_crouched: bool = Input.is_action_pressed("Crouch") 
	var is_running: bool = current_state == States.RUNNING
	var is_sliding: bool = current_state == States.SLIDING
	var is_over_slide_timer: bool = slide_timer <= 0.0
	return is_crouched and is_running and !is_sliding and is_over_slide_timer
func keep_sliding() -> bool:
	var slide_state: bool = current_state == States.SLIDING
	var still_sliding: bool = slide_timer > 0.0
	var still_crouching: bool = Input.is_action_pressed("Crouch")
	return still_sliding and still_crouching and is_on_floor() and slide_state
func can_sprint() -> bool:
	var tried_running: bool = Input.is_action_pressed("Sprint") 
	var is_crouching: bool = current_state != States.CROUCHING 
	var is_sliding: bool = current_state != States.SLIDING
	var is_moving = input_dir != Vector2.ZERO
	var is_going_back = Input.is_action_pressed("back")
	return tried_running and is_crouching and is_sliding and is_moving and !is_going_back
func switch_state(state: States):
	previous_state = current_state
	current_state = state
func handle_states(delta):
	if can_slide() || keep_sliding():
		if current_state != States.SLIDING:
			switch_state(States.SLIDING)
			toggle_crouch_cylinder()
			slide_timer = slide_timer_max
			slide_vector = input_dir
			slide_direction = neck.transform.basis
		if is_on_floor():
			direction = (slide_direction * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
			if is_on_ramp:
				apply_floor_snap()
			if is_looking_down_ramp:
				current_speed = (slide_timer + 1 + ramp_modifier * delta) * slide_speed
				ramp_modifier += ramp_modifier_base
			else:
				current_speed = (slide_timer + 1) * slide_speed
		neck.position.y = lerp(neck.position.y, crouched_view.position.y, delta * crouch_camera_lerp_factor)
	elif can_sprint():
		if current_state != States.RUNNING:
			switch_state(States.RUNNING)
		if is_on_floor():
			current_speed = lerp(current_speed, run_speed, delta * lerp_accel/speed_lerp_factor)
		neck.position.y = lerp(neck.position.y, standing_view.position.y, delta * crouch_camera_lerp_factor)
	elif Input.is_action_pressed("Crouch") or inside_object.is_colliding():
		if current_state != States.CROUCHING:
			switch_state(States.CROUCHING)
			toggle_crouch_cylinder()
		if is_on_floor():
			current_speed = lerp(current_speed, crouched_speed, delta * lerp_accel/speed_lerp_factor)
			apply_floor_snap()
		neck.position.y = lerp(neck.position.y, crouched_view.position.y, delta * crouch_camera_lerp_factor)
	else:
		if current_state != States.WALKING:
			switch_state(States.WALKING)
			toggle_standing_cylinder()
		if is_on_floor():
			current_speed = lerp(current_speed, walk_speed, delta * lerp_accel/speed_lerp_factor)
		neck.position.y = lerp(neck.position.y, standing_view.position.y, delta * crouch_camera_lerp_factor)

func handle_direction(delta):
	if is_on_floor():
		direction = lerp(direction, (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_accel)
	else:
		if remove_air_penalty_offset:
			direction = lerp(direction, (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * (lerp_accel - air_penalty + 0.1))
		else:
			direction = lerp(direction, (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * (lerp_accel - (air_penalty_offset + air_penalty) + 0.1))

func can_coyote() -> bool:
	var coyote_timer_over: bool = coyote_timer <= 0.0
	return !has_jumped and !coyote_timer_over
func can_wall_jump() -> bool:
	var has_jump:bool = has_wall_jump 
	var wall_jump_timer_over: bool = wall_jump_wait < 0
	var tried_jump: bool = Input.is_action_just_pressed("Jump")
	var on_wall: bool = is_on_wall() and !is_on_floor() 
	if use_jump_buffer_for_wall_jumps:
		return jump_buffer_timer > 0 and has_jump and wall_jump_timer_over and on_wall
	return has_jump and wall_jump_timer_over and tried_jump and on_wall
func handle_coyote(_delta):
	if !is_on_floor() and !has_jumped and !set_coyote:
		coyote_timer = coyote_timer_max
		set_coyote = true
	
	if Input.is_action_just_pressed("Jump") and can_coyote():
		velocity.y = jump_velocity
		slide_timer = 0.0
		has_jumped = true
func handle_jump(_delta):
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = jump_buffer_timer_max
	
	if jump_buffer_timer > 0 and is_on_floor():
		velocity.y = jump_velocity
		wall_jump_wait = wall_jump_wait_max
		slide_timer = 0.0
		has_jumped = true
func handle_wall_jump():
	if can_wall_jump():
		has_wall_jump = false
		velocity.y = jump_velocity
func handle_vertical(delta):
	if not is_on_floor():
		velocity.y -= gravity * gravity_force * delta
	else:
		has_jumped = false
		set_coyote = false
		has_wall_jump = true
	
	handle_coyote(delta)
	handle_jump(delta)
	handle_wall_jump()

func get_camera_facing_direction() -> Vector3:
	# Assuming the camera is a child of the player and its forward direction is its local -Z axis
	return -camera.global_transform.basis.z
func rad2deg(radians: float) -> float:
	return radians * 180.0 / PI
func is_facing_downward(normal: Vector3, facing_direction: Vector3) -> bool:
	var horizontal_normal = normal
	horizontal_normal.y = 0
	horizontal_normal = horizontal_normal.normalized()

	# Project facing direction onto horizontal plane
	var horizontal_facing_direction = facing_direction
	horizontal_facing_direction.y = 0
	horizontal_facing_direction = horizontal_facing_direction.normalized()

	var angle = acos(horizontal_facing_direction.dot(horizontal_normal) / (horizontal_facing_direction.length() * horizontal_normal.length()))
	var angle_degrees = rad2deg(angle)
	return angle_degrees <= MAX_ANGLE_VARIANCE
func calculate_ramp_inclination(normal: Vector3) -> float:
	var vertical_direction = Vector3(0, 1, 0) # Assuming y-axis is up
	var dot_product = normal.dot(vertical_direction)
	var normal_magnitude = normal.length()
	var vertical_magnitude = vertical_direction.length()
	var cos_theta = dot_product / (normal_magnitude * vertical_magnitude)
	return acos(cos_theta)
func is_ramp(normal: Vector3) -> bool:
	# Assuming a ramp is anything not horizontal
	var vertical_direction = Vector3(0, 1, 0)
	return abs(normal.dot(vertical_direction)) < 1.0 - TOLERANCE
func check_ramp_and_inclination():
	if ramp_cast.is_colliding():
		var collision_normal = ramp_cast.get_collision_normal()
		
		# Check if the surface is a ramp
		if is_ramp(collision_normal):
			is_on_ramp = true

			var inclination = calculate_ramp_inclination(collision_normal)
			ramp_inclination = rad2deg(inclination)

			var player_facing_direction = get_camera_facing_direction()
			if is_facing_downward(collision_normal, player_facing_direction):
				is_looking_down_ramp = true
			else:
				is_looking_down_ramp = false
		else:
			is_on_ramp = false
			ramp_modifier = 0.0
func finish_movement(delta):
	if is_on_floor():
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
	else:
		if direction:
			if air_speed_penalty and current_speed > 10.0:
				current_speed = lerp(current_speed, current_speed * air_speed_penalty_amount, delta/4)
			else:
				velocity.x = direction.x * current_speed
				velocity.z = direction.z * current_speed
	move_and_slide()
func _physics_process(delta):
	input_dir = Input.get_vector("left", "right", "forward", "back")
	grounded = is_on_floor()
	
	handle_direction(delta)
	handle_timers(delta)
	handle_states(delta)
	handle_vertical(delta)
	check_ramp_and_inclination()
	finish_movement(delta)

# TODO: Make a go to last checkpoint
func reset_pos():
	var run_timer = get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
	if run_timer.running:
		return
	transform.origin = scene_return.transform.origin
	current_speed = 0
	slide_timer = 0
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0
func reset():
	var reset_timer = get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
	reset_timer.reset_timer()
	transform.origin = Global.origin_point
	Global.start.visible = true
	Global.start.show_other_runs()
	current_speed = 0
	slide_timer = 0
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0

extends CharacterBody3D

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Player Objects
@onready var standing = $Standing
@onready var crouching = $Crouching
@onready var ray_cast_3d = $RayCast3D
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var menu := $PauseMenu

# Speed vars
var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 7.0
@export var crouched_speed = 3.0
@export var jump_velocity = 4.5

# States
enum states {
	WALKING,
	RUNNING,
	CROUCHING,
	SLIDING,
}
var curr_state = states.WALKING
var prev_state = states.WALKING

# State vars
var walking_state = false
var crouching_state = false
var running_state = false
var sliding_state = false

# Slide vars
var sliding_timer = 0.0
var sliding_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_direction = Vector3.ZERO
var slide_speed = 5

# Crouch vars
@export var crouching_depth = -0.75
@export var crouch_lerp = 8.0
@export var lerp_accel = 15.0

# Direction
var direction = Vector3.ZERO
var input_dir = Vector2.ZERO

# Mouse vars
@export var mouse_sensitivity = 0.1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	standing.disabled = false
	crouching.disabled = true

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		menu.pause()

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
				neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
				camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) 

func _physics_process(delta):
	input_dir = Input.get_vector("left", "right", "forward", "back")

	handle_crouch(delta)
	handle_standing(delta)
	handle_jump()
	handle_sliding(delta)
	handle_moving(delta)
	move_and_slide()

func set_standing():
	standing.disabled = false
	crouching.disabled = true
	
func set_crouching():
	standing.disabled = true
	crouching.disabled = false

# Handles standing
func handle_standing(delta):
	if !ray_cast_3d.is_colliding():
		set_standing()
		neck.position.y = lerp(neck.position.y, 0.65, delta * crouch_lerp)
		if Input.is_action_pressed("Sprint") and is_on_floor() and not Input.is_action_pressed("back"):
			current_speed = sprinting_speed
			crouching_state = false
			walking_state = false
			running_state = true
		else: 
			current_speed = walking_speed
			crouching_state = false
			walking_state = true
			running_state = false

# Handles crouching logic
func handle_crouch(delta):
	if Input.is_action_pressed("Crouch"):
		neck.position.y = lerp(neck.position.y, 0.65 + crouching_depth, delta * crouch_lerp)
		set_crouching()
		crouching_state = true
		walking_state = false
		if is_on_floor():
			if running_state and input_dir != Vector2.ZERO and !sliding_state:
				sliding_state = true
				sliding_timer = sliding_timer_max
				slide_vector = input_dir
				slide_direction = neck.transform.basis
				print("Slide begin")
			else:
				current_speed = crouched_speed
			running_state = false

# Handle jump, disables a slide so you can instantly slide once landing
func handle_jump():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity
		sliding_state = false

# Handle slide timer and camera tilt
func handle_sliding(delta):
	if sliding_timer > 0:
		sliding_timer -= delta
		direction = (slide_direction * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (sliding_timer+1) * slide_speed
		if sliding_timer <= 0:
			sliding_state = false
			print("Slide end")

# Check if the player is on ground and applies the movement speed
# if not moving it slows down to a stop gradually
# if on air applies a lerp for inertia
func handle_moving(delta):
	# Make movement direction the direction the player is looking at
	direction = lerp(direction, (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_accel)
	if is_on_floor():
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
	else:
		velocity.y -= gravity * delta
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 2.0)

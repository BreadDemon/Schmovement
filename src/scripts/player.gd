extends CharacterBody3D
class_name Player

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var jump_buffer_time = 0.2
var jump_timer = 0
var wall_jump_wait = 0.0
var wall_jump_wait_max = 0.2
var can_wall_jump
var can_coyote
var coyote_timer = 0.0
var coyote_timer_max = 0.1
var has_jumped

# Player Objects
@onready var standing = $Standing
@onready var crouching = $Crouching
@onready var ray_cast_3d = $RayCast3D
@onready var ray_cast_teleporter = $RayCast3D_teleporter
@onready var neck := $Neck
@onready var eyes = $Neck/Eyes
@onready var camera = $Neck/Eyes/Camera3D
@onready var menu := $PauseMenu

# Speed vars
var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 7
@export var crouched_speed = 3.0
@export var jump_velocity = 4.7

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
var slide_speed_init = 5
var spam_timer = 0.0
var spam_timer_max = 0.6
var spam_state = false

# Head bobbing vars
var head_bob_sprinting_speed = 22.0
var head_bob_walking_speed = 14.0
var head_bob_crouching_speed = 10.0

var head_bob_sprinting_intensity = 0.4
var head_bob_walking_intensity = 0.2
var head_bob_crouching_intensity = 0.1

var head_bob_vector = Vector2.ZERO
var head_bob_index  = 0.0
var head_bob_curr_intensity = 0.0



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
	elif event.is_action_pressed("Reset"):
		reset()

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) 

func _physics_process(delta):
	input_dir = Input.get_vector("left", "right", "forward", "back")
	handle_movement(delta)
	move_and_slide()

func handle_movement(delta):
	
	if Input.is_action_just_released("Crouch") and is_on_floor():
		sliding_timer = 0
		print("Slide end")
		sliding_state = false
	
	if Input.is_action_pressed("Crouch"):
		neck.position.y = lerp(neck.position.y, 0.65 + crouching_depth, delta * crouch_lerp)
		set_crouching()
		crouching_state = true
		walking_state = false
		if is_on_floor():
			if running_state and input_dir != Vector2.ZERO and !sliding_state and !spam_state:
				sliding_state = true
				sliding_timer = sliding_timer_max
				slide_vector = input_dir
				spam_state = true
				spam_timer = spam_timer_max
				slide_direction = neck.transform.basis
				print("Slide begin")
			else:
				current_speed = crouched_speed
			running_state = false
	if !ray_cast_3d.is_colliding() and !Input.is_action_pressed("Crouch"):
		set_standing()
		neck.position.y = lerp(neck.position.y, 0.65, delta * crouch_lerp)
		if Input.is_action_pressed("Sprint") and is_on_floor() and not Input.is_action_pressed("back"):
			current_speed = sprinting_speed
			crouching_state = false
			walking_state = false
			running_state = true
		elif is_on_floor(): 
			current_speed = walking_speed
			crouching_state = false
			walking_state = true
			running_state = false

	handle_bob(delta)
	handle_jump(delta)
	handle_sliding(delta)
	handle_moving(delta)

func handle_bob(delta):
	if running_state:
		head_bob_curr_intensity = head_bob_sprinting_intensity
		head_bob_index += head_bob_sprinting_speed * delta
	elif walking_speed:
		head_bob_curr_intensity = head_bob_walking_intensity
		head_bob_index += head_bob_walking_speed * delta
	elif crouching_state:
		head_bob_curr_intensity = head_bob_crouching_intensity
		head_bob_index += head_bob_crouching_speed * delta
		
	if is_on_floor() and !sliding_state and input_dir != Vector2.ZERO:
		head_bob_vector.y = sin(head_bob_index)
		head_bob_vector.x = sin(head_bob_index/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bob_vector.y * (head_bob_curr_intensity * 2.0), delta)
		eyes.position.x = lerp(eyes.position.x, head_bob_vector.x * head_bob_curr_intensity, delta)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta)

func set_standing():
	standing.disabled = false
	crouching.disabled = true

func set_crouching():
	standing.disabled = true
	crouching.disabled = false

# Handle jump, disables a slide so you can instantly slide once landing
func handle_jump(delta):
	jump_timer -= delta
	wall_jump_wait -= delta
	coyote_timer -= delta
	
	if !is_on_floor() and !has_jumped and coyote_timer < 0:
		coyote_timer = coyote_timer_max
		can_coyote = true
	
	if is_on_floor():
		can_wall_jump = true
		has_jumped = false
	
	if Input.is_action_just_pressed("Jump"):
		jump_timer = jump_buffer_time

	if jump_timer > 0 and is_on_wall() and can_wall_jump and !is_on_floor() and wall_jump_wait < 0:
		can_wall_jump = false
		can_coyote = false
		has_jumped = true
		velocity.y = jump_velocity


	if (jump_timer > 0) and is_on_floor():
		velocity.y = jump_velocity
		wall_jump_wait = wall_jump_wait_max
		spam_state = false
		can_coyote = false
		has_jumped = true
		spam_timer = 0
		print("Slide end")
		sliding_state = false
		current_speed = (sliding_timer+1) * slide_speed
		sliding_timer = 0
		
	if jump_timer > 0 and !is_on_floor() and !has_jumped and can_coyote and coyote_timer > 0:
		velocity.y = jump_velocity
		wall_jump_wait = wall_jump_wait_max
		spam_state = false
		can_coyote = false
		has_jumped = true
		spam_timer = 0
		print("Slide end")
		print("Coyote jump")
		sliding_state = false
		current_speed = (sliding_timer+1) * slide_speed
		sliding_timer = 0


# Handle slide timer and camera tilt
func handle_sliding(delta):
	spam_timer -= delta
	if spam_timer <= 0:
		spam_state = false
	
	if sliding_timer > 0 and is_on_floor():
		sliding_timer -= delta
		direction = (slide_direction * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (sliding_timer+1) * slide_speed
		if sliding_timer <= 0:
			sliding_state = false
			print("Slide end")
	elif sliding_timer > 0:
		sliding_timer -= delta
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
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 3.0)

func reset():
	var timer = get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
	timer.reset_timer()
	transform.origin = Global.origin_point
	current_speed = 0
	sliding_state = false
	running_state = false
	crouching_state = false
	walking_state = true
	set_standing()
	sliding_timer = 0
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0

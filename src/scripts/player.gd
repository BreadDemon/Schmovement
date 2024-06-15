extends CharacterBody3D

@onready var standing = $Standing
@onready var crouching = $Crouching
@onready var ray_cast_3d = $RayCast3D

var current_speed = 5.0

@export var walking_speed = 5.0
@export var sprinting_speed = 7.0
@export var crouched_speed = 3.0

@export var jump_velocity = 4.5

@export var mouse_sensitivity = 0.1

@export var crouching_depth = -0.75

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

@export var crouch_lerp = 8.0
@export var lerp_accel = 15.0
var direction = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		$PauseMenu.pause()

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) 

func _physics_process(delta):
	if Input.is_action_pressed("Crouch") and is_on_floor():
		current_speed = crouched_speed
		neck.position.y = lerp(neck.position.y, 0.65 + crouching_depth, delta * crouch_lerp)
		standing.disabled = true;
		crouching.disabled = false;
	elif Input.is_action_pressed("Crouch"):
		neck.position.y = lerp(neck.position.y, 0.65 + crouching_depth, delta * crouch_lerp)
		standing.disabled = true;
		crouching.disabled = false;
	elif !ray_cast_3d.is_colliding():
		standing.disabled = false;
		crouching.disabled = true;
		neck.position.y = lerp(neck.position.y, 0.65, delta * crouch_lerp)
		if Input.is_action_pressed("Sprint") and is_on_floor() and not Input.is_action_pressed("back"):
			current_speed = sprinting_speed
		else:
			current_speed = walking_speed
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = lerp(direction, (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_accel)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

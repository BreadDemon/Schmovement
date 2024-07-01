extends ColorRect

@onready var animator: AnimationPlayer = $AnimationPlayer
@export var input_settings: PackedScene

var pause_timer: float = 0.0
var pause_timer_max: float = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	var Resume = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
	Resume.button_down.connect(_on_pause_button_pressed)
	var Reset = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResetButton
	Reset.button_down.connect(_on_reset_button_pressed)
	var Exit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ExitButton
	Exit.button_down.connect(get_tree().quit)

@onready var debug_warning = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DebugWarning
func _process(delta):
	if Global.debug:
		debug_warning.visible = true
	else:
		debug_warning.visible = false

	pause_timer -= delta
	if pause_timer <= -1.0:
		pause_timer = -1.0

func _input(event):
	if Input.is_action_just_pressed("CloseMenu") and get_tree().paused:
		get_parent().load_debug_vars()
		pause_timer = pause_timer_max
		animator.play("Unpause")
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	animator.play("Pause")
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_pause_button_pressed():
	animator.play("Unpause")
	get_parent().load_debug_vars()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_reset_button_pressed():
	var player = get_parent()
	player.reset()
	_on_pause_button_pressed()

func _on_settings_button_pressed():
	var Settings = input_settings.instantiate()
	add_child(Settings)
	Settings.ingame = true
	Settings.player = get_parent()
	animator.play("hide_pause")
	Settings.animator.play("open_ingame")

extends ColorRect

@onready var animator: AnimationPlayer =$AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	var Resume = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
	Resume.button_down.connect(_on_pause_button_pressed)
	var Reset = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResetButton
	Reset.button_down.connect(_on_reset_button_pressed)
	var Exit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ExitButton
	Exit.button_down.connect(get_tree().quit)

func pause():
	animator.play("Pause")
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_pause_button_pressed():
	animator.play("Unpause")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_reset_button_pressed():
	var player = get_parent()
	player.reset()

extends Control

@onready var input_button_scene = preload('res://nodes/menus/input_button.tscn')
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Keybinds/MarginContainer/ScrollContainer/ActionList

# DEBUG STUFF 

## Speed Variables
@onready var debug_settings = $PanelContainer/MarginContainer/VBoxContainer/TabContainer
@onready var debug_check = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/EnableDebug/CheckButton

@onready var walk_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/WalkSpeedHbox/walk_speed_slider
@onready var walk_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/WalkSpeedHbox/WalkSpeedValue
@onready var crouch_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CrouchSpeedHbox/crouch_speed_slider
@onready var crouch_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CrouchSpeedHbox/CrouchSpeedValue
@onready var run_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RunSpeedHbox/run_speed_slider
@onready var run_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RunSpeedHbox/RunSpeedValue
@onready var enable_air_penalty = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/EnableAirPenalty
@onready var air_speed_penalty_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/AirSpeedPenaltyAmountHbox/air_speed_penalty_slider
@onready var air_speed_penalty_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/AirSpeedPenaltyAmountHbox/AirSpeedPenaltyValue


@onready var animator: AnimationPlayer = $AnimationPlayer

@onready var player: Player

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var ingame = false

var input_actions = {
	"forward": "Move Forward",
	"back": "Move Backwards",
	"left": "Move Left",
	"right": "Move Right",
	"Sprint": "Sprint",
	"Crouch": "Crouch",
	"Jump": "Jump",
	"Reset": "Reset"
}

func _ready():
	_load_keybindings_from_settings()
	_create_action_list()
	if !Global.debug:
		debug_settings.set_tab_hidden(2, true)
	else:
		debug_check.button_pressed = true

func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])

func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()

	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."

func _input(event):
	if is_remapping:
		if (event is InputEventKey || (event is InputEventMouseButton && event.pressed)):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
				
			InputMap.action_erase_events(action_to_remap)
			
			InputMap.action_add_event(action_to_remap, event)
			ConfigFileHandler.save_keybinding(action_to_remap, event)
			
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()

func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_button_pressed():
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size > 0:
			ConfigFileHandler.save_keybinding(action, events[0])
	_create_action_list()

func _on_back_button_pressed():
	if !ingame:
		get_tree().change_scene_to_file("res://nodes/menus/game_menu.tscn")
	else:
		animator.play("close_ingame")
		var pause = get_parent()
		pause.animator.play("unhide_pause")

func _on_check_button_toggled(toggled_on):
	if !toggled_on:
		debug_settings.set_tab_hidden(2, true)
	else:
		debug_settings.set_tab_hidden(2, false)
	Global.debug = toggled_on
	ConfigFileHandler.save_debug("enable", toggled_on)

func _on_h_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("walk_speed", walk_speed_slider.value)
func _on_walk_speed_slider_value_changed(value):
	walk_speed_value.text = str(walk_speed_slider.value)
	
func _on_crouch_speed_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("crouch_speed", crouch_speed_slider.value)
func _on_crouch_speed_slider_value_changed(value):
	crouch_speed_value.text = str(crouch_speed_slider.value)

func _on_run_speed_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug('run_speed', run_speed_slider.value)
func _on_run_speed_slider_value_changed(value):
	run_speed_value.text = str(run_speed_slider.value)

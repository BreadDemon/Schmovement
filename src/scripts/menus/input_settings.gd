extends Control

@onready var input_button_scene = preload('res://nodes/menus/input_button.tscn')
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Keybinds/MarginContainer/VBoxContainer/ScrollContainer/ActionList

#Settings
@onready var enable_debug_stats = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/EnableDebug/Enable_debug_stats
@onready var run_name_button = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/SpeedrunTimer/RunName/RunNameButton
@onready var splits_button = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/SpeedrunTimer/Splits/SplitsButton
@onready var stats_button = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/SpeedrunTimer/Stats/StatsButton
@onready var personal_best_button = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/SpeedrunTimer/PB/PersonalBestButton

# DEBUG STUFF 
@onready var debug_check = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/EnableDebug/Enable_debug

@onready var debug_settings = $PanelContainer/MarginContainer/VBoxContainer/TabContainer

## Speed Variables
@onready var walk_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/WalkSpeedHbox/walk_speed_slider
@onready var walk_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/WalkSpeedHbox/WalkSpeedValue
@onready var crouch_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CrouchSpeedHbox/crouch_speed_slider
@onready var crouch_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CrouchSpeedHbox/CrouchSpeedValue
@onready var run_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RunSpeedHbox/run_speed_slider
@onready var run_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RunSpeedHbox/RunSpeedValue
@onready var enable_air_penalty = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/EnableAirPenalty
@onready var always_run = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/SpeedrunTimer/Ancor/AlwaysRun

@onready var sensitivity_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/Sensitivity/SensitivitySlider
@onready var sensitivity_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Settings/MarginContainer/Settings/Sensitivity/SensitivityValue

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
	"Reset": "Reset",
	"Return": "Return to Spawn",
	"LastCheckpoint": "Return to Checkpoint",
	"ToggleTimer": "Toggle Timer"
}

func _ready():
	player = get_parent().get_parent()
	_load_keybindings_from_settings()
	_create_action_list()
	if !Global.debug:
		debug_settings.set_tab_hidden(2, true)
	else:
		debug_check.button_pressed = true
	
	_load_settings_from_file()
	
	
	var debug_load = ConfigFileHandler.load_settings()
	debug_check.button_pressed = debug_load.enable

func _load_settings_from_file():
	var settings_load = ConfigFileHandler.load_settings()
	sensitivity_slider.value = settings_load.sensitivity
	run_name_button.button_pressed = settings_load.enable_run_name
	splits_button.button_pressed = settings_load.enable_splits
	stats_button.button_pressed = settings_load.enable_stats
	personal_best_button.button_pressed = settings_load.enable_personal_best
	enable_debug_stats.button_pressed = settings_load.enable_debug_stats
	always_run.button_pressed = settings_load.always_run
	
	load_debug_from_file()
	
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
		var pause = get_parent()
		animator.play("close_ingame")
		pause.animator.play("unhide_pause")

func _on_check_button_toggled(toggled_on):
	if ingame:
		if !player.timer.running:
			if !toggled_on:
				debug_settings.set_tab_hidden(2, true)
			else:
				debug_settings.set_tab_hidden(2, false)
			Global.debug = toggled_on
			ConfigFileHandler.save_settings("enable", toggled_on)
	else:
		if !toggled_on:
			debug_settings.set_tab_hidden(2, true)
		else:
			debug_settings.set_tab_hidden(2, false)
		Global.debug = toggled_on
		ConfigFileHandler.save_settings("enable", toggled_on)
		
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

func _on_sensitivity_slider_drag_ended(value_changed):
	if value_changed:
		if ingame:	
			player.sensitivity = sensitivity_slider.value
		ConfigFileHandler.save_settings("sensitivity", sensitivity_slider.value)
func _on_sensitivity_slider_value_changed(value):
	sensitivity_value.text = str(sensitivity_slider.value)
	
func _on_run_name_button_toggled(toggled_on):
	ConfigFileHandler.save_settings("enable_run_name", toggled_on)
	if (!toggled_on || toggled_on) and ingame:
		player.timer.switch_name(toggled_on)

func _on_splits_button_toggled(toggled_on):
	ConfigFileHandler.save_settings("enable_splits", toggled_on)
	if (!toggled_on || toggled_on) and ingame:
		player.timer.switch_splits(toggled_on)

func _on_stats_button_toggled(toggled_on):
	ConfigFileHandler.save_settings("enable_stats", toggled_on)
	if (!toggled_on || toggled_on) and ingame:
		player.timer.switch_stats(toggled_on)

func _on_personal_best_button_toggled(toggled_on):
	ConfigFileHandler.save_settings("enable_personal_best", toggled_on)
	if (!toggled_on || toggled_on) and ingame:
		player.timer.switch_pb(toggled_on)

func _on_enable_debug_stats_toggled(toggled_on):
	ConfigFileHandler.save_settings("enable_debug_stats", toggled_on)
	if ingame:
		player.debug.visible = toggled_on

func _on_always_run_toggled(toggled_on):
	ConfigFileHandler.save_settings("always_run", toggled_on)
	if ingame:
		player.always_run = toggled_on

func _on_enable_air_speed_penalty_toggled(toggled_on):
	ConfigFileHandler.save_debug("air_speed_penalty", toggled_on)
	
func _on_air_penalty_offset_toggled(toggled_on):
	ConfigFileHandler.save_debug("air_penalty_offset", toggled_on)

func _on_use_jump_buffer_for_wall_jump_toggled(toggled_on):
	ConfigFileHandler.save_debug("use_jbuff", toggled_on)

@onready var air_speed_penalty_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/AirSpeedPenaltyAmountHbox/air_speed_penalty_slider
@onready var air_speed_penalty_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/AirSpeedPenaltyAmountHbox/AirSpeedPenaltyValue
func _on_air_speed_penalty_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("air_speed_penalty_amount", air_speed_penalty_slider.value)
func _on_air_speed_penalty_slider_value_changed(value):
	air_speed_penalty_value.text = str(air_speed_penalty_slider.value)

@onready var gravity_force_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/GravityForce/GravityForceSlider
@onready var gravity_force_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/GravityForce/GravityForceValue
func _on_gravity_force_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("gravity_force", gravity_force_slider.value)
func _on_gravity_force_slider_value_changed(value):
	gravity_force_value.text = str(gravity_force_slider.value)

@onready var air_move_penalty_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/AirMovePenalty/AirMovePenaltySlider
@onready var air_move_penalty_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/AirMovePenalty/AirMovePenaltyValue
func _on_air_move_penalty_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("air_move_penalty", air_move_penalty_slider.value)
func _on_air_move_penalty_slider_value_changed(value):
	air_move_penalty_value.text = str(air_move_penalty_slider.value)

@onready var jump_velocity_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/JumpVelocity/JumpVelocitySlider
@onready var jump_velocity_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/JumpVelocity/JumpVelocityValue
func _on_jump_velocity_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("jump_velocity", jump_velocity_slider.value)
func _on_jump_velocity_slider_value_changed(value):
	jump_velocity_value.text = str(jump_velocity_slider.value)

@onready var coyote_timer_max_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CoyoteTimerMax/CoyoteTimerMaxSlider
@onready var coyote_timer_max_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CoyoteTimerMax/CoyoteTimerMaxValue
func _on_coyote_timer_max_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("coyote_timer", coyote_timer_max_slider.value)
func _on_coyote_timer_max_slider_value_changed(value):
	coyote_timer_max_value.text = str(coyote_timer_max_slider.value)

@onready var jump_buffer_timer_max_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/JumpBufferTimerMax/JumpBufferTimerMaxSlider
@onready var jump_buffer_timer_max_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/JumpBufferTimerMax/JumpBufferTimerMaxValue
func _on_jump_buffer_timer_max_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("jump_buffer_timer", jump_buffer_timer_max_slider.value)
func _on_jump_buffer_timer_max_slider_value_changed(value):
	jump_buffer_timer_max_value.text = str(jump_buffer_timer_max_slider.value)

@onready var wall_jump_timer_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/WallJumpTimer/WallJumpTimerSlider
@onready var wall_jump_timer_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/WallJumpTimer/WallJumpTimerValue
func _on_wall_jump_timer_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("wall_jump_timer", wall_jump_timer_slider.value)
func _on_wall_jump_timer_slider_value_changed(value):
	wall_jump_timer_value.text = str(wall_jump_timer_slider.value)

@onready var jump_again_timer_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/JumpAgainTimer/JumpAgainTimerSlider
@onready var jump_again_timer_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/JumpAgainTimer/JumpAgainTimerValue
func _on_jump_again_timer_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("jump_again_timer", jump_again_timer_slider.value)
func _on_jump_again_timer_slider_value_changed(value):
	jump_again_timer_value.text = str(jump_again_timer_slider.value)

@onready var speed_lerp_factor_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/SpeedLerpFactor/SpeedLerpFactorSlider
@onready var speed_lerp_factor_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/SpeedLerpFactor/SpeedLerpFactorValue
func _on_speed_lerp_factor_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("speed_lerp_factor", speed_lerp_factor_slider.value)
func _on_speed_lerp_factor_slider_value_changed(value):
	speed_lerp_factor_value.text = str(speed_lerp_factor_slider.value)

@onready var crouch_lerp_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CrouchLerpSpeed/CrouchLerpSpeedSlider
@onready var crouch_lerp_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/CrouchLerpSpeed/CrouchLerpSpeedValue
func _on_crouch_lerp_speed_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("crouch_lerp_factor", crouch_lerp_speed_slider.value)
func _on_crouch_lerp_speed_slider_value_changed(value):
	crouch_lerp_speed_value.text = str(crouch_lerp_speed_slider.value)

@onready var slide_timer_max_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/SlideTimerMax/SlideTimerMaxSlider
@onready var slide_timer_max_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/SlideTimerMax/SlideTimerMaxValue
func _on_slide_timer_max_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("slide_timer", slide_timer_max_slider.value)
func _on_slide_timer_max_slider_value_changed(value):
	slide_timer_max_value.text = str(slide_timer_max_slider.value)

@onready var slide_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/SlideSpeed/SlideSpeedSlider
@onready var slide_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/SlideSpeed/SlideSpeedValue
func _on_slide_speed_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("slide_speed", slide_speed_slider.value)
func _on_slide_speed_slider_value_changed(value):
	slide_speed_value.text = str(slide_speed_slider.value)

@onready var ramp_down_look_angle_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RampDownLookAngle/RampDownLookAngleSlider
@onready var ramp_down_look_angle_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RampDownLookAngle/RampDownLookAngleValue
func _on_ramp_down_look_angle_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("ramp_look_angle", ramp_down_look_angle_slider.value)
func _on_ramp_down_look_angle_slider_value_changed(value):
	ramp_down_look_angle_value.text = str(ramp_down_look_angle_slider.value)

@onready var ramp_modifier_base_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RampModifierBase/RampModifierBaseSlider
@onready var ramp_modifier_base_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/RampModifierBase/RampModifierBaseValue
func _on_ramp_modifier_base_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("ramp_modifier_base", ramp_modifier_base_slider.value)
func _on_ramp_modifier_base_slider_value_changed(value):
	ramp_modifier_base_value.text = str(ramp_modifier_base_slider.value)

@onready var headbob_sprint_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobSprintSpeed/HeadbobSprintSpeedSlider
@onready var headbob_sprint_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobSprintSpeed/HeadbobSprintSpeedValue
func _on_headbob_sprint_speed_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("hb_sprint_speed", headbob_sprint_speed_slider.value)
func _on_headbob_sprint_speed_slider_value_changed(value):
	headbob_sprint_speed_value.text = str(headbob_sprint_speed_slider.value)

@onready var headbob_sprint_intensity_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobSprintIntensity/HeadbobSprintIntensitySlider
@onready var headbob_sprint_intensity_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobSprintIntensity/HeadbobSprintIntensityValue
func _on_headbob_sprint_intensity_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("hb_sprint_intensity", headbob_sprint_intensity_slider.value)
func _on_headbob_sprint_intensity_slider_value_changed(value):
	headbob_sprint_intensity_value.text = str(headbob_sprint_intensity_slider.value)

@onready var headbob_walk_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobWalkSpeed/HeadbobWalkSpeedSlider
@onready var headbob_walk_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobWalkSpeed/HeadbobWalkSpeedValue
func _on_headbob_walk_speed_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("hb_walk_speed", headbob_walk_speed_slider.value)
func _on_headbob_walk_speed_slider_changed():
	headbob_walk_speed_value.text = str(headbob_walk_speed_slider.value)

@onready var headbob_walk_intensity_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobWalkIntensity/HeadbobWalkIntensitySlider
@onready var headbob_walk_intensity_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobWalkIntensity/HeadbobWalkIntensityValue
func _on_headbob_walk_intensity_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("hb_walk_intensity", headbob_walk_intensity_slider.value)
func _on_headbob_walk_intensity_slider_value_changed(value):
	headbob_walk_intensity_value.text = str(headbob_walk_intensity_slider.value)

@onready var headbob_crouch_speed_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobCrouchSpeed/HeadbobCrouchSpeedSlider
@onready var headbob_crouch_speed_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobCrouchSpeed/HeadbobCrouchSpeedValue
func _on_headbob_crouch_speed_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("hb_crouch_speed", headbob_crouch_speed_slider.value)
func _on_headbob_crouch_speed_slider_value_changed(value):
	headbob_crouch_speed_value.text = str(headbob_crouch_speed_slider.value)

@onready var headbob_crouch_intensity_slider = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobCrouchIntensity/HeadbobCrouchIntensitySlider
@onready var headbob_crouch_intensity_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/HeadbobCrouchIntensity/HeadbobCrouchIntensityValue
func _on_headbob_crouch_intensity_slider_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_debug("hb_crouch_intensity", headbob_crouch_intensity_slider.value)
func _on_headbob_crouch_intensity_slider_value_changed(value):
	headbob_crouch_intensity_value.text = str(headbob_crouch_intensity_slider.value)

@onready var enable_air_speed_penalty = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/EnableAirSpeedPenalty
@onready var air_penalty_offset = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/AirPenaltyOffset
@onready var use_jump_buffer_for_wall_jump = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Debug/MarginContainer/DebugSettings/ScrollContainer/VBoxContainer/UseJumpBufferForWallJump


func load_debug_from_file():
	var enabled_debug = ConfigFileHandler.load_settings()
	var debug_load = ConfigFileHandler.load_debug(enabled_debug.enable)
	air_penalty_offset.button_pressed = debug_load.air_penalty_offset
	enable_air_speed_penalty.button_pressed = debug_load.air_speed_penalty
	gravity_force_slider.value = debug_load.gravity_force
	air_move_penalty_slider.value = debug_load.air_move_penalty
	jump_velocity_slider.value = debug_load.jump_velocity
	coyote_timer_max_slider.value = debug_load.coyote_timer
	jump_buffer_timer_max_slider.value = debug_load.jump_buffer_timer
	wall_jump_timer_slider.value = debug_load.wall_jump_timer
	jump_again_timer_slider.value = debug_load.jump_again_timer
	crouch_speed_slider.value = debug_load.crouch_speed
	walk_speed_slider.value = debug_load.walk_speed
	run_speed_slider.value = debug_load.run_speed
	air_speed_penalty_slider.value = debug_load.air_speed_penalty_amount
	speed_lerp_factor_slider.value = debug_load.speed_lerp_factor
	crouch_lerp_speed_slider.value = debug_load.crouch_lerp_factor
	slide_timer_max_slider.value = debug_load.slide_timer
	slide_speed_slider.value = debug_load.slide_speed
	ramp_down_look_angle_slider.value = debug_load.ramp_look_angle
	ramp_modifier_base_slider.value = debug_load.ramp_modifier_base
	headbob_crouch_speed_slider.value = debug_load.hb_crouch_speed
	headbob_crouch_intensity_slider.value = debug_load.hb_crouch_intensity
	headbob_sprint_speed_slider.value = debug_load.hb_sprint_speed
	headbob_sprint_intensity_slider.value = debug_load.hb_sprint_intensity
	headbob_walk_speed_slider.value = debug_load.hb_walk_speed
	headbob_walk_intensity_slider.value = debug_load.hb_walk_intensity
	use_jump_buffer_for_wall_jump.button_pressed = debug_load.use_jbuff

func _on_reset_defaults_pressed():
	ConfigFileHandler.reset_debug()
	load_debug_from_file()



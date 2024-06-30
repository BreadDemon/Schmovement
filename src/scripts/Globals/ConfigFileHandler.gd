extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.save"

var configruns = ConfigFile.new()
const RUNS_FILE_PATH = "user://runs.save"

var config_debug_default = ConfigFile.new()
const DEBUG_DEFAULT_FILE_PATH = "user://debug_default.save"

var config_version = ConfigFile.new()
const VERSION_PATH = "user://version_setting.save"

func _ready():
	
	if !FileAccess.file_exists(VERSION_PATH):
		config_version.set_value("version", "version", Global.game_version)
		write_settings()
		
		config_version.save(VERSION_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
		var version = config_version.get_value("version", "version")
		if version != Global.game_version:
			write_settings()
			
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		write_settings()		
	else:
		config.load(SETTINGS_FILE_PATH)
	
	if FileAccess.file_exists(RUNS_FILE_PATH):
		configruns.load(RUNS_FILE_PATH)
		
	if !FileAccess.file_exists(DEBUG_DEFAULT_FILE_PATH):
		config_debug_default.set_value("debug", "walk_speed", 5.0)
		config_debug_default.set_value("debug", "crouch_speed", 3.0)
		config_debug_default.set_value("debug", "run_speed", 7.0)
		config_debug_default.set_value("debug", "air_speed_penalty", false)
		config_debug_default.set_value("debug", "gravity_force", 1.0)
		config_debug_default.set_value("debug", "air_penalty_offset", false)
		config_debug_default.set_value("debug", "air_move_penalty", 1.0)
		config_debug_default.set_value("debug", "jump_velocity", 4.6)
		config_debug_default.set_value("debug", "coyote_timer", 0.2)
		config_debug_default.set_value("debug", "jump_buffer_timer", 0.2)
		config_debug_default.set_value("debug", "wall_jump_timer", 0.21)
		config_debug_default.set_value("debug", "speed_lerp_factor", 2.0)
		config_debug_default.set_value("debug", "crouch_lerp_factor", 3.0)
		config_debug_default.set_value("debug", "slide_timer", 1.0)
		config_debug_default.set_value("debug", "slide_speed", 5.0)
		config_debug_default.set_value("debug", "ramp_look_angle", 15.0)
		config_debug_default.set_value("debug", "ramp_modifier_base", 0.5)
		config_debug_default.set_value("debug", "hb_sprint_speed", 22.0)
		config_debug_default.set_value("debug", "hb_sprint_intensity", 0.4)
		config_debug_default.set_value("debug", "hb_walk_intensity", 0.2)
		config_debug_default.set_value("debug", "hb_walk_speed", 14.0)
		config_debug_default.set_value("debug", "hb_crouch_speed", 10.0)
		config_debug_default.set_value("debug", "hb_crouch_intensity", 0.1)
		config_debug_default.set_value("debug", "jump_again_timer", 0.3)
		config_debug_default.set_value("debug", "air_speed_penalty_amount", 0.9)
		config_debug_default.set_value("debug", "use_jbuff", true)
		
		config_debug_default.save(DEBUG_DEFAULT_FILE_PATH)
	else:
		config_debug_default.load(DEBUG_DEFAULT_FILE_PATH)

func write_settings():
	config.set_value("Keybinding","forward", "W")
	config.set_value("Keybinding","back", "S")
	config.set_value("Keybinding","left", "A")
	config.set_value("Keybinding","right", "D")
	config.set_value("Keybinding","Sprint", "Shift")
	config.set_value("Keybinding","Crouch", "Ctrl")
	config.set_value("Keybinding","Jump", "Space")
	config.set_value("Keybinding","Reset", "R")
	config.set_value("Keybinding","Return", "Delete")
	config.set_value("Keybinding","LastCheckpoint", "Backspace")
	config.set_value("Keybinding","ToggleTimer", "T")
	
	config.set_value("Last_scene","path", "res://nodes/levels/Tutorial.tscn")		
	
	config.set_value("debug", "walk_speed", 5.0)
	config.set_value("debug", "crouch_speed", 3.0)
	config.set_value("debug", "run_speed", 7.0)
	config.set_value("debug", "air_speed_penalty", false)
	config.set_value("debug", "gravity_force", 1.0)
	config.set_value("debug", "air_penalty_offset", false)
	config.set_value("debug", "air_move_penalty", 1.0)
	config.set_value("debug", "jump_velocity", 4.6)
	config.set_value("debug", "coyote_timer", 0.2)
	config.set_value("debug", "jump_buffer_timer", 0.2)
	config.set_value("debug", "wall_jump_timer", 0.21)
	config.set_value("debug", "speed_lerp_factor", 2.0)
	config.set_value("debug", "crouch_lerp_factor", 3.0)
	config.set_value("debug", "slide_timer", 1.0)
	config.set_value("debug", "slide_speed", 5.0)
	config.set_value("debug", "ramp_look_angle", 15.0)
	config.set_value("debug", "ramp_modifier_base", 0.5)
	config.set_value("debug", "hb_sprint_speed", 22.0)
	config.set_value("debug", "hb_sprint_intensity", 0.4)
	config.set_value("debug", "hb_walk_intensity", 0.2)
	config.set_value("debug", "hb_walk_speed", 14.0)
	config.set_value("debug", "hb_crouch_speed", 10.0)
	config.set_value("debug", "hb_crouch_intensity", 0.1)
	config.set_value("debug", "jump_again_timer", 0.3)
	config.set_value("debug", "air_speed_penalty_amount", 0.9)
	config.set_value("debug", "use_jbuff", true)
	
	config.set_value("Settings", "enable", false)
	config.set_value("Settings", "sensitivity", 0.1)
	config.set_value("Settings", "enable_run_name", true)
	config.set_value("Settings", "enable_splits", true)
	config.set_value("Settings", "enable_stats", true)
	config.set_value("Settings", "enable_personal_best", true)
	config.set_value("Settings", "enable_debug_stats", false)
	
	config.save(SETTINGS_FILE_PATH)
		
func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("Keybinding", action, event_str)
	config.save(SETTINGS_FILE_PATH)
	
func save_settings(section_name: StringName, value):
	config.set_value("Settings", section_name, value)
	config.save(SETTINGS_FILE_PATH)

func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("Keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("Keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybindings[key] = input_event
	return keybindings
	
func load_settings():
	var settings_value = {}
	var settings = config.get_section_keys("Settings")
	for key in settings:
		settings_value[key] = config.get_value("Settings", key)
	return settings_value
	
func save_scene(scene: StringName):
	config.set_value("Last_scene", "path", scene)
	config.save(SETTINGS_FILE_PATH)

func retrieve_last_scene() -> String:
	var last_scene: String = config.get_value("Last_scene", "path")
	if !last_scene.is_empty():
		return last_scene
	return ""
	
func save_runs(run_name: StringName, personal_best: float):
	configruns.set_value("RunName", run_name, personal_best)
	configruns.save(RUNS_FILE_PATH)

func save_attempts(run_name: StringName, attempts: int):
	configruns.set_value("RunAttempts", run_name, attempts)
	configruns.save(RUNS_FILE_PATH)
	
func load_runs(runs):
	var run_names = configruns.get_section_keys("RunName")
	for run_name in run_names:
		if runs.run_name == run_name:
			runs.PB = configruns.get_value("RunName", run_name)
	var run_attemps = configruns.get_section_keys("RunAttempts")
	for run_name in run_attemps:
		if runs.run_name == run_name:
			runs.attempts = configruns.get_value("RunAttempts", run_name)

func save_debug(config_name: String, value):
	config.set_value("debug", config_name, value)
	config.save(SETTINGS_FILE_PATH)

func load_debug(debug: bool):
	var debug_settings = {}
	if debug:
		for key in config.get_section_keys("debug"):
			debug_settings[key] = config.get_value("debug", key)
	else:
		for key in config_debug_default.get_section_keys("debug"):
			debug_settings[key] = config_debug_default.get_value("debug", key)
	return debug_settings

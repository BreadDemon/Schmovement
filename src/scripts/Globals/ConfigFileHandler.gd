extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.save"
var configruns = ConfigFile.new()
const RUNS_FILE_PATH = "user://runs.save"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("Keybinding","forward", "W")
		config.set_value("Keybinding","back", "S")
		config.set_value("Keybinding","left", "A")
		config.set_value("Keybinding","right", "D")
		config.set_value("Keybinding","Sprint", "Shift")
		config.set_value("Keybinding","Crouch", "Ctrl")
		config.set_value("Keybinding","Jump", "Space")
		config.set_value("Keybinding","Reset", "R")		
		
		config.set_value("Last_scene","path", "res://nodes/levels/Tutorial.tscn")		
		
		config.set_value("debug", "enable", false)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	
	if FileAccess.file_exists(RUNS_FILE_PATH):
		configruns.load(RUNS_FILE_PATH)
		
		
func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("Keybinding", action, event_str)
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
	
func load_runs(runs):
	var run_names = configruns.get_section_keys("RunName")
	for run_name in run_names:
		if runs.run_name == run_name:
			runs.PB = configruns.get_value("RunName", run_name)

func save_debug(config_name: String, state):
	pass

func load_debug(config_name):
	pass

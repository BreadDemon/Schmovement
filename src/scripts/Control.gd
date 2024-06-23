extends Control

@onready var Play = $CenterContainer/MarginContainer/VBoxContainer/Play
@onready var Settings = $CenterContainer/MarginContainer/VBoxContainer/SettingButton
@onready var Exit = $CenterContainer/MarginContainer/VBoxContainer/Exit

func _ready():
	Play.button_down.connect(_on_PlayButton_pressed)
	Settings.button_down.connect(_on_SettingsButton_pressed)
	Exit.button_down.connect(_on_ExitButton_pressed)
	
func _on_PlayButton_pressed():
	# Transition to the game scene
	get_tree().change_scene_to_file("res://nodes/levels/playground.tscn")

func _on_SettingsButton_pressed():
	# Quit the game
	get_tree().change_scene_to_file("res://nodes/menus/input_settings.tscn")
	
func _on_ExitButton_pressed():
	# Quit the game
	get_tree().quit()

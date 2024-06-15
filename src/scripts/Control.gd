extends Control

func _ready():
	var Play = $Play
	Play.button_down.connect(_on_PlayButton_pressed)
	var Exit = $Exit
	Exit.button_down.connect(_on_ExitButton_pressed)
	
func _on_PlayButton_pressed():
	# Transition to the game scene
	get_tree().change_scene_to_file("res://nodes/playgroung.tscn")

func _on_ExitButton_pressed():
	# Quit the game
	get_tree().quit()

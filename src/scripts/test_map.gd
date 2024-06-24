extends Node3D

var path = "res://nodes/levels/test_map.tscn"

func _ready():
	ConfigFileHandler.save_scene(path)

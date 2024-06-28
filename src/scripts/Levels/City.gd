extends Node3D

var path = "res://nodes/levels/City.tscn"

func _ready():
	ConfigFileHandler.save_scene(path)


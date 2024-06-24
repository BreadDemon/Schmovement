extends Node3D

var path = "res://nodes/levels/playground.tscn"

func _ready():
	ConfigFileHandler.save_scene(path)

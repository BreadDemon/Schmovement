extends Node3D

var path = "res://nodes/levels/Tutorial.tscn"

func _ready():
	Global.coming_from = "Tutorial"
	ConfigFileHandler.save_scene(path)
	Global.origin_point = Vector3(0,3,0)

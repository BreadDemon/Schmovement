extends Node3D
class_name LoadZone

@export var PathScene: String

func _on_character_body_3d_loadzone():
	assert(PathScene != null, "Path Cannot be null")
	get_tree().change_scene_to_file(PathScene)

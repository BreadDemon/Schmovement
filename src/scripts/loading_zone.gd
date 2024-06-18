extends Node3D
class_name LoadZone

@export var PathScene: String

func _on_body_entered(body):
	if body is Player:
		get_tree().change_scene_to_file(PathScene)

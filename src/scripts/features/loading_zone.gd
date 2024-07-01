extends Node3D
class_name LoadZone

@export var PathScene: String
@export var coming_from: String

func _on_body_entered(body):
	if body is Player:
		Global.coming_from = coming_from
		get_tree().change_scene_to_file(PathScene)

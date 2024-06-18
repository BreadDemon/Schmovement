extends Node3D
class_name Teleporter

@export var receptor: Receptor

func _on_body_entered(body):
	if body is Player:
		body.transform.origin = receptor.transform.origin

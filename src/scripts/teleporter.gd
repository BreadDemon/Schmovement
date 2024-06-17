extends Node3D
class_name Teleporter

@export var receptor: Receptor

func _on_character_body_3d_teleport(player, teleporter):
	var result = teleporter.get_parent().receptor
	player.transform.origin = result.transform.origin
	print("Teleported!!!!")

extends Area3D

var had_wj

func _on_body_entered(body):
	if body is Player:
		body.has_wall_jump = true


func _on_body_exited(body):
	if body is Player:
		body.has_wall_jump = true

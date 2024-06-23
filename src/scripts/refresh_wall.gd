extends Area3D

var had_wj

func _on_body_entered(body):
	if body is Player:
		print("Entered")
		had_wj = body.can_wall_jump


func _on_body_exited(body):
	if body is Player:
		print("Left")
		if had_wj and !body.can_wall_jump:
			body.can_wall_jump = true

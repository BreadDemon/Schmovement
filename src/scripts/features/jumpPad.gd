extends Area3D

@export var power = 10
@export var angled = false

func _on_body_entered(body):
	if body is Player:
		body.velocity.y = power
		body.has_wall_jump = true

extends Area3D

@export var power = 10

func _on_body_entered(body):
	if body is Player:
		body.velocity.y = power
		var new_speed = clamp(body.current_speed + 2.0, body.current_speed, body.sprinting_speed)
		body.sliding_state = false

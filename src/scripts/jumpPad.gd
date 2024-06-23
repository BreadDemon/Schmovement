extends Area3D

@export var power = 10
@export var angled = false

func _on_body_entered(body):
	if body is Player:
		body.velocity.y = power
		body.sliding_state = false
		body.spam_state = false
		body.can_wall_jump = true
		body.spam_timer = 0

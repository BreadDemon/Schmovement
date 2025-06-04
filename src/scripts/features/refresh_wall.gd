extends Area3D

var player: Player = null
var had_wall_jump: bool = false
var gave_wall_jump: bool = false

func _process(_delta):
	if player != null:
		if player.has_wall_jump:
			had_wall_jump = true
	
	if had_wall_jump and !player.has_wall_jump and !gave_wall_jump:
		player.has_wall_jump = true
		gave_wall_jump = true

func _on_body_entered(body):
	if body is Player:
		player = body

func _on_body_exited(body):
	if body is Player:
		player = null
		gave_wall_jump = false
		had_wall_jump = false

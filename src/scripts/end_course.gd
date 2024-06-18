extends Node3D
class_name EndCourse


func _on_body_entered(body):
	if body is Player:
		var timer = body.get_node("Neck/Camera3D/PanelContainer/Timer")
		timer.running = false

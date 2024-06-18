extends Node3D
class_name StartCourse

@export var end_course: EndCourse

func _on_body_entered(body):
	if body is Player:
		var timer = body.get_node("Neck/Camera3D/PanelContainer/Timer")
		timer.running = true

extends Node3D
class_name StartCourse

func _on_body_entered(body):
	if body is Player:
		Global.start_time = str(0.0)
		var timer = body.get_node("Neck/Timer").get_child(0).get_child(0)
		timer.reset()
		timer.running = true

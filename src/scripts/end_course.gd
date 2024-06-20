extends Node3D
class_name EndCourse

@export var start_course: StartCourse

func _on_body_entered(body):
	if body is Player and Global.start_course == start_course:
		var timer = body.get_node("Timer").get_child(0).get_child(0)
		timer.running = false

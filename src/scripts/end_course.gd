extends Node3D
class_name EndCourse

@export var start_course: StartCourse

func _on_body_entered(body):
	if body is Player and Global.start_course == start_course:
		var timer = body.get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
		timer.running = false
		if !start_course.has_calculated:
			timer.set_pb()
			start_course.has_calculated = true

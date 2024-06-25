extends Node3D
class_name EndCourse

@export var start_course: StartCourse

func _on_body_entered(body):
	if body is Player and Global.start_course == start_course:
		var timer = body.get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
		var DevTime = timer.get_parent().get_node("DT").get_node("DevTime")
		timer.running = false
		if !start_course.has_calculated:
			timer.set_pb(start_course)
			start_course.has_calculated = true
		if float(start_course.pb) < start_course.dev_time and float(start_course.pb) != 0.0:
			DevTime.text = "Beaten!"

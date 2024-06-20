extends Node3D
class_name StartCourse

@export var origin_point: ReturnNode

func _on_body_entered(body):
	if body is Player:
		var timer = body.get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
		if !timer.running:
			self.monitorable = true
			self.monitoring = true
			timer.reset_timer()
			Global.start_time = str(0.0)
			Global.start_course = self
			Global.origin_point = origin_point.transform.origin
			timer.running = true
		else:
			self.monitorable = false
			self.monitoring = false

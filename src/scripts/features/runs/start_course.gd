extends Node3D
class_name StartCourse

@export var run_name = "None"
@export var origin_point: ReturnNode
var has_calculated

# Implementar texto mostrando se venceu do tempo dev 
@export var dev_time: float
var pb = 0.0

func _ready():
	#ConfigFileHandler.load_runs($".")
	pass
	
func _on_body_entered(body):
	ConfigFileHandler.load_runs($".")
	
	if body is Player:
		var timer = body.get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
		
		if !timer.running:
			Global.personal_best = pb
			var Name = timer.get_parent().get_node("Name")
			Name.text = run_name
			var Personal = timer.get_parent().get_node("times").get_node("PersonalBest")
			var DT = timer.get_parent().get_node("DT").get_node("time")
			var DevTime = timer.get_parent().get_node("DT").get_node("DevTime")
			var format = "%s%s"
			DT.text = format % ["DT: ", str(dev_time)]
			if float(pb) > dev_time or float(pb) == 0.0:
				DevTime.text = ""
			Personal.text = str(pb)
			has_calculated = false
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

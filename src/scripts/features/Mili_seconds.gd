extends Label
class_name GameTimer

var start_time = Global.start_time
@export var running: bool = false

var result_diff

func _physics_process(delta):
	if running:
		start_time = start_time + delta
		update()

func update():
	if running:
		var format = "%.3f"
		format = format % start_time
		
		Global.start_time = format
		text = format.replace(".", ":")
		if start_time < float(Global.pb) || float(Global.pb) == 0.0:
			add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			add_theme_color_override("font_color", Color(1, 0, 0))

func reset_timer():
	start_time = 0.0
	Global.start_time = start_time
	update()
	running = false

#TODO: make the save again, make it save floats
func set_pb(start_course):
	if float(Global.pb) == 0.0:
		var personal_best = get_parent().get_node("times").get_node("PersonalBest")
		Global.pb = Global.start_time
		personal_best.text = str(Global.pb)
		start_course.PB = float(Global.start_time)
		ConfigFileHandler.save_runs(start_course.run_name, str(start_course.PB))
		return
		
	if float(Global.pb) != 0:
		var diff = get_parent().get_node("times").get_node("Diff")
		var format = "%s%.3f"
		result_diff = start_time - float(Global.pb)
		if Global.start_time > Global.pb:
			diff.text = format % ["+", result_diff]
			diff.add_theme_color_override("font_color", Color(1, 0, 0))
		else:
			diff.text = format % ["", result_diff]
			diff.add_theme_color_override("font_color", Color(0, 0.65, 0.075))

	if float(Global.pb) > float(Global.start_time) || float(Global.pb) == 0:
		var personal_best = get_parent().get_node("times").get_node("PersonalBest")
		Global.pb = Global.start_time
		personal_best.text = str(Global.pb)
		start_course.PB = float(Global.start_time)
		ConfigFileHandler.save_runs(start_course.run_name, str(start_course.PB))

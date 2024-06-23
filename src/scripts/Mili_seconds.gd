extends Label

var start_time = Global.start_time
@export var running: bool = false

var result_diff

func _physics_process(delta):
	if running:
		start_time = float(start_time) + delta
		update()

func update():
	if running:
		var formatted_time = str(start_time+0.000)
		var decimal_index = formatted_time.find(".")
		if decimal_index > 0:
			formatted_time = formatted_time.left(decimal_index + 4)  # Take only three decimal places
		
		Global.start_time = formatted_time
		text = formatted_time.replace(".", ":")
		if start_time < float(Global.personal_best) || float(Global.personal_best) == 0.0:
			add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			add_theme_color_override("font_color", Color(1, 0, 0))

func reset_timer():
	start_time = 0.0
	Global.start_time = str(start_time)
	update()
	running = false

func set_pb(start_course):
	if float(Global.start_time) == 0.0:
		print("Failed PB setting somehow")
		return
		
	if float(Global.personal_best) != 0:
		var diff = get_parent().get_node("times").get_node("Diff")
		var format = "%s%.3f"
		result_diff = start_time - float(Global.personal_best)
		if Global.start_time > Global.personal_best:
			diff.text = format % ["+", result_diff]
			diff.add_theme_color_override("font_color", Color(1, 0, 0))
		else:
			diff.text = format % ["", result_diff]
			diff.add_theme_color_override("font_color", Color(0, 0.65, 0.075))

	if float(Global.personal_best) > float(Global.start_time) || float(Global.personal_best) == 0:
		var personal_best = get_parent().get_node("times").get_node("PersonalBest")
		Global.personal_best = Global.start_time
		personal_best.text = Global.personal_best
		start_course.pb = Global.start_time

extends CanvasLayer
class_name TimerV2

var start_time = Global.time
@export var running: bool = false

@onready var clock = $Panel/Container/Clock
@onready var timer_name = $Panel/Container/Name_Attempts
@onready var checkpoint_section = $Panel/Container/Checkpoint
@onready var stats = $Panel/Container/Diff_PB
@onready var pb_stat = $Panel/Container/DT

var result_diff

func switch_timer():
	visible = !visible

func switch_name(state: bool):
	timer_name.visible = state

func switch_clock():
	clock.visible = !clock.visible
	
func switch_splits(state: bool):
	checkpoint_section.visible = state
	
func switch_stats(state: bool):
	stats.visible = state
	
func switch_pb(state: bool):
	pb_stat.visible = state
	
func _physics_process(delta):
	if running:
		start_time = start_time + delta
		update()

func update():
	if running:
		var format = "%.3f"
		format = format % start_time
		
		Global.time = format
		clock.text = format.replace(".", ":")
		if start_time < float(Global.pb) || float(Global.pb) == 0.0:
			clock.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			clock.add_theme_color_override("font_color", Color(1, 0, 0))

func reset_timer():
	start_time = 0.0
	Global.time = start_time
	update()
	running = false

#TODO: make the save again, make it save floats
func set_pb(start_course):
	if float(Global.pb) == 0.0:
		var personal_best = get_node("Panel/Container/DT/PersonalBest")
		Global.pb = Global.time
		personal_best.text = "PB: " + str(Global.pb)
		start_course.PB = float(Global.time)
		ConfigFileHandler.save_runs(start_course.run_name, start_course.PB)
		return
		
	if float(Global.pb) != 0:
		var diff = get_node("Panel/Container/Diff_PB/Diff")
		var format = "%s%.3f"
		result_diff = start_time - float(Global.pb)
		if Global.time > Global.pb:
			diff.text = format % ["+", result_diff]
			diff.add_theme_color_override("font_color", Color(1, 0, 0))
		else:
			diff.text = format % ["", result_diff]
			diff.add_theme_color_override("font_color", Color(0, 0.65, 0.075))

	if float(Global.pb) > float(Global.time) || float(Global.pb) == 0:
		var personal_best = get_node("Panel/Container/DT/PersonalBest")
		Global.pb = Global.time
		personal_best.text = "PB: " + str(Global.pb)
		start_course.PB = float(Global.time)
		ConfigFileHandler.save_runs(start_course.run_name, start_course.PB)

extends Label

var start_time = Global.start_time
@export var running: bool = false

func _physics_process(delta):
	if running:
		start_time = float(start_time) + delta
		update()

func update():
	if running:
		var formatted_time = str(start_time+0.000)
		var decimal_index = formatted_time.find(".")
		if decimal_index > 0:
			formatted_time = formatted_time.left(decimal_index + 4)  # Take only two decimal places
		
		Global.start_time = formatted_time
		text = formatted_time.replace(".", ":")

func reset_timer():
	start_time = 0.0
	Global.start_time = str(start_time)
	update()
	running = false

func set_pb():
	if float(Global.personal_best) < float(Global.start_time):
		var personal_best = get_parent().get_node("PersonalBest")
		Global.personal_best = Global.start_time
		personal_best.text = Global.personal_best

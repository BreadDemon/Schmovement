extends Label

var start_time: int
@export var running: bool = false

func _ready():
	if running:
		start_time = Time.get_ticks_msec()
		set_process(true)

func _process(delta):
	if running:
		var current_time: float = Time.get_ticks_msec() - start_time
		text = str(current_time/1000)

extends Area3D
class_name EndRunNodeV3

@onready var visual: MeshInstance3D = $MeshInstance3D
const RED = preload("res://assets/Textures/red.tres")

var start_node: StartRunNodeV3
var timer: TimerV2

func _ready():
	visual.set_material_override(RED)
	visible = false

func _on_body_entered(body):
	if body is Player:
		timer = body.get_node("TimerV2")
		if can_stop_run():
			timer.running = false
			update_ui()
			deactivate_run_state()

func can_stop_run() -> bool:
	return start_node == Global.RunStartV3 and timer.running and start_node.collected_all_checkpoints()

func update_ui() -> void:
	timer.set_pb(start_node)
	if start_node.PB < start_node.dev_time and start_node.PB != 0.0:
		if start_node.timer_ui_elements.timer_pb:
			start_node.timer_ui_elements.timer_pb.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow
	else:
		if start_node.timer_ui_elements.timer_pb:
			start_node.timer_ui_elements.timer_pb.add_theme_color_override("font_color", Color(0, 1, 0)) # Green

func deactivate_run_state() -> void:
	start_node.hide_my_checkpoints()
	start_node.reset_all_checkpoints()
	start_node.show_all_runs()
	start_node.start_run_buffer_timer = start_node.start_run_buffer_time_max
	self.visible = false
	start_node.visible = true
	Global.RunReturnPoint = start_node.global_position

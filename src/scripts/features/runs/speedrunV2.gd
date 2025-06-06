extends Area3D
class_name Speedrun

@export_category("Run Settings")
@export var run_name: String = "None"
@export var dev_time: float = 0.0
@export var restart_point: ReturnNode
@export var other_node: Speedrun
@export var checkpoints: Array[Checkpoint] = []
var start_timer: float = 0.0
@export var start_timer_max: float = 3.0
var last_collected_checkpoint: Checkpoint
var PB: float
var attempts: int
@export var show_end: bool = true

enum _type { START, END }
@export var node_type: _type

@onready var visual = $Visual
const RED = preload("res://assets/Textures/red.tres")

var timer: TimerV2
var container: VBoxContainer

var timer_run_name: Label
var timer_attempts: Label

var clock: Label

var checkpoint_diff: Label
var checkpoint_time: Label

var timer_diff: Label
var timer_pb: Label
var timer_dt: Label
var format = "%s%s"

func _ready():
	if node_type == _type.END:
		run_name = other_node.run_name
		visual.set_material_override(RED)
		visible = false
func _process(delta):
	start_timer -= delta
	if start_timer < -1.0:
		start_timer = 0.0
func get_vars(body):
	timer = body.get_node("TimerV2")
	container = timer.get_node("PanelContainer/Panel/Container")
	
	timer_run_name = container.get_node("Name_Attempts/Name")
	
	clock = container.get_node("Clock")
	
	checkpoint_diff = container.get_node("Checkpoint/Checkpoint_Diff")
	checkpoint_time = container.get_node("Checkpoint/Checkpoint_Time")
	
	timer_attempts = container.get_node("Diff_PB/Attempts")
	timer_diff = container.get_node("DT/Diff")
	timer_pb = container.get_node("DT/PersonalBest")
func set_vars():
	timer_run_name.text = run_name
	timer_pb.text = "PB: " + str(PB)
	timer.reset_timer()
	timer.running = true
func hide_other_runs():
	var runs = get_parent().get_parent().get_children()
	for run in runs:
		if run.get_node("start").run_name != run_name:
			run.get_node("start").visible = false
			run.get_node("end").visible = false
func show_other_runs():
	var runs = get_parent().get_parent().get_children()
	for run in runs:
		run.get_node("start").visible = true
func collected_all_checkpoints() -> bool:
	for checkpoint in checkpoints:
		if !checkpoint.is_collected:
			return false
	return true
func reset_all_checkpoints():
	for checkpoint in checkpoints:
		checkpoint.is_collected = false
func show_my_checkpoints():
	for checkpoint in get_parent().get_node("checkpoints").get_children():
		checkpoint.visible = true
func hide_my_checkpoints():
	for checkpoint in get_parent().get_node("checkpoints").get_children():
		checkpoint.visible = false
func clear_checkpoint_pb():
	checkpoint_diff.text = ""
	checkpoint_time.text = ""
func _on_body_entered(body):
	ConfigFileHandler.load_runs($".")
	
	if body is Player:
		get_vars(body)
		
		if node_type == _type.START and !timer.running and start_timer <= 0.0:
			if PB < dev_time and PB != 0.0:
				timer_pb.add_theme_color_override("font_color", Color(1, 1, 0))
				print("dt, PB %f.2f DT %f.2f" % [PB, dev_time])
			else:
				print("Not dt, PB %f.2f DT %f.2f" % [PB, dev_time])
				timer_pb.add_theme_color_override("font_color", Color(0, 1, 0))
			attempts += 1
			ConfigFileHandler.save_attempts(run_name, attempts)
			clear_checkpoint_pb()
			timer_attempts.text = "Attempts: " + str(attempts)
			self.visible = false
			show_my_checkpoints()
			if show_end:
				other_node.visible = true
			set_vars()
			hide_other_runs()
			last_collected_checkpoint = null
			Global.checkpoint_respawn = restart_point
			Global.pb = PB
			Global.time = 0.0
			Global.run = self
			if restart_point != null:
				Global.origin_point = restart_point.transform.origin
		elif node_type == _type.END and other_node == Global.run and timer.running and collected_all_checkpoints():
			timer.running = false
			hide_my_checkpoints()
			other_node.start_timer = start_timer_max
			timer.set_pb(other_node)
			reset_all_checkpoints()
			show_other_runs()
			if PB < dev_time and PB != 0.0:
				timer_pb.add_theme_color_override("font_color", Color(1, 1, 0))
			self.visible = false

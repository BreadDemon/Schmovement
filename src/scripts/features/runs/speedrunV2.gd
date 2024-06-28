extends Area3D
class_name Speedrun

@export_category("Run Settings")
@export var run_name: String = "None"
@export var dev_time: float
@export var restart_point: ReturnNode
@export var other_node: Speedrun
enum _type { START, END }
@export var node_type: _type
@export var checkpoints: Array[Checkpoint] = []
var last_collected_checkpoint: Checkpoint

@onready var visual = $Visual
const RED = preload("res://assets/Textures/red.tres")

var timer: GameTimer
var timer_run_name: Label
var timer_pb: Label
var timer_dt: Label
var timer_dt_beaten: Label
var format = "%s%s"

var PB: float

func _ready():
	print_debug("Initial checkpoints state in _ready")
	if node_type == _type.END:
		run_name = other_node.run_name
		visual.set_material_override(RED)
	
	# Backup the initial state of checkpoints
	var backup_checkpoints = checkpoints.duplicate()
	print_debug("Initial Checkpoints (backup)")

func get_vars(body):
	timer = body.get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
	timer_run_name = timer.get_parent().get_node("Name")
	timer_pb = timer.get_parent().get_node("times").get_node("PersonalBest")
	timer_dt = timer.get_parent().get_node("DT").get_node("time")
	timer_dt_beaten = timer.get_parent().get_node("DT").get_node("DevTime")

func set_vars():
	timer_run_name.text = run_name
	timer_dt.text = format % ["DT: ", str(dev_time)]
	timer_pb.text = str(PB)
	timer.reset_timer()
	timer.running = true
	if PB > dev_time or PB == 0.0:
		timer_dt_beaten.text = ""

func hide_other_runs():
	var runs = get_parent().get_parent().get_children()
	print("Hide me!")
	for run in runs:
		if run.get_node("start").run_name != run_name:
			run.get_node("start").visible = false
			run.get_node("end").visible = false
		for checkpoint in run.get_node("checkpoints").get_children():
			if checkpoint.mother_run.run_name != run_name:
				checkpoint.visible = false

func show_other_runs():
	var runs = get_parent().get_parent().get_children()
	print("Show me!")
	for run in runs:
		run.get_node("start").visible = true
		run.get_node("end").visible = true
		for checkpoint in run.get_node("checkpoints").get_children():
			checkpoint.visible = true

func collected_all_checkpoints() -> bool:
	for checkpoint in checkpoints:
		if !checkpoint.is_collected:
			return false
	return true

func reset_all_checkpoints():
	for checkpoint in checkpoints:
		checkpoint.is_collected = false

func _on_body_entered(body):
	ConfigFileHandler.load_runs($".")
	
	if body is Player:
		get_vars(body)
		if node_type == _type.START and !timer.running:
			self.visible = false
			set_vars()
			hide_other_runs()
			Global.pb = PB
			Global.start_time = 0.0
			Global.start = self
			if restart_point != null:
				Global.origin_point = restart_point.transform.origin
		elif other_node == Global.start and timer.running and collected_all_checkpoints():
			timer.running = false
			timer.set_pb(other_node)
			reset_all_checkpoints()
			show_other_runs()
			if other_node.PB < other_node.dev_time and other_node.PB != 0.0:
				timer_dt_beaten.text = "Beaten!"

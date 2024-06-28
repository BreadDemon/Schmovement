extends Area3D
class_name Speedrun

@export_category("Run Settings")
@export var run_name: String = "None"
@export var dev_time: float
@export var restart_point: ReturnNode
@export var other_node: Speedrun
enum _type {START, END}
@export var node_type: _type
@export var checkpoints: Array[Checkpoint] = []

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
	if node_type == _type.END:
		run_name = other_node.run_name
		visual.set_material_override(RED)
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
func show_other_runs():
	var runs = get_parent().get_parent().get_children()
	print("Show me!")
	for run in runs:
		run.get_node("start").visible = true
		run.get_node("end").visible = true
func _on_body_entered(body):
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
		elif other_node == Global.start and timer.running:
			timer.running = false
			timer.set_pb(other_node)
			show_other_runs()
			if other_node.PB < other_node.dev_time and other_node.PB != 0.0:
				timer_dt_beaten.text = "Beaten!"

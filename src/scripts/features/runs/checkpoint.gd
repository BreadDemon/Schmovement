extends Area3D
class_name Checkpoint

var is_collected: bool = false
@export var is_respwanable: bool
@export var respawn_point: ReturnNode
var time_by_checkpoint: float
var time_since_last_checkpoint: float
@export var mother_run: Speedrun 

func _on_body_entered(body):
	var timer = body.get_node("Timer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer")
	if body is Player and timer.running and Global.start == mother_run and !is_collected:
		is_collected = true
		print("You collected me!")

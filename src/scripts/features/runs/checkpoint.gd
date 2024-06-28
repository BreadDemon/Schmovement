extends Area3D
class_name Checkpoint

var is_collected: bool = false
@export var is_respwanable: bool
@export var respawn_point: ReturnNode
var time_by_checkpoint: float
var time_since_last_checkpoint: float
var checkpoint_pb: float
@export var mother_run: Speedrun 

func _ready():
	visible = false

func _on_body_entered(body):
	var timer = body.get_node("TimerV2")
	var checkpoint_diff = body.get_node("TimerV2/Panel/Container/Checkpoint/Checkpoint_Diff")
	var checkpoint_time = body.get_node("TimerV2/Panel/Container/Checkpoint/Checkpoint_Time")
	if body is Player and timer.running and Global.run == mother_run and !is_collected:
		is_collected = true
		time_by_checkpoint = Global.time
		if Global.run.last_collected_checkpoint == null:
			Global.run.last_collected_checkpoint = self
			time_since_last_checkpoint = Global.time
			if is_respwanable:
				Global.checkpoint_respawn = respawn_point
			else:
				Global.checkpoint_respawn = null
		else:
			time_since_last_checkpoint = Global.time - Global.run.last_collected_checkpoint.time_by_checkpoint
			Global.run.last_collected_checkpoint = self
			if is_respwanable:
				Global.checkpoint_respawn = respawn_point
			else:
				Global.checkpoint_respawn = null
		if checkpoint_pb != 0.0:
			if checkpoint_pb > time_since_last_checkpoint:
				var diff = time_since_last_checkpoint - checkpoint_pb
				checkpoint_diff.text = str(diff)
				checkpoint_pb = time_since_last_checkpoint
				checkpoint_time.text = str(checkpoint_pb)
				checkpoint_diff.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				var diff = time_since_last_checkpoint - checkpoint_pb
				checkpoint_diff.text = "+" + str(diff)
				checkpoint_time.text = str(time_since_last_checkpoint)
				checkpoint_diff.add_theme_color_override("font_color", Color(1, 0, 0))
		else:
			checkpoint_pb = time_since_last_checkpoint
			checkpoint_time.text = str(time_since_last_checkpoint)
		print("You collected me!")

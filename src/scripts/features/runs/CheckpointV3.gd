extends Area3D
class_name CheckpointV3

@export var is_respawnable: bool
@export var required_checkpoints: Array[CheckpointV3] = []

var mother_run: StartRunNodeV3 # Assuming Speedrun is a class_name or Resource

var is_collected: bool = false
var time_by_checkpoint: float
var time_since_last_checkpoint: float
var checkpoint_pb: float # Personal best for the segment ending at this checkpoint

@onready var visual: Node3D = $Visual # Ensure $Visual is a Node3D or inherits from it
const ORANGE_MATERIAL = preload("res://assets/Textures/orange.tres")

func _ready():
	visible = false # Start invisible, shown by the run logic
	if is_respawnable:
		visual.set_material_override(ORANGE_MATERIAL)

func _are_prerequisites_met() -> bool:
	if required_checkpoints.is_empty():
		return true # No prerequisites, so they are considered met

	for req_checkpoint in required_checkpoints:
		if not req_checkpoint.is_collected:
			# print_debug("CheckpointV3 (%s): Prerequisite '%s' not yet collected." % [name, req_checkpoint.name])
			return false # Found a prerequisite that has not been collected
	
	return true # All prerequisites have been collected

func _on_body_entered(body):
	if body is not Player:
		return # Not a player, so ignore this collision

	if is_collected:
		return # Checkpoint already collected in this attempt, do nothing

	var timer_node = body.get_node_or_null("TimerV2")
	var ui_base_path := "TimerV2/PanelContainer/Panel/Container/Checkpoint/" # Define base path once
	var diff_label_node := body.get_node_or_null(ui_base_path + "Checkpoint_Diff") as Label
	var time_label_node := body.get_node_or_null(ui_base_path + "Checkpoint_Time") as Label

	if not timer_node.running or Global.RunStartV3 != mother_run:
		return # Timer isn't running for this run, or it's not the correct run

	if not _are_prerequisites_met():
		return # Cannot collect this checkpoint yet

	is_collected = true
	visible = false # Hide the checkpoint itself
	time_by_checkpoint = Global.time # Record total time at this checkpoint

	# 5. --- Calculate Time for the Current Segment ---
	var last_collected_node = mother_run.last_collected_checkpoint
	if last_collected_node == null: # This is the first checkpoint collected in the run
		time_since_last_checkpoint = Global.time
	else:
		time_since_last_checkpoint = Global.time - last_collected_node.time_by_checkpoint

	mother_run.last_collected_checkpoint = self # Update to this checkpoint

	if is_respawnable:
		Global.RunReturnPoint = self.global_position

	time_label_node.text = "%.3f" % time_since_last_checkpoint

	if checkpoint_pb <= 0.0: # No segment PB recorded yet, or it's an invalid initial value
		checkpoint_pb = time_since_last_checkpoint # Set current segment time as the initial PB
		diff_label_node.text = "--.--" # Indicate no comparison difference yet
		diff_label_node.remove_theme_color_override("font_color") # Clear any previous color
	else:
		var diff: float = time_since_last_checkpoint - checkpoint_pb
		if time_since_last_checkpoint < checkpoint_pb: # New segment Personal Best!
			checkpoint_pb = time_since_last_checkpoint # Update the PB
			diff_label_node.text = "-%.3f" % abs(diff) # Show negative difference
			diff_label_node.add_theme_color_override("font_color", Color.GREEN) # Or your preferred "better" color
		else: # Slower than or equal to segment PB
			diff_label_node.text = "+%.3f" % diff # Show positive or zero difference
			diff_label_node.add_theme_color_override("font_color", Color.RED) # Or your preferred "worse" color

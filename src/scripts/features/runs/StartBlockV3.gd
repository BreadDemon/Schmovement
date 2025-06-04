extends Area3D
class_name StartRunNodeV3

@export_category("Run Settings")
@export var run_name: String = "None"
@export var start_run_buffer_time_max: float = 3.0
var start_run_buffer_timer: float = 0.0
@export var clear_time: float = 0.0
@export var challenge_time: float = 0.0
@export var dev_time: float = 0.0
@export var end_node: EndRunNodeV3
@export var checkpoints: Array[CheckpointV3] = []
@export var show_end_node: bool = true

var last_collected_checkpoint: CheckpointV3
var PB: float
var attempts: int

var timer: TimerV2
var timer_ui_elements: Dictionary = {
	"run_name": null,        # Label
	"attempts": null,        # Label
	"clock": null,           # Label
	"checkpoint_diff": null, # Label
	"checkpoint_time": null, # Label
	"timer_diff": null,      # Label
	"timer_pb": null         # Label
}

var container: VBoxContainer # Kept separate as it's the parent of UI elements
var format_string = "%s%s" # 'format' is a built-in, renamed to 'format_string'

func _ready():
	end_node.start_node = self
	for cp in checkpoints:
		cp.mother_run = self

func _process(delta: float):
	start_run_buffer_timer -= delta
	if start_run_buffer_timer < -1.0:
		start_run_buffer_timer = 0.0

func get_ui_elements(body: Node):
	timer = body.get_node("TimerV2")
	if not timer:
		printerr("TimerV2 node not found on body!")
		return

	container = timer.get_node("PanelContainer/Panel/Container")
	if not container:
		printerr("Container node not found in TimerV2!")
		return

	timer_ui_elements.run_name = container.get_node("Name_Attempts/Name")
	timer_ui_elements.clock = container.get_node("Clock")
	timer_ui_elements.checkpoint_diff = container.get_node("Checkpoint/Checkpoint_Diff")
	timer_ui_elements.checkpoint_time = container.get_node("Checkpoint/Checkpoint_Time")
	timer_ui_elements.attempts = container.get_node("Diff_PB/Attempts") # Corrected path based on original
	timer_ui_elements.timer_diff = container.get_node("DT/Diff") # Assuming "DT/Diff" was a typo and meant for timer_diff
	timer_ui_elements.timer_pb = container.get_node("DT/PersonalBest")

	# Ensure all elements were found
	for key in timer_ui_elements:
		if timer_ui_elements[key] == null:
			printerr("Failed to get UI element: ", key)


func set_ui_vars():
	if timer_ui_elements.run_name:
		timer_ui_elements.run_name.text = run_name
	if timer_ui_elements.timer_pb:
		timer_ui_elements.timer_pb.text = "PB: " + str(PB)

# Call this when 'self' (the current run) starts
func hide_all_runs():
	var runs_container_node = get_parent() # This is the "runs" node
	for other_run_node in runs_container_node.get_children():
		if other_run_node == self:
			continue # Skip the current run
		if other_run_node is StartRunNodeV3:
			other_run_node.visible = false

func show_all_runs(): # Call this when resetting, allowing any run to be started
	var runs_container_node = get_parent() # This is the "runs" node
	for run_node_to_activate in runs_container_node.get_children():
		if run_node_to_activate is StartRunNodeV3:
			run_node_to_activate.visible = true    # Ensure the node itself is visible

func collected_all_checkpoints() -> bool:
	for checkpoint in checkpoints:
		if not checkpoint.is_collected:
			return false
	return true

func reset_all_checkpoints():
	for checkpoint in checkpoints:
		checkpoint.is_collected = false

func show_my_checkpoints():
	if checkpoints.is_empty():
		return
	for checkpoint_instance in checkpoints:
		checkpoint_instance.visible = true

func hide_my_checkpoints():
	if checkpoints.is_empty():
		return
	for checkpoint_instance in checkpoints:
		checkpoint_instance.visible = false

func clear_checkpoint_pb_display():
	if timer_ui_elements.checkpoint_diff:
		timer_ui_elements.checkpoint_diff.text = ""
	if timer_ui_elements.checkpoint_time:
		timer_ui_elements.checkpoint_time.text = ""

func reset_run():
	self.visible = true
	end_node.visible = false
	hide_my_checkpoints()
	reset_all_checkpoints()
	show_all_runs()

func _on_body_entered(body: Node):
	ConfigFileHandler.load_runs($".") # Assuming ConfigFileHandler is an autoload or static class

	if body is Player: # Make sure Player is a defined class_name
		get_ui_elements(body)

		if can_start_run():
			show_my_checkpoints()
			clear_checkpoint_pb_display()
			set_ui_vars()
			update_attempts()
			toggle_visibilities()

			last_collected_checkpoint = null
			Global.RunReturnPoint = self.global_position
			Global.pb = PB
			Global.time = 0.0
			Global.RunStartV3 = self
			Global.RunResetPoint = self.global_position
			
			if timer:
				timer.reset_timer()
				timer.running = true

func toggle_visibilities() -> void:
	if show_end_node:
		end_node.visible = true

func update_attempts() -> void:
	attempts += 1
	ConfigFileHandler.save_attempts(run_name, attempts)

	if timer_ui_elements.attempts:
		timer_ui_elements.attempts.text = "Attempts: " + str(attempts)

func can_start_run() -> bool:
	# Ensure timer is valid before checking 'running' property
	return timer != null and not timer.running and start_run_buffer_timer <= 0.0

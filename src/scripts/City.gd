extends Node3D

@onready var runs = $Runs

func _ready():
	ConfigFileHandler.load_runs(runs)

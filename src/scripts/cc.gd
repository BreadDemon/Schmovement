extends Node3D

@onready var controller_v_2 = $ControllerV2

func _ready():
	controller_v_2.velocity.y = 5.0
	controller_v_2.velocity.z = -5.0

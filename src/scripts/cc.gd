extends Node3D

@onready var controller_v_2 = $ControllerV2
@onready var city_entrance = $CityEntrance
@onready var tutorial_return = $tutorialReturn

func _ready():
	print(tutorial_return.transform.origin)
	print(Global.coming_from)
	if Global.coming_from == "Tutorial":
		controller_v_2.velocity.y = 5.0
		controller_v_2.velocity.z = -5.0
		Global.origin_point = tutorial_return.transform.origin
	elif Global.coming_from == "City":
		controller_v_2.transform.origin = city_entrance.transform.origin
		Global.origin_point = city_entrance.transform.origin
		controller_v_2.apply_floor_snap()
	else:
		controller_v_2.velocity.y = 5.0
		controller_v_2.velocity.z = -5.0
		Global.origin_point = tutorial_return.transform.origin

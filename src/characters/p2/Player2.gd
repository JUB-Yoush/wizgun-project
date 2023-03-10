extends load("res://src/characters/base/Base.gd") 


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# CONTROLS ---------------------
	input_up = "p2_up"
	input_down = "p2_down"
	input_left = "p2_left"
	input_right = "p2_right"
	
	input_jump = "p2_jump"
	input_gun = "p2_gun"
	input_sword = "p2_sword"
	
	# IDENTIFIERS ---------------------
	player_tag = "p2"
	#add_collision_exception_with(get_parent().get_node("Player1"))
	


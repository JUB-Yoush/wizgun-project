#extends preload("res://src/characters/base/Base.gd")
extends CharacterBase
func _ready():
	# CONTROLS ---------------------
	input_up = "p1_up"
	input_down = "p1_down"
	input_left = "p1_left"
	input_right = "p1_right"
	
	input_jump = "p1_jump"
	input_gun = "p1_gun"
	input_sword = "p1_sword"
	
	# IDENTIFIERS ---------------------
	player_tag = "p1"
	#add_collision_exception_with(get_parent().get_node("Player2"))
	super._ready()

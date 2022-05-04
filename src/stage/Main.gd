extends Node2D

onready var respawnPositions = $RespawnPositions

signal hitstop_over

func get_respawn_position():
	var respawn_position:Position2D
	var rng = randi() % respawnPositions.get_child_count()
	respawn_position = respawnPositions.get_child(rng)
	return respawn_position

func make_hitstop(timeScale, duration):
	#connect("hitstop_over",caller, "")
	#timeScale = how slow the hitstop is (0.03)
	#duration = how long it lasts in seconds (0.7)
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1
	emit_signal("hitstop_over")

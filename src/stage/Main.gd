extends Node2D

onready var respawnPositions = $RespawnPositions

func get_respawn_position():
	var respawn_position:Position2D
	var rng = randi() % respawnPositions.get_child_count()
	respawn_position = respawnPositions.get_child(rng)
	return respawn_position

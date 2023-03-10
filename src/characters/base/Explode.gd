extends Area2D
@export var explode_lifetime:float = 0.2

func _ready() -> void:
	connect("area_entered",Callable(self,"on_area_entered"))
	await get_tree().create_timer(explode_lifetime).timeout
	call_deferred("queue_free")

func on_area_entered(area:Area2D):
	print("thats an area")
	var body:PhysicsBody2D = area.get_parent()
	if body != null:
		if body.is_in_group("player"):
			body.on_player_defeat()
		
	

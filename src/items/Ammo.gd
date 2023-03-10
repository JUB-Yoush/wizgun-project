extends Area2D

func _ready():
	connect("body_entered",Callable(self,"_on_body_entered"))
	

func _on_body_entered(body):
	print('body')
	if body.is_in_group("player"):
		body.ammo = 3
		queue_free()
		
	

extends Area2D

var dir:Vector2 = Vector2.ZERO
export var speed:float = 10
onready var visibilityNotif = $VisibilityNotifier2D

enum PARENTS{
	P1,
	P2
}
var parent_enum
# Called when the node enters the scene tree for the first time.
func _ready():
	visibilityNotif.connect("screen_exited",self,"exited_screen")
	if parent_enum == PARENTS.P1:
		set_modulate("#1b22d3")
	elif parent_enum == PARENTS.P2:
		set_modulate("#d31b1b")
	
	match dir:
		Vector2(0,1):
			$Sprite.rotation_degrees = 0
			$CollisionShape2D.rotation_degrees = 0
			$Sprite.set_flip_h(false)
		Vector2(0,-1):
			$Sprite.rotation_degrees = 0
			$CollisionShape2D.rotation_degrees = 0
			$Sprite.set_flip_h(true)
		Vector2(1,0):
			$Sprite.rotation_degrees = 90
			$CollisionShape2D.rotation_degrees = 90
		Vector2(-1,0):
			$Sprite.rotation_degrees = 270
			$CollisionShape2D.rotation_degrees = 270
			
		
	


func _physics_process(delta):
	var velocity = speed * dir
	position += velocity
	pass

func exited_screen():
	queue_free()

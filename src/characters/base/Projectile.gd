extends Area2D

var dir:Vector2 = Vector2.ZERO
export var speed:float = 10
onready var visibilityNotif = $VisibilityNotifier2D

# Called when the node enters the scene tree for the first time.
func _ready():
	visibilityNotif.connect("screen_exited",self,"exited_screen")
	pass # Replace with function body.


func _physics_process(delta):
	var velocity = speed * dir
	position += velocity
	pass

func exited_screen():
	queue_free()

extends Area2D

onready var timer := $Timer
onready var progressBar := $ProgressBar

var body_present:PhysicsBody2D = null
var delivery_time := 1.0
var two_bodies_present := false
func _ready() -> void:
	timer.wait_time = delivery_time
	connect("area_entered",self,"on_area_entered")
	connect("area_exited",self,"on_area_exited")
	timer.connect("timeout",self,"on_timer_timeout")


func on_area_entered(area:Area2D):
	print('hi')
	if body_present == null and area.is_in_group("hitbox"):
		body_present = area.get_parent()
		start_delivery()
	elif body_present != null and area.is_in_group("hitbox"):
		two_bodies_present = true
		timer.stop()
		progressBar.visible = false

func on_area_exited(area:Area2D):
	# if one body left then make it the active one, if no bodies then set to null
	print('bye')
	if area.get_parent().is_in_group("player"):
		if two_bodies_present:
			var collisions := get_overlapping_areas()
			for collision in collisions:
				if collision.is_in_group("hitbox"):
					body_present = collision.get_parent()
					start_delivery()
		else:
			body_present = null
			timer.stop()
			progressBar.visible = false

func start_delivery():
	timer.wait_time = delivery_time
	if timer.is_stopped():
		timer.start()
		progressBar.visible = true 

	
func _physics_process(delta: float) -> void:
	if body_present:
		print(body_present.player_tag)
	#prints("basket time:",timer.time_left,timer.is_stopped(),two_bodies_present)
	progressBar.value = -(timer.time_left - 1)


func on_timer_timeout():
	body_present.scored_point()
	

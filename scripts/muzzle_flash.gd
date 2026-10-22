extends Node3D
class_name MuzzleFlash

@export var min_energy := 2.0
@export var max_energy := 6.0

@export var min_duration := 0.04
@export var max_duration := 0.1

@export var self_destroy_time : float = 0.5

@onready var light := $OmniLight3D

func _ready():
	randomize()

	# random color
	var color := Color(
		randf_range(0.9, 1.0),
		randf_range(0.6, 0.9),
		randf_range(0.2, 0.5)
	)
	light.light_color = color

	# random energy
	var start_energy = randf_range(min_energy, max_energy)
	light.light_energy = start_energy

	# random duration
	var duration = randf_range(min_duration, max_duration)

	# animate
	var tween = create_tween()
	tween.tween_property(light, "light_energy", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		
	# start particles
	$MuzzleSparks.emitting = true
	$MuzzleFlash.rotation.z = randf() * TAU
	$MuzzleFlash.emitting = true
	$MuzzleCircle.emitting = true

	# self-destroy
	await get_tree().create_timer(self_destroy_time).timeout
	queue_free()
	

extends Node3D
class_name ShootImpact01

@export var self_destroy_time : float = 1.0
@export var impact_pos_offset : float = 0.05

func _ready():
	randomize()
	
	# start particles
	$ImpactSparks.emitting = true
	$ImpactCircle.emitting = true

	# self-destroy
	await get_tree().create_timer(self_destroy_time).timeout
	queue_free()
	
func create_transform_matrix(impact_pos : Vector3, impact_nrm : Vector3):
	# create transform matrix from impact position and normal
	
	var up = Vector3.UP
	if abs(impact_nrm.dot(up)) > 0.99:
		up = Vector3.FORWARD

	var basis = Basis()
	basis.z = -impact_nrm
	basis.x = up.cross(basis.z).normalized()
	basis.y = basis.z.cross(basis.x).normalized()
	
	var pos = impact_pos + impact_nrm * impact_pos_offset # add position offset

	global_transform = Transform3D(basis, pos)			

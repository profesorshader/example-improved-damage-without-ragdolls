extends Decal
class_name ShootDecal01

func create_transform_matrix(impact_pos : Vector3, impact_nrm : Vector3):
	# create transform matrix from impact position and normal

	var up = Vector3.UP
	if abs(impact_nrm.dot(up)) > 0.99:
		up = Vector3.FORWARD

	var basis = Basis()
	basis.y = impact_nrm.normalized()
	basis.x = up.cross(basis.y).normalized()
	basis.z = basis.x.cross(basis.y).normalized()
	
	# add an extra random rotation around local Y
	var angle = randf() * TAU
	basis = basis.rotated(basis.y, angle)	
	
	global_transform = Transform3D(basis, impact_pos)	

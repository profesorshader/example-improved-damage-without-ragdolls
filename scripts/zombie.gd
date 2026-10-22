extends Node3D

@onready var skl_mod_head_damage: SklModImpactDamage = $Zombie/Skeleton3D/SklModImpactDamageHead
@onready var skl_mod_left_arm_damage: SklModImpactDamage = $Zombie/Skeleton3D/SklModImpactDamageLeftArm
@onready var skl_mod_right_arm_damage: SklModImpactDamage = $Zombie/Skeleton3D/SklModImpactDamageRightArm
@onready var skl_mod_spine_damage: SklModImpactDamage = $Zombie/Skeleton3D/SklModImpactDamageSpine
@onready var skl_mod_hips_damage: SklModImpactDamage = $Zombie/Skeleton3D/SklModImpactDamageHips

func do_head_impact(dir: Vector3):
	skl_mod_head_damage.do_impact(dir)

func do_left_arm_impact(dir: Vector3):
	skl_mod_left_arm_damage.do_impact(dir)
	
func do_right_arm_impact(dir: Vector3):
	skl_mod_right_arm_damage.do_impact(dir)	

func do_spine_impact(dir: Vector3):
	skl_mod_spine_damage.do_impact(dir)		
	
func do_hips_impact(dir: Vector3):
	skl_mod_hips_damage.do_impact(dir)		
	
func do_impact(collider, dir: Vector3):
	# where was hit?
	print(collider.name)
	match collider.name:
		"AreaHead", "AreaNeck":
			do_head_impact(dir)
		"AreaLeftArm", "AreaLeftForeArm":
			do_left_arm_impact(dir)
		"AreaRightArm", "AreaRightForeArm":
			do_right_arm_impact(dir)
		"AreaSpine1":
			do_spine_impact(dir)
		"AreaSpine", "AreaHips":
			do_hips_impact(dir)
		_:
			print(collider.name + " collider not configured")

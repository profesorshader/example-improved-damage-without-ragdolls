extends Node3D

@export var life = 100
@export var dissolve_material: ShaderMaterial
@export var death_time = 1.0

var is_dead : bool = false

@onready var zombie_mesh : MeshInstance3D = $Zombie/Skeleton3D/Zombie_Cylinder
@onready var animation_player : AnimationPlayer = $AnimationPlayer

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
	
func do_death_animation():		
	# flag as dead
	is_dead = true
	
	# pause animation 
	# the zombie model does not have a death animation
	# a "frozen" effect should work
	animation_player.pause()
	skl_mod_head_damage.pause()
	skl_mod_left_arm_damage.pause()
	skl_mod_right_arm_damage.pause()
	skl_mod_spine_damage.pause()
	skl_mod_hips_damage.pause()	
	
	# wait death time
	if dissolve_material:
		zombie_mesh.material_override = dissolve_material
		
		zombie_mesh.material_override.set_shader_parameter("t", 0.0)

		var tween = create_tween()
		tween.tween_method(
			func(value):
				zombie_mesh.material_override.set_shader_parameter("t", value),
			0.0,
			1.0,
			death_time
		)

		await tween.finished			

	# remove from scene	
	queue_free()	
	
func do_impact(collider, dir: Vector3):
	# already dead ?
	if is_dead:
		return
			
	# where was hit?
	print(collider.name)
	match collider.name:
		"AreaHead", "AreaNeck":
			life -= 15
			do_head_impact(dir)
		"AreaLeftArm", "AreaLeftForeArm":
			life -= 5
			do_left_arm_impact(dir)
		"AreaRightArm", "AreaRightForeArm":
			life -= 5
			do_right_arm_impact(dir)
		"AreaSpine1":
			life -= 10
			do_spine_impact(dir)
		"AreaSpine", "AreaHips":
			life -= 10
			do_hips_impact(dir)
		_:
			print(collider.name + " collider not configured")
			
	# is dead?
	if life <= 0:		
		do_death_animation()

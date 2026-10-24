extends SkeletonModifier3D
class_name SklModImpactDamage

enum AnimMode { IDLE, IMPACT, RECOVER }
enum AxisOption { X, Y, Z, ZERO, NEG_X, NEG_Y, NEG_Z }

@export var enabled : bool = true

@export var max_rotation : float = 30.0 # in degrees

# all bones ara optional
@export var bone_name_a : String = "Head"
@export var bone_name_b : String = "Neck"
@export var bone_name_c : String = "Spine2"
@export var bone_name_d : String = "Spine1"

@export var bone_weight_a : float = 1.0
@export var bone_weight_b : float = 0.5
@export var bone_weight_c : float = 0.25
@export var bone_weight_d : float = 0.125

@export var source_x: AxisOption = AxisOption.Z
@export var source_y: AxisOption = AxisOption.ZERO
@export var source_z: AxisOption = AxisOption.NEG_X

var anim_mode : AnimMode = AnimMode.IDLE;

var bone_idx_a : int = -1
var bone_idx_b : int = -1
var bone_idx_c : int = -1
var bone_idx_d : int = -1

var skeleton : Skeleton3D = null
var desired_angle : float = 0.0 # radians
var current_angle : float = 0.0 # radians
var impact_speed : float = 50.0
var recover_speed : float = 5.0
var impact_axis : Vector3 = Vector3(1.0, 0.0, 0.0)

var is_paused : bool = false

func pause():
	is_paused = true

func enable_skeleton_modifier():
	active = enabled
	
func disable_skeleton_modifier():
	active = false

func get_axis_value(option: AxisOption, dir: Vector3) -> float:
	match option:
		AxisOption.X: return dir.x
		AxisOption.Y: return dir.y
		AxisOption.Z: return dir.z
		AxisOption.ZERO: return 0.0
		AxisOption.NEG_X: return -dir.x
		AxisOption.NEG_Y: return -dir.y
		AxisOption.NEG_Z: return -dir.z
	return 0.0
	
func _ready():
	# leave disabled for now
	disable_skeleton_modifier()
	
	# skeleton found?
	skeleton = get_skeleton()
	if !skeleton:		
		return 

	# look for the bones
	bone_idx_a = skeleton.find_bone(bone_name_a)	
	bone_idx_b = skeleton.find_bone(bone_name_b)	
	bone_idx_c = skeleton.find_bone(bone_name_c)	
	bone_idx_d = skeleton.find_bone(bone_name_d)	
	
func _process_modification() -> void:
	# need to modify ?
	if (current_angle == 0.0):
		disable_skeleton_modifier()
		return	
		
	# is paused?
	if is_paused:
		return
		
	# change bones rotations
	var src_rot : Quaternion
	var rot : Quaternion
	if (bone_idx_a >= 0):
		src_rot = skeleton.get_bone_pose_rotation(bone_idx_a)
		rot = Quaternion(impact_axis, current_angle * bone_weight_a)
		skeleton.set_bone_pose_rotation(bone_idx_a, src_rot * rot)		
	
	if (bone_idx_b >= 0):
		src_rot = skeleton.get_bone_pose_rotation(bone_idx_b)
		rot = Quaternion(impact_axis, current_angle * bone_weight_b)
		skeleton.set_bone_pose_rotation(bone_idx_b, src_rot * rot)			

	if (bone_idx_c >= 0):
		src_rot = skeleton.get_bone_pose_rotation(bone_idx_c)
		rot = Quaternion(impact_axis, current_angle * bone_weight_c)
		skeleton.set_bone_pose_rotation(bone_idx_c, src_rot * rot)			
	
	if (bone_idx_d >= 0):
		src_rot = skeleton.get_bone_pose_rotation(bone_idx_d)
		rot = Quaternion(impact_axis, current_angle * bone_weight_d)
		skeleton.set_bone_pose_rotation(bone_idx_d, src_rot * rot)			

func _process(delta):
	# is paused?
	if is_paused:
		return
			
	# animate!
	match anim_mode:
		# animate impact
		AnimMode.IMPACT:
			current_angle = lerp(current_angle, desired_angle, delta * impact_speed)
			if abs(current_angle - desired_angle) < 0.001:
				current_angle = desired_angle
				anim_mode = AnimMode.RECOVER
		# animate recover
		AnimMode.RECOVER:
			current_angle = lerp(current_angle, 0.0, delta * recover_speed)
			if abs(current_angle - 0.0) < 0.001:
				current_angle = 0.0
				anim_mode = AnimMode.IDLE
				disable_skeleton_modifier()
		
func do_impact(dir: Vector3):
	# convert from world to local space
	var local_dir = global_transform.basis.inverse() * dir	
	
	# convert impact direction into the desired axis rotation for the bones
	impact_axis.x = get_axis_value(source_x, local_dir)
	impact_axis.y = get_axis_value(source_y, local_dir)
	impact_axis.z = get_axis_value(source_z, local_dir)
	
	# normalize!
	impact_axis = impact_axis.normalized()
	
	# axis is wrong?
	if impact_axis.length() == 0.0:
		return 
		
	# apply initial rotation 
	desired_angle = deg_to_rad(max_rotation)
	anim_mode = AnimMode.IMPACT
	enable_skeleton_modifier()

extends CharacterBody3D
class_name Player

@export var move_vel : float = 5.0
@export var jump_vel : float = 4.5
@export var mouse_sens : float = 0.002
@export var gamepad_sens : float = 0.025
@export var cam_x_min_deg : float = -70.0
@export var cam_x_max_deg : float = 70.0

const BLOOD_IMPACT_01 = preload("res://scenes/sub/blood_impact_01.tscn")
const MUZZLE_FLASH = preload("res://scenes/sub/muzzle_flash.tscn")
const SHOT_IMACT_01 = preload("res://scenes/sub/shot_impact_01.tscn")
const SHOT_DECAL_01 = preload("res://scenes/sub/shot_decal_01.tscn")
const SHOT_SOUNDS = [
	preload("res://sfx/pistol-gun-shot-01.wav"),
	preload("res://sfx/pistol-gun-shot-02.wav"),
	preload("res://sfx/pistol-gun-shot-03.wav"),
	preload("res://sfx/pistol-gun-shot-04.wav"),
	preload("res://sfx/pistol-gun-shot-05.wav")
]

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var cam_x_min_rad : float;
var cam_x_max_rad : float;

const MAX_DECALS := 10
var decal_list : Array[Decal] = []

func _ready():
	$Camera3D.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cam_x_min_rad = deg_to_rad(cam_x_min_deg)	
	cam_x_max_rad = deg_to_rad(cam_x_max_deg)	
	
func rotate_camera(axis_x, axis_y, sensitivity):	
	rotate_y(-axis_x * sensitivity)
	$Camera3D.rotate_x(-axis_y * sensitivity)
	$Camera3D.rotation.x = clampf($Camera3D.rotation.x, cam_x_min_rad, cam_x_max_rad)	

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_camera(event.relative.x, event.relative.y, mouse_sens)

func _process(_delta):
	# movement
	var input_dir = Input.get_vector("rotate_left", "rotate_right", "rotate_up", "rotate_down")
	if input_dir.length() > 0.0:
		rotate_camera(input_dir.x, input_dir.y, gamepad_sens)
	
	# shooting
	if Input.is_action_just_pressed("shoot"):
		_do_shoot()
		
func _physics_process(delta):
	# its on the floor?
	if not is_on_floor():
		# add gravity
		velocity.y -= gravity * delta		
	else:
		# handle jump
		if Input.is_action_just_pressed("action_jump") and is_on_floor():
			velocity.y = jump_vel				

	# get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_vel
		velocity.z = direction.z * move_vel
	else:
		velocity.x = move_toward(velocity.x, 0, move_vel)
		velocity.z = move_toward(velocity.z, 0, move_vel)

	# procesamos el movimiento
	move_and_slide()			

func _do_shoot():
	var src = $Camera3D/Weapon/MuzzleFlashPoint
	
	# muzzle flash
	var flash = MUZZLE_FLASH.instantiate()
	src.add_child(flash)
	
	# compute ray
	var ray_origin = src.global_transform.origin
	var direction = -src.global_transform.basis.z  # forward (-Z in Godot)
	var length = 1000.0
	var ray_end = ray_origin + direction * length	

	# do ray-cast
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true # exclude areas
	query.exclude = [self] # exclude player
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	# do sound
	$AudioStreamPlayer3D.stream = SHOT_SOUNDS.pick_random()
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.95, 1.05)
	$AudioStreamPlayer3D.volume_db = randf_range(-10, 0)
	$AudioStreamPlayer3D.play()	

	# any impact?
	if result:		
		
		# it's an enemy?
		if result.collider:
			# new code
			if result.collider.collision_layer == 4:
				# get zombie
				var zombie = result.collider.get_owner()
				
				# add enemy spray
				var blood_impact = BLOOD_IMPACT_01.instantiate()			
				blood_impact.create_transform_matrix(result.position, result.normal)
				get_tree().current_scene.add_child(blood_impact)					
				
				# do impact
				zombie.do_impact(result.collider, direction)
			else:
			
				# old code
				if result.collider.is_in_group("enemy"):
					var blood_impact = BLOOD_IMPACT_01.instantiate()			
					blood_impact.create_transform_matrix(result.position, result.normal)
					get_tree().current_scene.add_child(blood_impact)
					
				else:
					# create shoot impact + decal
					var shot_impact = SHOT_IMACT_01.instantiate()
					var shot_decal = SHOT_DECAL_01.instantiate()

					# compute impact matrix and add to the scene		
					shot_impact.create_transform_matrix(result.position, result.normal)
					get_tree().current_scene.add_child(shot_impact)
					
					# add decal
					shot_decal.create_transform_matrix(result.position, result.normal)
					get_tree().current_scene.add_child(shot_decal)
					decal_list.append(shot_decal)
					
					# remove old decals
					if decal_list.size() > MAX_DECALS:
						var old_decal = decal_list.pop_front()
						old_decal.queue_free()		
		

extends CharacterBody3D


const WALL_COLLISION_MASK := 1 << 0
const GROUND_COLLISION_MASK := 1 << 1
const PLAYER_COLLISION_LAYER := 1 << 2
const MovementMath = preload("res://scripts/movement_math.gd")

@export var move_speed := 6.0
@export var acceleration := 22.0
@export var stop_distance := 0.2
@export var gravity_scale := 1.0
@export var turn_speed := 10.0

var _has_target := false
var _target_position := Vector3.ZERO
var _gravity := 9.8


func _ready() -> void:
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	collision_layer = PLAYER_COLLISION_LAYER
	collision_mask = WALL_COLLISION_MASK | GROUND_COLLISION_MASK


func set_move_target(world_target: Vector3) -> void:
	_target_position = Vector3(world_target.x, global_position.y, world_target.z)
	_has_target = true


func clear_move_target() -> void:
	_has_target = false


func _physics_process(delta: float) -> void:
	if _has_target and MovementMath.arrived_2d(global_position, _target_position, stop_distance):
		_has_target = false

	var move_target := global_position
	if _has_target:
		move_target = _target_position

	velocity = MovementMath.next_velocity_2d(
		velocity,
		global_position,
		move_target,
		move_speed,
		acceleration,
		stop_distance,
		delta
	)

	if not is_on_floor():
		velocity.y -= _gravity * gravity_scale * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	move_and_slide()
	_rotate_toward_motion(delta)


func _rotate_toward_motion(delta: float) -> void:
	var planar_velocity := Vector2(velocity.x, velocity.z)
	if planar_velocity.length() <= 0.05:
		return

	var target_yaw := atan2(planar_velocity.x, planar_velocity.y)
	rotation.y = lerp_angle(rotation.y, target_yaw, minf(1.0, turn_speed * delta))

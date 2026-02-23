extends Node3D


const GROUND_COLLISION_MASK := 1 << 1

@export var orbit_sensitivity := 0.2
@export var key_orbit_speed := 65.0
@export var min_zoom := 4.0
@export var max_zoom := 14.0
@export var zoom_step := 1.0

@onready var player = $Player
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_yaw: Node3D = $CameraPivot/CameraYaw
@onready var camera_pitch: Node3D = $CameraPivot/CameraYaw/CameraPitch
@onready var spring_arm: SpringArm3D = $CameraPivot/CameraYaw/CameraPitch/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/CameraYaw/CameraPitch/SpringArm3D/Camera3D

var _orbiting := false
var _yaw := 35.0
var _pitch := -35.0


func _ready() -> void:
	player.global_position = Vector3(0.0, 0.51, 0.0)
	_apply_camera_angles()


func _physics_process(delta: float) -> void:
	camera_pivot.global_position = player.global_position + Vector3(0.0, 1.0, 0.0)

	if Input.is_key_pressed(KEY_Q):
		_yaw += key_orbit_speed * delta
		_apply_camera_angles()
	elif Input.is_key_pressed(KEY_E):
		_yaw -= key_orbit_speed * delta
		_apply_camera_angles()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_position: Vector3 = _raycast_to_ground(event.position)
			if click_position.is_finite():
				player.set_move_target(click_position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_orbiting = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			spring_arm.spring_length = clampf(spring_arm.spring_length - zoom_step, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			spring_arm.spring_length = clampf(spring_arm.spring_length + zoom_step, min_zoom, max_zoom)

	if event is InputEventMouseMotion and _orbiting:
		_yaw -= event.relative.x * orbit_sensitivity
		_pitch = clampf(_pitch - event.relative.y * orbit_sensitivity, -80.0, -10.0)
		_apply_camera_angles()


func _apply_camera_angles() -> void:
	camera_yaw.rotation_degrees.y = _yaw
	camera_pitch.rotation_degrees.x = _pitch


func _raycast_to_ground(screen_position: Vector2) -> Vector3:
	var from := camera.project_ray_origin(screen_position)
	var to := from + camera.project_ray_normal(screen_position) * 500.0

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = GROUND_COLLISION_MASK
	query.collide_with_areas = false
	query.exclude = [player]

	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return Vector3.INF

	return result.position

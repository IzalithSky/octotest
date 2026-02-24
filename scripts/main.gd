extends Node3D


const GROUND_COLLISION_MASK := 1 << 1
const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"
const InteractionController = preload("res://scripts/interaction_controller.gd")

@export var orbit_sensitivity := 0.2
@export var key_orbit_speed := 65.0
@export var min_zoom := 4.0
@export var max_zoom := 14.0
@export var zoom_step := 1.0

@onready var player: CharacterBody3D = $Player
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_yaw: Node3D = $CameraPivot/CameraYaw
@onready var camera_pitch: Node3D = $CameraPivot/CameraYaw/CameraPitch
@onready var spring_arm: SpringArm3D = $CameraPivot/CameraYaw/CameraPitch/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/CameraYaw/CameraPitch/SpringArm3D/Camera3D
@onready var hud_root: Control = $UI/HUD
@onready var hint_label: Label = $UI/HUD/HintPanel/HintMargin/HintLabel
@onready var in_game_menu: Control = $UI/InGameMenu
@onready var in_game_main_menu_button: Button = $UI/InGameMenu/MenuCenter/MenuPanel/MenuMargin/MenuButtons/MainMenuButton
@onready var in_game_quit_button: Button = $UI/InGameMenu/MenuCenter/MenuPanel/MenuMargin/MenuButtons/QuitButton
@onready var room_light: OmniLight3D = $OmniLight3D

var _interaction_controller: InteractionController
var _orbiting := false
var _yaw := 35.0
var _pitch := -35.0


func _ready() -> void:
	player.global_position = Vector3(0.0, 0.51, 0.0)
	_apply_camera_angles()
	_make_click_through(hud_root)
	_create_interaction_controller()
	in_game_main_menu_button.pressed.connect(_on_main_menu_pressed)
	in_game_quit_button.pressed.connect(_on_quit_pressed)
	_set_in_game_menu_visible(false)


func _physics_process(delta: float) -> void:
	camera_pivot.global_position = player.global_position + Vector3(0.0, 1.0, 0.0)
	if in_game_menu.visible:
		_interaction_controller.set_interaction_enabled(false)
		return

	_interaction_controller.set_interaction_enabled(true)
	_interaction_controller.process_interactions(delta)

	if Input.is_key_pressed(KEY_Q):
		_yaw += key_orbit_speed * delta
		_apply_camera_angles()
	elif Input.is_key_pressed(KEY_E):
		_yaw -= key_orbit_speed * delta
		_apply_camera_angles()


func _unhandled_input(event: InputEvent) -> void:
	if _is_escape_press(event):
		if _interaction_controller != null and _interaction_controller.consume_escape():
			get_viewport().set_input_as_handled()
			return
		_set_in_game_menu_visible(not in_game_menu.visible)
		get_viewport().set_input_as_handled()
		return

	if in_game_menu.visible:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _interaction_controller.try_handle_interaction_click(event.position):
				get_viewport().set_input_as_handled()
				return
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

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		_interaction_controller.handle_drop_input(event.shift_pressed)
		get_viewport().set_input_as_handled()


func _create_interaction_controller() -> void:
	_interaction_controller = InteractionController.new()
	_interaction_controller.name = "InteractionController"
	add_child(_interaction_controller)
	_interaction_controller.initialize(player, camera, hint_label, self, room_light)


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


func _is_escape_press(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo and event.keycode == KEY_ESCAPE
	return false


func _set_in_game_menu_visible(is_visible: bool) -> void:
	in_game_menu.visible = is_visible
	_orbiting = false
	if is_visible:
		_interaction_controller.set_interaction_enabled(false)
	if is_visible:
		in_game_main_menu_button.grab_focus()


func _make_click_through(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child: Node in node.get_children():
		_make_click_through(child)


func _on_main_menu_pressed() -> void:
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
	if error != OK:
		push_error("Failed to load main menu scene: %s" % MAIN_MENU_SCENE_PATH)


func _on_quit_pressed() -> void:
	get_tree().quit()

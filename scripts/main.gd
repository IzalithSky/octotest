extends Node3D


const GROUND_COLLISION_MASK := 1 << 1
const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"
const InteractionController = preload("res://scripts/interaction_controller.gd")
const FocusTargetType = preload("res://scripts/focus_target.gd")

@export var orbit_sensitivity := 0.2
@export var key_orbit_speed := 65.0
@export var min_zoom := 4.0
@export var max_zoom := 14.0
@export var zoom_step := 1.0
@export var focus_zoom_distance := 3.6
@export var focus_tween_duration := 0.24

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
var _focus_mode := false
var _focus_target: FocusTargetType
var _focus_pending_target: FocusTargetType
var _focus_tween: Tween
var _saved_spring_length := 9.0
var _player_mesh: MeshInstance3D


func _ready() -> void:
	player.global_position = Vector3(0.0, 0.51, 0.0)
	_apply_camera_angles()
	_make_click_through(hud_root)
	_create_interaction_controller()
	_player_mesh = player.get_node_or_null("MeshInstance3D") as MeshInstance3D
	in_game_main_menu_button.pressed.connect(_on_main_menu_pressed)
	in_game_quit_button.pressed.connect(_on_quit_pressed)
	_set_in_game_menu_visible(false)


func _physics_process(delta: float) -> void:
	if not _focus_mode:
		camera_pivot.global_position = player.global_position + Vector3(0.0, 1.0, 0.0)

	if in_game_menu.visible:
		_interaction_controller.set_interaction_enabled(false)
		return

	_interaction_controller.set_interaction_enabled(true)
	_interaction_controller.process_interactions(delta)
	_process_focus_mode()
	_process_pending_focus_entry()

	if not _focus_mode and Input.is_key_pressed(KEY_Q):
		_yaw += key_orbit_speed * delta
		_apply_camera_angles()
	elif not _focus_mode and Input.is_key_pressed(KEY_E):
		_yaw -= key_orbit_speed * delta
		_apply_camera_angles()


func _unhandled_input(event: InputEvent) -> void:
	if _is_escape_press(event):
		if _focus_mode:
			_exit_focus_mode()
			get_viewport().set_input_as_handled()
			return
		if _interaction_controller != null and _interaction_controller.consume_escape():
			get_viewport().set_input_as_handled()
			return
		_set_in_game_menu_visible(not in_game_menu.visible)
		get_viewport().set_input_as_handled()
		return

	if in_game_menu.visible:
		return

	if _focus_mode:
		_handle_focus_mode_input(event)
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked_focus_target := _interaction_controller.get_focus_target_at_screen(event.position)
			if clicked_focus_target != null:
				_focus_pending_target = clicked_focus_target
			if _interaction_controller.try_handle_interaction_click(event.position):
				get_viewport().set_input_as_handled()
				return
			if clicked_focus_target != null:
				_interaction_controller.request_approach_focus_target(clicked_focus_target)
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


func _handle_focus_mode_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_exit_focus_mode()
			get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _interaction_controller.try_handle_interaction_click(event.position):
				get_viewport().set_input_as_handled()
				return

			if _interaction_controller.try_interact_with_focus_target(event.position):
				get_viewport().set_input_as_handled()
				return

			if _interaction_controller.is_click_over_focus_items(event.position):
				get_viewport().set_input_as_handled()
				return

			_exit_focus_mode()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		get_viewport().set_input_as_handled()


func _process_pending_focus_entry() -> void:
	if _focus_mode:
		return
	if _focus_pending_target == null:
		return
	if not is_instance_valid(_focus_pending_target):
		_focus_pending_target = null
		return
	if _interaction_controller.can_enter_focus_target(_focus_pending_target):
		_enter_focus_mode(_focus_pending_target)
		_focus_pending_target = null


func _process_focus_mode() -> void:
	if not _focus_mode:
		return
	if _focus_target == null or not is_instance_valid(_focus_target):
		_exit_focus_mode()
		return
	if _focus_target.auto_exit_on_solved and _interaction_controller.is_focus_target_solved(_focus_target):
		_exit_focus_mode()


func _enter_focus_mode(target: FocusTargetType) -> void:
	if target == null:
		return
	_focus_mode = true
	_focus_target = target
	_focus_pending_target = null
	_saved_spring_length = spring_arm.spring_length
	player.clear_move_target()
	_interaction_controller.set_focus_locked(true)
	_interaction_controller.set_focus_display(true, camera)
	_interaction_controller.set_focus_target(_focus_target)
	_set_focus_visuals_enabled(false)
	var target_angles := _compute_focus_angles(target)
	_yaw = target_angles.x
	_pitch = target_angles.y
	_start_focus_tween(_focus_target.get_focus_position(), focus_zoom_distance)


func _exit_focus_mode() -> void:
	if not _focus_mode:
		return
	_focus_mode = false
	_focus_target = null
	_focus_pending_target = null
	_interaction_controller.set_focus_locked(false)
	_interaction_controller.set_focus_display(false, null)
	_interaction_controller.set_focus_target(null)
	_set_focus_visuals_enabled(true)
	_start_focus_tween(player.global_position + Vector3(0.0, 1.0, 0.0), _saved_spring_length)


func _start_focus_tween(target_pivot_position: Vector3, target_zoom: float) -> void:
	if _focus_tween != null:
		_focus_tween.kill()
	_focus_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_focus_tween.tween_property(camera_pivot, "global_position", target_pivot_position, focus_tween_duration)
	_focus_tween.parallel().tween_property(spring_arm, "spring_length", target_zoom, focus_tween_duration)
	_focus_tween.parallel().tween_property(camera_yaw, "rotation_degrees:y", _yaw, focus_tween_duration)
	_focus_tween.parallel().tween_property(camera_pitch, "rotation_degrees:x", _pitch, focus_tween_duration)


func _set_focus_visuals_enabled(is_enabled: bool) -> void:
	if _player_mesh != null:
		_player_mesh.visible = is_enabled
	_interaction_controller.set_held_item_visuals_visible(is_enabled or _focus_mode)


func _compute_focus_angles(target: FocusTargetType) -> Vector2:
	var host := target.get_parent() as Node3D
	var default_yaw := _yaw
	if host != null:
		default_yaw = wrapf(rad_to_deg(host.global_rotation.y) - 180.0, -180.0, 180.0)
	var desired_yaw := target.get_focus_yaw_degrees(default_yaw)
	var desired_pitch := target.get_focus_pitch_degrees(-22.0)
	return Vector2(desired_yaw, desired_pitch)


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
	if is_visible and _focus_mode:
		_exit_focus_mode()
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

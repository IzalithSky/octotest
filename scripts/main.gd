extends Node3D


const WALL_COLLISION_MASK := 1 << 0
const GROUND_COLLISION_MASK := 1 << 1
const INTERACTABLE_COLLISION_MASK := 1 << 3
const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"

@export var orbit_sensitivity := 0.2
@export var key_orbit_speed := 65.0
@export var min_zoom := 4.0
@export var max_zoom := 14.0
@export var zoom_step := 1.0
@export var interact_move_standoff := 1.2
@export var held_item_follow_speed := 15.0
@export var max_held_items := 8
@export var slow_at_item_count := 5
@export var immobilized_at_item_count := 8
@export var heavy_carry_speed_multiplier := 0.45
@export var hand_socket_inner_radius := 1.0
@export var hand_socket_outer_radius := 1.35
@export var hand_socket_height := 1.05

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

var _orbiting := false
var _yaw := 35.0
var _pitch := -35.0
var _hovered_interactable: Interactable
var _hovered_in_range := false
var _hovered_blocked := false
var _held_interactables: Array[Interactable] = []
var _hand_sockets: Array[Node3D] = []
var _held_socket_by_item_id: Dictionary = {}
var _queued_interaction_target: Interactable
var _light_toggle_on := true
var _default_light_energy := 4.0
var _base_move_speed := 6.0


func _ready() -> void:
	player.global_position = Vector3(0.0, 0.51, 0.0)
	_apply_camera_angles()
	_base_move_speed = player.move_speed
	_default_light_energy = room_light.light_energy
	_make_click_through(hud_root)
	_ensure_hand_sockets()
	_setup_scene_interactables()
	_update_carry_mobility()
	in_game_main_menu_button.pressed.connect(_on_main_menu_pressed)
	in_game_quit_button.pressed.connect(_on_quit_pressed)
	_set_in_game_menu_visible(false)
	_update_hint_text()


func _physics_process(delta: float) -> void:
	camera_pivot.global_position = player.global_position + Vector3(0.0, 1.0, 0.0)
	if in_game_menu.visible:
		_set_hovered_interactable(null, false, false)
		return

	_process_queued_interaction()
	_update_hovered_interactable()
	_update_held_item_transform(delta)

	if Input.is_key_pressed(KEY_Q):
		_yaw += key_orbit_speed * delta
		_apply_camera_angles()
	elif Input.is_key_pressed(KEY_E):
		_yaw -= key_orbit_speed * delta
		_apply_camera_angles()


func _unhandled_input(event: InputEvent) -> void:
	if _is_escape_press(event):
		_set_in_game_menu_visible(not in_game_menu.visible)
		get_viewport().set_input_as_handled()
		return

	if in_game_menu.visible:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _try_handle_interaction_click(event.position):
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

	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_F:
			if event.shift_pressed:
				_drop_all_held_items()
			else:
				_drop_last_held_item()
			get_viewport().set_input_as_handled()


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


func _raycast_to_interactable(screen_position: Vector2) -> Interactable:
	var from := camera.project_ray_origin(screen_position)
	var to := from + camera.project_ray_normal(screen_position) * 500.0

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = INTERACTABLE_COLLISION_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [player]

	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	if result.collider is Interactable:
		return result.collider as Interactable

	return null


func _try_handle_interaction_click(screen_position: Vector2) -> bool:
	var target := _raycast_to_interactable(screen_position)
	if target == null:
		_queued_interaction_target = null
		return false

	if _is_item_currently_held(target):
		_queued_interaction_target = null
		_drop_specific_held_item(target)
		return true

	var in_range := _is_interactable_in_range(target)
	var blocked := not _has_line_of_sight(target)
	if target.interaction_type == Interactable.InteractionType.PICKUP and _held_interactables.size() >= max_held_items:
		blocked = true
		in_range = false

	_set_hovered_interactable(target, in_range, blocked)

	if _hovered_blocked:
		return true

	if _hovered_in_range:
		_queued_interaction_target = null
		if target.interaction_type == Interactable.InteractionType.CLICK:
			target.interact(player)
			return true

		if target.interaction_type == Interactable.InteractionType.PICKUP:
			_pick_up_interactable(target)
			return true

		return true

	_queued_interaction_target = target
	_move_toward_interactable(target)
	return true


func _process_queued_interaction() -> void:
	if _queued_interaction_target == null:
		return

	if not is_instance_valid(_queued_interaction_target):
		_queued_interaction_target = null
		return

	if _is_item_currently_held(_queued_interaction_target):
		_queued_interaction_target = null
		return

	if not _has_line_of_sight(_queued_interaction_target):
		return

	if not _is_interactable_in_range(_queued_interaction_target):
		return

	if _queued_interaction_target.interaction_type == Interactable.InteractionType.PICKUP:
		if _held_interactables.size() >= max_held_items:
			_queued_interaction_target = null
			return
		_pick_up_interactable(_queued_interaction_target)
		_queued_interaction_target = null
		return

	if _queued_interaction_target.interaction_type == Interactable.InteractionType.CLICK:
		_queued_interaction_target.interact(player)
		_queued_interaction_target = null
		return


func _update_hovered_interactable() -> void:
	var target := _raycast_to_interactable(get_viewport().get_mouse_position())
	if target == null:
		_set_hovered_interactable(null, false, false)
		return

	if _is_item_currently_held(target):
		_set_hovered_interactable(target, true, false)
		return

	var in_range := _is_interactable_in_range(target)
	var blocked := not _has_line_of_sight(target)
	if target.interaction_type == Interactable.InteractionType.PICKUP and _held_interactables.size() >= max_held_items:
		blocked = true
		in_range = false

	_set_hovered_interactable(target, in_range, blocked)


func _set_hovered_interactable(target: Interactable, in_range: bool, blocked: bool) -> void:
	if _hovered_interactable != null and _hovered_interactable != target:
		if _is_item_currently_held(_hovered_interactable):
			_hovered_interactable.set_visual_state(Interactable.VisualState.HELD)
		else:
			_hovered_interactable.set_visual_state(Interactable.VisualState.IDLE)

	_hovered_interactable = target
	_hovered_in_range = in_range and not blocked
	_hovered_blocked = blocked

	if _hovered_interactable != null:
		if _is_item_currently_held(_hovered_interactable):
			_hovered_interactable.set_visual_state(Interactable.VisualState.HOVERED)
		elif _hovered_blocked:
			_hovered_interactable.set_visual_state(Interactable.VisualState.BLOCKED)
		elif _hovered_in_range:
			_hovered_interactable.set_visual_state(Interactable.VisualState.IN_RANGE)
		else:
			_hovered_interactable.set_visual_state(Interactable.VisualState.HOVERED)

	_update_hint_text()


func _is_interactable_in_range(target: Interactable) -> bool:
	return target.can_interact_from(player.global_position)


func _has_line_of_sight(target: Interactable) -> bool:
	var from: Vector3 = player.global_position + Vector3(0.0, 0.9, 0.0)
	var to: Vector3 = target.get_focus_position()
	var target_root := target.get_pickup_root()
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = WALL_COLLISION_MASK | INTERACTABLE_COLLISION_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [player]

	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true

	if result.collider == target or result.collider == target_root:
		return true

	return false


func _move_toward_interactable(target: Interactable) -> void:
	var player_pos: Vector3 = player.global_position
	var target_pos: Vector3 = target.get_focus_position()
	var away: Vector3 = player_pos - target_pos
	away.y = 0.0

	if away.length() <= 0.01:
		away = Vector3.BACK
	else:
		away = away.normalized()

	var move_position: Vector3 = target_pos + away * interact_move_standoff
	move_position.y = player_pos.y
	player.set_move_target(move_position)


func _pick_up_interactable(target: Interactable) -> void:
	if _held_interactables.size() >= max_held_items:
		return

	if _is_item_currently_held(target):
		return

	_held_interactables.append(target)
	_refresh_hand_socket_layout()

	var socket_index := int(_held_socket_by_item_id.get(target.get_instance_id(), -1))
	if socket_index < 0 or socket_index >= _hand_sockets.size():
		_held_interactables.erase(target)
		_refresh_hand_socket_layout()
		return

	var pickup_root := target.get_pickup_root()
	var socket := _hand_sockets[socket_index]
	pickup_root.reparent(socket, true)
	target.set_held(true)
	pickup_root.transform = target.get_hold_transform()
	target.interact(player)
	player.clear_move_target()
	_update_carry_mobility()
	_update_hint_text()


func _drop_last_held_item() -> void:
	if _held_interactables.is_empty():
		return

	_drop_held_item_by_index(_held_interactables.size() - 1)


func _drop_specific_held_item(item: Interactable) -> void:
	var index := _held_interactables.find(item)
	if index == -1:
		return
	_drop_held_item_by_index(index)


func _drop_all_held_items() -> void:
	while not _held_interactables.is_empty():
		_drop_held_item_by_index(_held_interactables.size() - 1)


func _drop_held_item_by_index(index: int) -> void:
	if index < 0 or index >= _held_interactables.size():
		return

	var item := _held_interactables[index]
	_held_interactables.remove_at(index)
	_refresh_hand_socket_layout()

	var pickup_root := item.get_pickup_root()
	pickup_root.reparent(self, true)
	item.set_held(false)
	item.drop(player)

	var lateral_offset := player.global_basis.x * (0.2 * float(index % 3 - 1))
	var drop_position: Vector3 = player.global_position + player.global_basis.z * 1.25 + Vector3(0.0, 0.6, 0.0) + lateral_offset
	pickup_root.global_position = drop_position
	if pickup_root is RigidBody3D:
		var body := pickup_root as RigidBody3D
		body.linear_velocity = player.velocity * 0.35 + Vector3(0.0, 0.5, 0.0)

	if _hovered_interactable == item:
		_set_hovered_interactable(null, false, false)

	_update_carry_mobility()
	_update_hint_text()


func _update_held_item_transform(delta: float) -> void:
	if _held_interactables.is_empty():
		return

	var alpha := minf(1.0, held_item_follow_speed * delta)
	for held_item in _held_interactables:
		var socket_index := int(_held_socket_by_item_id.get(held_item.get_instance_id(), -1))
		if socket_index < 0 or socket_index >= _hand_sockets.size():
			continue
		var pickup_root := held_item.get_pickup_root()
		var socket := _hand_sockets[socket_index]
		var target_transform := socket.global_transform * held_item.get_hold_transform()
		pickup_root.global_transform = pickup_root.global_transform.interpolate_with(target_transform, alpha)


func _ensure_hand_sockets() -> void:
	var sockets_root: Node3D = player.get_node_or_null("HandSockets") as Node3D
	if sockets_root == null:
		sockets_root = Node3D.new()
		sockets_root.name = "HandSockets"
		player.add_child(sockets_root)

	var existing_count := sockets_root.get_child_count()
	for i in range(existing_count, max_held_items):
		var socket := Node3D.new()
		socket.name = "HandSocket%d" % i
		sockets_root.add_child(socket)

	_hand_sockets.clear()
	var child_index := 0
	for child in sockets_root.get_children():
		if child_index >= max_held_items:
			break
		if child is Node3D:
			_hand_sockets.append(child as Node3D)
			child_index += 1

	_refresh_hand_socket_layout()


func _refresh_hand_socket_layout() -> void:
	_held_socket_by_item_id.clear()

	var held_count := _held_interactables.size()
	if held_count == 0:
		for i in range(_hand_sockets.size()):
			var idle_socket := _hand_sockets[i]
			idle_socket.position = Vector3(0.0, hand_socket_height, 0.0)
		return

	for i in range(held_count):
		_held_socket_by_item_id[_held_interactables[i].get_instance_id()] = i

	var inner_count := mini(held_count, 4)
	var outer_count := maxi(held_count - inner_count, 0)

	for i in range(_hand_sockets.size()):
		var socket := _hand_sockets[i]
		if i >= held_count:
			socket.position = Vector3(0.0, hand_socket_height, 0.0)
			continue

		var ring_index := 0
		var slot_index := i
		var slots_in_ring := inner_count
		var radius := hand_socket_inner_radius
		var height_offset := 0.0
		if i >= inner_count:
			ring_index = 1
			slot_index = i - inner_count
			slots_in_ring = maxi(outer_count, 1)
			radius = hand_socket_outer_radius
			height_offset = 0.2

		var angle_offset := 0.0 if ring_index == 0 else PI / float(slots_in_ring)
		var angle := TAU * float(slot_index) / float(slots_in_ring) + angle_offset
		var local_pos := Vector3(cos(angle) * radius, hand_socket_height + height_offset, sin(angle) * radius)
		socket.position = local_pos

		var outward := Vector3(local_pos.x, 0.0, local_pos.z).normalized()
		if outward.length() > 0.001:
			socket.rotation.y = atan2(outward.x, outward.z)


func _is_item_currently_held(item: Interactable) -> bool:
	if item == null:
		return false
	return _held_socket_by_item_id.has(item.get_instance_id())


func _update_carry_mobility() -> void:
	var held_count := _held_interactables.size()
	if held_count >= immobilized_at_item_count:
		player.move_speed = 0.0
		player.clear_move_target()
	elif held_count >= slow_at_item_count:
		player.move_speed = _base_move_speed * heavy_carry_speed_multiplier
	else:
		player.move_speed = _base_move_speed


func _setup_scene_interactables() -> void:
	var button := get_node_or_null("Interactables/LightButton/Interactable") as Interactable
	if button == null:
		return

	var handler := _on_button_clicked.bind(button.get_parent() as StaticBody3D)
	if not button.clicked.is_connected(handler):
		button.clicked.connect(handler)


func _update_hint_text() -> void:
	var lines := PackedStringArray([
		"LMB Move / Interact",
		"RMB + Drag Orbit",
		"Q/E Keyboard Orbit",
		"Mouse Wheel Zoom",
		"F Drop Last Item",
		"Shift+F Drop All Items",
		"Esc In-Game Menu"
	])

	if _hovered_interactable != null:
		if _is_item_currently_held(_hovered_interactable):
			lines.append("LMB Drop %s" % _hovered_interactable.display_name)
		elif _hovered_blocked:
			lines.append("Blocked: %s" % _hovered_interactable.display_name)
		elif _hovered_in_range:
			lines.append("LMB %s %s" % [_hovered_interactable.prompt_action, _hovered_interactable.display_name])
		else:
			lines.append("%s is out of range" % _hovered_interactable.display_name)
			lines.append("LMB Move Closer")

	lines.append("Held: %d/%d" % [_held_interactables.size(), max_held_items])
	if _held_interactables.size() >= immobilized_at_item_count:
		lines.append("Overloaded: cannot move")
	elif _held_interactables.size() >= slow_at_item_count:
		lines.append("Heavy carry: movement slowed")
	if _queued_interaction_target != null and is_instance_valid(_queued_interaction_target):
		lines.append("Auto-interact queued: %s" % _queued_interaction_target.display_name)

	hint_label.text = "\n".join(lines)


func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


func _on_button_clicked(_interactable: Interactable, _actor: Node, button_body: StaticBody3D) -> void:
	_light_toggle_on = not _light_toggle_on
	room_light.light_energy = _default_light_energy if _light_toggle_on else 0.35

	if button_body.has_node("MeshInstance3D"):
		var mesh := button_body.get_node("MeshInstance3D") as MeshInstance3D
		var mat := _make_material(
			Color(0.84, 0.24, 0.2, 1.0) if _light_toggle_on else Color(0.36, 0.36, 0.38, 1.0),
			0.5
		)
		mesh.material_override = mat


func _is_escape_press(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo and event.keycode == KEY_ESCAPE
	return false


func _set_in_game_menu_visible(is_visible: bool) -> void:
	in_game_menu.visible = is_visible
	_orbiting = false
	if is_visible:
		_set_hovered_interactable(null, false, false)
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

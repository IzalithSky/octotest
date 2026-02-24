extends Node
class_name InteractionController


const WALL_COLLISION_MASK := 1 << 0
const INTERACTABLE_COLLISION_MASK := 1 << 3
const CardReaderType = preload("res://scripts/card_reader.gd")

@export var interact_move_standoff := 1.2
@export var held_item_follow_speed := 15.0
@export var max_held_items := 8
@export var slow_at_item_count := 5
@export var immobilized_at_item_count := 8
@export var heavy_carry_speed_multiplier := 0.45
@export var hand_socket_inner_radius := 1.0
@export var hand_socket_outer_radius := 1.35
@export var hand_socket_height := 1.05
@export var drop_clamp_extent := 15.2

var _player: CharacterBody3D
var _camera: Camera3D
var _hint_label: Label
var _world_root: Node3D
var _room_light: OmniLight3D

var _interaction_enabled := true
var _hovered_interactable: Interactable
var _hovered_in_range := false
var _hovered_blocked := false
var _held_interactables: Array[Interactable] = []
var _hand_sockets: Array[Node3D] = []
var _held_socket_by_item_id: Dictionary = {}
var _queued_interaction_target: Interactable
var _pending_card_reader: CardReaderType
var _awaiting_card_selection := false
var _eligible_held_cards: Array[Interactable] = []
var _selection_markers: Dictionary = {}
var _light_toggle_on := true
var _default_light_energy := 4.0
var _base_move_speed := 6.0


func initialize(player: CharacterBody3D, camera: Camera3D, hint_label: Label, world_root: Node3D, room_light: OmniLight3D) -> void:
	_player = player
	_camera = camera
	_hint_label = hint_label
	_world_root = world_root
	_room_light = room_light
	_base_move_speed = _player.move_speed
	_default_light_energy = _room_light.light_energy
	_ensure_hand_sockets()
	_setup_scene_interactables()
	_update_carry_mobility()
	_update_hint_text()


func set_interaction_enabled(is_enabled: bool) -> void:
	if _interaction_enabled == is_enabled:
		return
	_interaction_enabled = is_enabled
	if not _interaction_enabled:
		_cancel_card_selection_mode()
		_set_hovered_interactable(null, false, false)


func process_interactions(delta: float) -> void:
	if not _interaction_enabled:
		return
	_process_queued_interaction()
	_update_hovered_interactable()
	_update_held_item_transform(delta)


func consume_escape() -> bool:
	if _awaiting_card_selection:
		_cancel_card_selection_mode()
		return true
	return false


func try_handle_interaction_click(screen_position: Vector2) -> bool:
	if not _interaction_enabled:
		return false

	var target := _raycast_to_interactable(screen_position)

	if _awaiting_card_selection:
		if target != null and _is_item_currently_held(target) and _eligible_held_cards.has(target):
			_apply_card_to_pending_reader(target)
			return true
		if target != null and _get_card_reader_for_interactable(target) == _pending_card_reader:
			_cancel_card_selection_mode()
			return true
		_update_hint_text()
		return true

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
		var reader := _get_card_reader_for_interactable(target)
		if reader != null:
			_handle_card_reader_click(reader)
			return true
		if target.interaction_type == Interactable.InteractionType.CLICK:
			target.interact(_player)
			return true
		if target.interaction_type == Interactable.InteractionType.PICKUP:
			_pick_up_interactable(target)
			return true
		return true

	_queued_interaction_target = target
	_move_toward_interactable(target)
	return true


func handle_drop_input(drop_all: bool) -> void:
	if drop_all:
		_drop_all_held_items()
	else:
		_drop_last_held_item()


func _raycast_to_interactable(screen_position: Vector2) -> Interactable:
	var from := _camera.project_ray_origin(screen_position)
	var to := from + _camera.project_ray_normal(screen_position) * 500.0

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = INTERACTABLE_COLLISION_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [_player]

	var result := _world_root.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	if result.collider is Interactable:
		return result.collider as Interactable
	return null


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
		var reader := _get_card_reader_for_interactable(_queued_interaction_target)
		if reader != null:
			_handle_card_reader_click(reader)
			_queued_interaction_target = null
			return
		_queued_interaction_target.interact(_player)
		_queued_interaction_target = null


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


func _get_card_reader_for_interactable(target: Interactable) -> CardReaderType:
	if target == null:
		return null
	var parent := target.get_parent()
	if parent is CardReaderType:
		return parent as CardReaderType
	return null


func _handle_card_reader_click(reader: CardReaderType) -> void:
	if reader == null:
		return

	if reader.has_inserted_card():
		var held_cards := _get_held_cards()
		if not held_cards.is_empty():
			if held_cards.size() == 1:
				_pending_card_reader = reader
				_apply_card_to_pending_reader(held_cards[0])
			else:
				_enter_card_selection_mode(reader, held_cards)
			return

		if _held_interactables.size() >= max_held_items:
			_update_hint_text()
			return
		var ejected_card := reader.eject_card()
		if ejected_card != null:
			_attach_item_to_hands(ejected_card, false)
		_cancel_card_selection_mode()
		_update_hint_text()
		return

	var held_cards := _get_held_cards()
	if held_cards.is_empty():
		_cancel_card_selection_mode()
		_update_hint_text()
		return

	if held_cards.size() == 1:
		_pending_card_reader = reader
		_apply_card_to_pending_reader(held_cards[0])
		return

	_enter_card_selection_mode(reader, held_cards)


func _get_held_cards() -> Array[Interactable]:
	var cards: Array[Interactable] = []
	for held_item in _held_interactables:
		if held_item.is_card():
			cards.append(held_item)
	return cards


func _enter_card_selection_mode(reader: CardReaderType, held_cards: Array[Interactable]) -> void:
	_cancel_card_selection_mode()
	_pending_card_reader = reader
	_awaiting_card_selection = true
	_eligible_held_cards = held_cards.duplicate()

	for card in _eligible_held_cards:
		card.set_visual_state(Interactable.VisualState.IN_RANGE)
		var marker := Label3D.new()
		marker.text = "?"
		marker.position = Vector3(0.0, 0.45, 0.0)
		marker.modulate = Color(1.0, 0.94, 0.28, 1.0)
		marker.outline_modulate = Color(0.1, 0.1, 0.1, 1.0)
		card.get_pickup_root().add_child(marker)
		_selection_markers[card.get_instance_id()] = marker

	_update_hint_text()


func _cancel_card_selection_mode() -> void:
	_awaiting_card_selection = false
	_pending_card_reader = null
	for marker in _selection_markers.values():
		if marker is Node and is_instance_valid(marker):
			(marker as Node).queue_free()
	_selection_markers.clear()
	for card in _eligible_held_cards:
		if card != null and is_instance_valid(card):
			card.set_visual_state(Interactable.VisualState.HELD)
	_eligible_held_cards.clear()
	_update_hint_text()


func _apply_card_to_pending_reader(card: Interactable) -> void:
	if _pending_card_reader == null or card == null:
		_cancel_card_selection_mode()
		return
	if not _is_item_currently_held(card):
		_cancel_card_selection_mode()
		return
	if not _pending_card_reader.can_accept_card(card):
		_update_hint_text()
		return

	if _pending_card_reader.has_inserted_card():
		var previous_card := _pending_card_reader.eject_card()
		if previous_card != null:
			_attach_item_to_hands(previous_card, false)

	var removed_card := _remove_held_item(card)
	if removed_card == null:
		_cancel_card_selection_mode()
		return

	removed_card.set_held(true)
	if not _pending_card_reader.insert_card(removed_card):
		_attach_item_to_hands(removed_card, false)

	_cancel_card_selection_mode()
	_update_hint_text()


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
	return target.can_interact_from(_player.global_position)


func _has_line_of_sight(target: Interactable) -> bool:
	var from: Vector3 = _player.global_position + Vector3(0.0, 0.9, 0.0)
	var to: Vector3 = target.get_focus_position()
	var target_root := target.get_pickup_root()
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = WALL_COLLISION_MASK | INTERACTABLE_COLLISION_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [_player]

	var result := _world_root.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true
	if result.collider == target or result.collider == target_root:
		return true
	return false


func _move_toward_interactable(target: Interactable) -> void:
	var player_pos: Vector3 = _player.global_position
	var target_pos: Vector3 = target.get_focus_position()
	var away: Vector3 = player_pos - target_pos
	away.y = 0.0

	if away.length() <= 0.01:
		away = Vector3.BACK
	else:
		away = away.normalized()

	var standoff := interact_move_standoff
	if _get_card_reader_for_interactable(target) != null:
		standoff = maxf(standoff, 2.6)

	var move_position: Vector3 = target_pos + away * standoff
	move_position.y = player_pos.y
	_player.set_move_target(move_position)


func _pick_up_interactable(target: Interactable) -> void:
	if _held_interactables.size() >= max_held_items or _is_item_currently_held(target):
		return

	if not _attach_item_to_hands(target, true):
		return

	target.interact(_player)
	_player.clear_move_target()
	_cancel_card_selection_mode()


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
	item = _remove_held_item(item)
	if item == null:
		return

	var pickup_root := item.get_pickup_root()
	pickup_root.reparent(_world_root, true)
	item.set_held(false)
	item.drop(_player)

	var lateral_offset := _player.global_basis.x * (0.2 * float(index % 3 - 1))
	var drop_position: Vector3 = _player.global_position + _player.global_basis.z * 1.25 + Vector3(0.0, 0.6, 0.0) + lateral_offset
	drop_position.x = clampf(drop_position.x, -drop_clamp_extent, drop_clamp_extent)
	drop_position.z = clampf(drop_position.z, -drop_clamp_extent, drop_clamp_extent)
	pickup_root.global_position = drop_position
	if pickup_root is RigidBody3D:
		var body := pickup_root as RigidBody3D
		body.linear_velocity = _player.velocity * 0.35 + Vector3(0.0, 0.5, 0.0)

	if _hovered_interactable == item:
		_set_hovered_interactable(null, false, false)

	_cancel_card_selection_mode()
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
	var sockets_root: Node3D = _player.get_node_or_null("HandSockets") as Node3D
	if sockets_root == null:
		sockets_root = Node3D.new()
		sockets_root.name = "HandSockets"
		_player.add_child(sockets_root)

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
		for socket in _hand_sockets:
			socket.position = Vector3(0.0, hand_socket_height, 0.0)
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


func _remove_held_item(item: Interactable) -> Interactable:
	if item == null:
		return null
	var index := _held_interactables.find(item)
	if index == -1:
		return null
	_held_interactables.remove_at(index)
	_refresh_hand_socket_layout()
	_update_carry_mobility()
	return item


func _attach_item_to_hands(item: Interactable, clear_motion_target: bool) -> bool:
	if item == null:
		return false
	if _held_interactables.size() >= max_held_items:
		return false
	if _is_item_currently_held(item):
		return true

	_held_interactables.append(item)
	_refresh_hand_socket_layout()

	var socket_index := int(_held_socket_by_item_id.get(item.get_instance_id(), -1))
	if socket_index < 0 or socket_index >= _hand_sockets.size():
		_held_interactables.erase(item)
		_refresh_hand_socket_layout()
		return false

	var pickup_root := item.get_pickup_root()
	var socket := _hand_sockets[socket_index]
	pickup_root.reparent(socket, true)
	item.set_interaction_enabled(true)
	item.set_held(true)
	pickup_root.transform = item.get_hold_transform()

	if clear_motion_target:
		_player.clear_move_target()

	_update_carry_mobility()
	return true


func _update_carry_mobility() -> void:
	var held_count := _held_interactables.size()
	if held_count >= immobilized_at_item_count:
		_player.move_speed = 0.0
		_player.clear_move_target()
	elif held_count >= slow_at_item_count:
		_player.move_speed = _base_move_speed * heavy_carry_speed_multiplier
	else:
		_player.move_speed = _base_move_speed


func _setup_scene_interactables() -> void:
	var button := _world_root.get_node_or_null("Interactables/LightButton/Interactable") as Interactable
	if button == null:
		return

	var handler := _on_button_clicked.bind(button.get_parent() as StaticBody3D)
	if not button.clicked.is_connected(handler):
		button.clicked.connect(handler)


func _update_hint_text() -> void:
	if _hint_label == null:
		return

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
	if _awaiting_card_selection and _pending_card_reader != null:
		lines.append("Card Reader: choose held card (click card in hands)")

	_hint_label.text = "\n".join(lines)


func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


func _on_button_clicked(_interactable: Interactable, _actor: Node, button_body: StaticBody3D) -> void:
	_light_toggle_on = not _light_toggle_on
	_room_light.light_energy = _default_light_energy if _light_toggle_on else 0.35

	if button_body.has_node("MeshInstance3D"):
		var mesh := button_body.get_node("MeshInstance3D") as MeshInstance3D
		mesh.material_override = _make_material(
			Color(0.84, 0.24, 0.2, 1.0) if _light_toggle_on else Color(0.36, 0.36, 0.38, 1.0),
			0.5
		)

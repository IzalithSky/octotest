extends SceneTree


const TEST_WORLD_SCENE = preload("res://tests/slope_movement_test_scene.tscn")
const SETTLE_FRAMES := 20
const MOVE_FRAMES := 220

var _failures := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := TEST_WORLD_SCENE.instantiate()
	root.add_child(world)

	var player := world.get_node("Player") as CharacterBody3D
	if player == null:
		_failures += 1
		printerr("FAIL: player node missing in slope test scene")
		_finish()
		return

	for i in range(SETTLE_FRAMES):
		await physics_frame

	var start_y := player.global_position.y
	player.call("set_move_target", Vector3(0.0, 0.0, 9.0))

	for i in range(MOVE_FRAMES):
		await physics_frame

	var uphill_y := player.global_position.y
	_expect_true(uphill_y > start_y + 1.0, "player should climb upward while moving onto ramp")
	_expect_true(player.is_on_floor(), "player should remain grounded while climbing slope")

	player.call("set_move_target", Vector3(0.0, 0.0, -6.0))

	for i in range(MOVE_FRAMES):
		await physics_frame

	var downhill_y := player.global_position.y
	_expect_true(downhill_y < uphill_y - 1.0, "player should descend after moving back down ramp")
	_expect_true(absf(downhill_y - 0.5) < 0.35, "player should settle near floor height after descent")
	_expect_true(player.is_on_floor(), "player should be on floor at end of slope test")

	world.queue_free()
	await process_frame
	_finish()


func _expect_true(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	printerr("FAIL: ", message)


func _finish() -> void:
	if _failures == 0:
		print("slope_movement_test: PASS")
		quit(0)
		return

	printerr("slope_movement_test: FAIL (%d failures)" % _failures)
	quit(1)

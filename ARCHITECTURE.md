# Project Architecture

This document describes the current runtime architecture of the prototype and must be updated when structural changes are made.

## High-Level Runtime

1. `res://scenes/main.tscn` is the main scene.
2. `Main` (`Node3D`) owns world setup, camera behavior, and click-to-move input routing.
3. `Player` (`CharacterBody3D`) owns locomotion, gravity handling, and slope alignment.
4. `Room` contains authored static geometry (floor, ceiling, walls, ramps, windows).
5. `WorldEnvironment` provides sky/background visuals visible through wall openings.

## Scene Graph Responsibilities

1. `Main`:
- Script: `res://scripts/main.gd`
- Handles mouse raycast targeting on ground collision layer.
- Handles orbit camera controls (RMB drag, Q/E yaw, wheel zoom).
2. `WorldEnvironment`:
- Provides procedural sky and ambient environment settings.
3. `Room`:
- `Floor` uses ground collision layer for click-to-move raycast targeting.
- `Ceiling` and wall pieces use wall collision layer for physical boundaries.
- North/south walls are segmented to create real window openings.
- `Window*` nodes are transparent collidable blocks filling window apertures.
- `RampWest`/`RampEast` provide slope traversal test surfaces.
4. `Player`:
- Uses `CollisionShape3D` + visible cube mesh.
- Updated each physics frame by `player_controller.gd`.
5. Camera rig:
- `CameraPivot -> CameraYaw -> CameraPitch -> SpringArm3D -> Camera3D`.
- Pivot follows player position.

## Script Architecture

1. `res://scripts/main.gd`
- Input and camera orchestration.
- Converts screen click to world target via physics raycast.
- Calls `Player.set_move_target()`.
2. `res://scripts/player_controller.gd`
- Character movement state (`_target_position`, `_has_target`).
- Gravity and grounded handling.
- Uses `MovementMath.next_velocity_2d()` for planar acceleration/deceleration.
- Uses `MovementMath.project_planar_direction_on_surface()` to keep movement stable on slopes.
3. `res://scripts/movement_math.gd`
- Pure helper math (no scene dependencies).
- Designed for headless logic testing.

## Movement Data Flow

1. User clicks floor/ramp.
2. `main.gd` raycasts against ground layer and sends target to player.
3. `player_controller.gd` computes planar velocity toward target.
4. If grounded, planar direction is projected onto floor tangent for slope handling.
5. Gravity is applied when airborne.
6. `move_and_slide()` resolves motion/collision.

## Test Architecture

1. `res://tests/movement_math_test.gd`
- Pure logic tests for `movement_math.gd` helpers.
2. `res://tests/slope_movement_test.gd`
- Headless integration test validating uphill/downhill traversal with gravity.
- Uses `res://tests/slope_movement_test_scene.tscn`.

## Extension Points

1. Add new gameplay math to `movement_math.gd` first when testable in isolation.
2. Add physics integration tests under `tests/` for interaction-heavy behavior.
3. Keep room geometry authored in scene files when editor visibility matters.

## Update Policy

When changing scene hierarchy, collision layers, movement flow, or test strategy:

1. Update this file in the same branch/commit set.
2. Update `PROCEDURES.md` only if workflow expectations also change.
3. Add a `DEVLOG.md` entry summarizing architectural impact.

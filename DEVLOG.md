# Dev Log

## 2026-02-23

### Step 1 - Project bootstrap
- Confirmed this is an empty Godot 4.6 template project.
- Created baseline folders: `scenes/`, `scripts/`, `tests/`.
- Plan: implement runtime-built 3D cube room, point-and-click player movement with gravity, orbit camera via SpringArm3D, and headless logic tests for movement math.

### Step 2 - Core prototype implementation
- Added `scripts/movement_math.gd` with pure movement logic (`arrived_2d`, `next_velocity_2d`).
- Added `scripts/player_controller.gd`:
  - `CharacterBody3D` click-target movement.
  - Gravity from project settings.
  - Runtime-created cube mesh + collision shape.
- Added `scripts/main.gd`:
  - Runtime cube room (floor, ceiling, 4 walls) with collisions.
  - Point-and-click floor raycast movement.
  - Orbit camera around player with `SpringArm3D` (RMB drag + Q/E orbit, wheel zoom).
- Added `scenes/main.tscn` with player + camera rig + light and script bindings.
- Updated `project.godot` to run `res://scenes/main.tscn`.

### Step 3 - Unit-testable sanity checks
- Added `tests/movement_math_test.gd` for headless movement math validation.
- Next: run `Godot_v4.6.1-stable_linux.x86_64 --headless --script res://tests/movement_math_test.gd` and fix any issues.

### Step 4 - Verification and hardening
- Headless test initially crashed because the sandbox blocked default Godot user paths.
- Resolved test runtime by launching Godot with `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp`.
- Found/Fixed strict typing parse issue in `scripts/main.gd`:
  - Replaced `Variant`-inferred click position with explicit `Vector3` flow.
  - `_raycast_to_ground()` now returns `Vector3` and uses `Vector3.INF` as a no-hit sentinel.

### Validation commands (pass)
1. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --quit-after 5`
   - Result: project boots in headless mode with no script errors.
2. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/movement_math_test.gd`
   - Result: `movement_math_test: PASS`.

### Current status
- Prototype functionality implemented and sanity-checked.
- Dev log is current and can be used to resume from this point.

### Step 5 - Fix visibility and collision-shape authoring
- User-reported issue: scene looked transparent in editor, runtime view was black, and player warned for missing collision shape.
- Root causes:
  - Room/player visuals and collision were generated in `_ready()`, so editor had no authored geometry.
  - Enclosed room could render very dark without an interior light source.
- Fixes:
  - Converted room + player to explicit authored nodes in `scenes/main.tscn`.
  - Added real `CollisionShape3D` and `MeshInstance3D` under `Player`.
  - Added static bodies and collision/mesh children for floor, ceiling, and 4 walls.
  - Added an `OmniLight3D` inside the room.
  - Simplified scripts:
    - Removed runtime room construction from `scripts/main.gd`.
    - Removed runtime mesh/collision creation from `scripts/player_controller.gd`.
- Revalidated:
  - Headless project boot passes.
  - `movement_math_test` still passes.

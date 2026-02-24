# Dev Log

## 2026-02-24

### Step 17 - GDD review and clarifications

Full review of `docs/GDD.md`. Resolved open design questions and corrected structural issues:

- **Catch/return behaviour**: world state preserved on catch, no cooldown, room puzzle progress resets.
- **Movement**: Octo walks on surfaces inside the station; swimming only in outdoor open-water sections.
- **Save system**: autosave on entering each new room; players can quit and resume.
- **Collectibles**: objects are actionable or not (visually distinct, no UI); fancy things occupy arm slots, no separate inventory.
- **Controls**: PC-first target documented; iPad/Mac input deferred to post-PC review. Removed swipe/pinch references.
- **Scope**: World Bible (Blue Current Research Facility) is now the explicit source of truth for rooms and layout.
- **Arm system**: removed biology breakdown table; simplified to 8 arms with specialisation deferred to prototyping.
- **Roadmap**: added missing Step 5 (pick up / carry / set down); deferred iPad touch input note.
- **TASK_LIST.md**: updated Milestone 5 to reflect PC-first export order and removed iPad-specific performance target.

No code changes. Design docs only.

## 2026-02-23

### Step 16 - Update project icon to octopus PNG
- Updated Godot application icon to use PNG asset:
  - `project.godot` -> `config/icon="res://icon.png"`
- Added icon asset file:
  - `icon.png` (single source for Godot project icon and Git/SourceTree usage)
- Validation:
  - Ran `./scripts/check.sh` -> PASS.

### Step 15 - Import Gone Exploring design docs and split backlog
- Imported the provided source doc into project docs as the initial canonical GDD:
  - `docs/GDD.md`
- Split planning into a separate editable backlog tailored to current repo baseline:
  - `docs/TASK_LIST.md`
- Updated top-level docs map (`docs/README.md`) to link the new game docs.
- Note: `docs/GDD.md` was later refined in-repo (task-list removal, image removal, and tangle marked optional/post-MVP).

### Step 14 - Portable Godot binary detection and docs sync
- Updated `scripts/check.sh` binary resolution to support cross-device setups without per-run path overrides.
- Detection order now:
  - `GODOT_BIN` override
  - `godot4` in `PATH`
  - `godot` in `PATH`
  - `Godot` in `PATH`
  - `/Applications/Godot.app/Contents/MacOS/Godot` (macOS app install)
  - `/ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64` (legacy Linux fallback)
- Updated docs to match current behavior:
  - `docs/README.md`
  - `docs/PROCEDURES.md`
  - `docs/TESTING.md`

### Validation commands (pass)
1. `./scripts/check.sh`
   - Result: boot smoke test + movement math test + slope integration test all passed.

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

### Step 6 - Session procedure documentation
- Added `PROCEDURES.md` with AI-agent session initialization rules.
- Documented:
  - Project/Godot paths and startup commands.
  - Branch policy (feature/fix branches, keep `main` stable).
  - Testing policy (always add/update tests where possible, run headless checks).
  - Dev log maintenance requirements.
  - Known pitfalls discovered in this project so far.
- Purpose: reduce re-onboarding time and prevent repeated setup mistakes in future sessions.

### Step 7 - Slope/ramp test branch and movement validation
- Created branch: `feat/slope-ramps`.
- Added authored ramps to main scene (`scenes/main.tscn`) to test slope traversal in gameplay:
  - `Room/RampWest`
  - `Room/RampEast`
- Ramps are on ground collision layer (`collision_layer = 2`) so point-and-click raycasts can target them.
- Added slope-related movement helper in `scripts/movement_math.gd`:
  - `project_planar_direction_on_surface(direction, surface_normal)`
- Updated `scripts/player_controller.gd` to align planar movement direction with floor slope when grounded.
- Expanded unit tests in `tests/movement_math_test.gd` with slope projection checks.
- Added headless physics integration test assets:
  - `tests/slope_movement_test_scene.tscn`
  - `tests/slope_movement_test.gd`
- Found/fixed a ramp placement issue during testing (initially too high above floor, causing failed uphill/downhill checks).

### Validation commands (pass)
1. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --quit-after 5`
2. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/movement_math_test.gd`
3. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/slope_movement_test.gd`

### Step 14 - Main menu and in-game UI
- Added startup menu scene and script:
  - `scenes/main_menu.tscn`
  - `scripts/main_menu.gd`
- Main menu has `Play` and `Quit` actions.
- Switched startup scene in `project.godot`:
  - `run/main_scene="res://scenes/main_menu.tscn"`
- Added gameplay UI under `scenes/main.tscn`:
  - HUD key-hint panel anchored in a corner.
  - In-game menu with `Main Menu` and `Quit` buttons.
- Updated `scripts/main.gd`:
  - `Esc` toggles in-game menu visibility.
  - Menu visibility blocks gameplay input while open.
  - HUD controls are forced to `MOUSE_FILTER_IGNORE` so gameplay remains clickable through hint UI.
  - Added scene return (`Main Menu`) and app quit handlers.
- Updated docs for the new scene flow and manual QA:
  - `docs/README.md`
  - `docs/ARCHITECTURE.md`
  - `docs/PROCEDURES.md`
  - `docs/TESTING.md`

### Validation commands (pass)
1. `./scripts/check.sh`
   - Result: boot smoke test PASS, `movement_math_test: PASS`, `slope_movement_test: PASS`.

### Step 13 - Stair implementation research note
- Added `docs/misc/STAIRS.md` with a practical Godot stair-handling guide.
- Documented the most reliable pattern seen in practice:
  - pre-move step-up probe,
  - normal `move_and_slide()`,
  - post-move step-down probe.
- Included parameter tuning guidance (`step_height_max`, `floor_snap_length`, `safe_margin`) and geometry pitfalls.
- Linked the new note from `docs/README.md` so it is discoverable during session restarts.

### Step 11 - Canonical branch reset and restart hardening
- Synced `main` with latest work (merged prior `master` history forward into `main`).
- Set workflow docs to treat `main` as canonical stable branch.
- Added missing restart docs:
  - `README.md` (quickstart, controls, run/validate commands, docs map).
  - `TESTING.md` (automated + manual visual QA checklist).
- Added unified validation script:
  - `scripts/check.sh` (boot smoke + movement math test + slope integration test).
- Added additional hard-won pitfalls not previously centralized:
  - Transparent windows need real wall openings to reveal sky.
  - Ramp base alignment matters; floating ramps cause false slope failures.
- Validation:
  - Ran `./scripts/check.sh` -> PASS.

### Step 12 - Reorganize textures and docs folders
- Moved texture assets:
  - `icon.svg` -> `assets/textures/icon.svg`
  - `icon.svg.import` -> `assets/textures/icon.svg.import`
- Updated `project.godot` icon path to `res://assets/textures/icon.svg`.
- Moved documentation files under `docs/`:
  - `docs/README.md`
  - `docs/PROCEDURES.md`
  - `docs/ARCHITECTURE.md`
  - `docs/TESTING.md`
  - `docs/DEVLOG.md`
- Updated doc cross-references to use `docs/...` paths from project root.

### Step 10 - Merge room-window visuals and add architecture docs
- Merged `feat/room-scale-windows` into `master` (fast-forward).
- Added `ARCHITECTURE.md` documenting:
  - Scene hierarchy responsibilities.
  - Script/module boundaries.
  - Movement data flow.
  - Test architecture and extension points.
- Updated `PROCEDURES.md` to require architecture maintenance:
  - Session init now includes reading `ARCHITECTURE.md`.
  - Added dedicated architecture maintenance rules.
  - End-of-session checklist now requires architecture doc updates for structural changes.

### Step 8 - Room scale and glass windows pass
- Created branch: `feat/room-scale-windows`.
- Updated authored room dimensions in `scenes/main.tscn`:
  - Floor expanded from 20x20 to 32x32.
  - Wall height increased from 6 to 9.
  - Ceiling raised accordingly.
- Added four collidable transparent window blocks on north/south walls:
  - `WindowNorthLeft`, `WindowNorthRight`, `WindowSouthLeft`, `WindowSouthRight`.
  - Added dedicated transparent glass-like material (`StandardMaterial3D_window`).
- Slightly moved ramps farther from center to keep room flow balanced in larger layout.
- Increased interior omni light height/range/energy to better illuminate the larger volume.

### Validation commands (pass)
1. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --quit-after 5`
2. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/movement_math_test.gd`
3. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/slope_movement_test.gd`

### Step 9 - Window openings + visual palette refresh
- Reworked room wall authoring in `scenes/main.tscn`:
  - Replaced monolithic north/south walls with segmented wall blocks around each window aperture.
  - Result: actual holes exist behind window blocks, so outside sky is visible through glass.
- Added `WorldEnvironment` with procedural sky so openings show a proper sky backdrop.
- Retuned room materials to a muted, less depressing color palette (non-acidic, lower contrast than player):
  - Wall: soft blue-gray.
  - Floor: desaturated slate.
  - Ceiling: warm neutral.
  - Ramp: muted green-gray.
  - Window glass: softer cyan tint.

### Validation commands (pass)
1. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --quit-after 5`
2. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/movement_math_test.gd`
3. `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/slope_movement_test.gd`

# Stair Movement Notes (Godot 4.x)

This note captures practical stair handling patterns for `CharacterBody3D` projects where default slope settings are not enough.

## Core Problem

`move_and_slide()` handles slopes well, but true stairs have vertical risers that are often treated like walls.  
Symptoms:

1. Character bumps into each step edge.
2. Character "micro-jumps" up stairs.
3. Character jitters or briefly loses floor contact when descending.

## What Usually Works

Use a custom stair solver around `move_and_slide()`:

1. Pre-move `step_up` probe (when moving forward and blocked).
2. Regular `move_and_slide()` pass.
3. Post-move `step_down` probe (to reattach to floor cleanly).

The probe is typically done with `PhysicsServer3D.body_test_motion(...)` against the character body RID.

High-level flow:

```gdscript
# Pseudocode (structure, not drop-in code)
func _physics_process(delta: float) -> void:
    var wanted_motion: Vector3 = horizontal_velocity * delta

    if is_on_floor():
        try_step_up(wanted_motion) # small up + forward feasibility probe

    move_and_slide()

    if not is_on_floor() and velocity.y <= 0.0:
        try_step_down() # controlled snap to lower stair/floor
```

## Important Tuning Parameters

1. `step_height_max`: usually around `0.2` to `0.4` world units (depends on your level scale).
2. `floor_snap_length`: keep this non-zero; often close to `step_height_max`.
3. `floor_max_angle`: should allow intended ramps/sloped stair proxies.
4. `safe_margin`: too large can cause early collisions near stair edges; too small can cause instability.
5. Geometry scale: riser height must stay below `step_height_max` or ascent will fail.

## Geometry and Collision Pitfalls

1. Keep stair colliders clean and manifold; avoid tiny gaps between treads/risers.
2. Prefer one coherent static stair collider over many misaligned thin pieces.
3. Avoid ultra-sharp character feet for stair-heavy games; smoother bottoms reduce snagging.
4. Ensure consistent unit scale across scene and movement constants.

## Test Plan (Headless + Visual)

For this project, add a dedicated stair test scene (similar to ramp tests) with:

1. "Should pass" stair set (riser below `step_height_max`).
2. Boundary stair set (riser near the limit).
3. "Should fail" stair set (riser above the limit).

Validate:

1. Ascend/descend succeeds on pass/boundary sets.
2. No repeated airborne frames while descending normal stairs.
3. No artificial jump impulse when climbing.
4. Movement still behaves on ramps after stair logic is enabled.

## Sources

1. Godot docs: `CharacterBody3D` (`floor_snap_length`, floor classification): https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
2. Godot docs: `PhysicsServer3D.body_test_motion`: https://docs.godotengine.org/en/stable/classes/class_physicsserver3d.html
3. Godot docs: `SeparationRayShape3D` (often discussed for step handling): https://docs.godotengine.org/en/stable/classes/class_separationrayshape3d.html
4. Godot proposal discussing built-in step offset support gap: https://github.com/godotengine/godot-proposals/issues/2751
5. Godot Asset Library example plugin for stair stepping (`Stairs Character`): https://godotengine.org/asset-library/asset/2278

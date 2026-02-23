# Testing Guide

## Automated Checks

Run all required headless checks:

```bash
./scripts/check.sh
```

Equivalent commands:

```bash
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --quit-after 5
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/movement_math_test.gd
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/slope_movement_test.gd
```

## Manual Visual QA Checklist

1. Launch game scene from `main`.
2. Confirm room is larger and ceiling is high.
3. Confirm north/south windows show sky (true wall openings, not just transparent overlays).
4. Confirm transparent window blocks are still collidable (player cannot pass through).
5. Confirm room palette is muted and lower contrast than player cube.
6. Confirm ramps are reachable and traversal is smooth uphill/downhill.
7. Confirm click targets on ramps work and player remains grounded appropriately.
8. Confirm camera orbit and zoom still behave as expected.

## Regression Focus Areas

1. Scene authoring changes can break collision layers used by click raycast.
2. Ramp position/height adjustments can invalidate slope movement expectations.
3. Wall/window edits can accidentally remove visual access to sky.

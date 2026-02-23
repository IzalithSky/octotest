# Testing Guide

## Automated Checks

Run all required headless checks:

```bash
./scripts/check.sh
```

Equivalent commands:

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/check.sh
```

or, if a Godot binary is on your `PATH`:

```bash
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp godot --headless --path /path/to/octotest --quit-after 5
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp godot --headless --path /path/to/octotest --script res://tests/movement_math_test.gd
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp godot --headless --path /path/to/octotest --script res://tests/slope_movement_test.gd
```

`scripts/check.sh` also supports `godot4`, `Godot`, default macOS app path, and the legacy `/ssd2/...` Linux path.

## Manual Visual QA Checklist

1. Launch project and confirm startup menu (`main_menu.tscn`) appears first.
2. Click `Play` and confirm gameplay scene loads.
3. Confirm room is larger and ceiling is high.
4. Confirm north/south windows show sky (true wall openings, not just transparent overlays).
5. Confirm transparent window blocks are still collidable (player cannot pass through).
6. Confirm room palette is muted and lower contrast than player cube.
7. Confirm ramps are reachable and traversal is smooth uphill/downhill.
8. Confirm click targets on ramps work and player remains grounded appropriately.
9. Confirm camera orbit and zoom still behave as expected.
10. Confirm HUD key-hint panel is visible in a corner and does not block click-to-move when clicking through it.
11. Press `Esc` to open/close in-game menu; verify `Main Menu` returns to startup menu and `Quit` exits app.

## Regression Focus Areas

1. Scene authoring changes can break collision layers used by click raycast.
2. Ramp position/height adjustments can invalidate slope movement expectations.
3. Wall/window edits can accidentally remove visual access to sky.

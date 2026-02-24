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
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp godot --headless --path /path/to/octotest --script res://tests/card_reader_interaction_test.gd
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
12. Confirm light switch is mounted on wall and toggles room light + button material.
13. Confirm hover color state when out of range.
14. Confirm in-range interaction color state.
15. Confirm blocked interaction color state.
16. Confirm click on out-of-range interactable moves player closer and auto-interacts when in range.
17. Confirm octopus can hold up to 8 pickup items.
18. Confirm movement slows at heavy carry threshold and stops when fully loaded.
19. Confirm `LMB` on held item drops that specific item.
20. Confirm `F` drops last held item and `Shift + F` drops all.
21. Confirm clicking a focus-enabled object enters focus mode after approach (e.g. `CardReader`).
22. In focus mode, confirm held items appear at the bottom and can be selected by click.
23. Confirm clicking outside focus interaction area exits focus immediately.
24. Confirm card reader LED states: yellow (empty), red (wrong), green (correct).
25. Confirm reader holds one card at a time: second card cannot replace inserted card.
26. Confirm clicking inserted card retrieves/ejects it back to held items (when a slot is available).
27. Confirm non-applicable held item click in focus (e.g. mug on reader) animates toward slot and returns.

## Regression Focus Areas

1. Scene authoring changes can break collision layers used by click raycast.
2. Ramp position/height adjustments can invalidate slope movement expectations.
3. Wall/window edits can accidentally remove visual access to sky.
4. Interaction layer (`collision_layer = 8`) misconfiguration can break hover/click detection.
5. Carry layout changes can cause held-item clipping or unstable drop behavior.
6. Focus click hit areas are sensitive to camera/layout tuning; verify no accidental near-click item activation.

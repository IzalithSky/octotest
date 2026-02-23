# Octotest Prototype

Godot `4.6.1` 3D isometric prototype with:

1. Point-and-click movement.
2. Orbit camera rig (`SpringArm3D`).
3. Gravity and slope traversal ramps.
4. Authored room geometry with window openings and transparent collidable glass.
5. UI flow with a startup main menu, in-game menu, and gameplay HUD hints.

## Canonical Branch

Use `main` as the default stable branch.

## Run

```bash
cd /path/to/octotest
godot --path .
```

If your binary is named differently, these also work:

```bash
godot4 --path .
Godot --path .
```

For checks, `./scripts/check.sh` auto-detects, in order:

1. `GODOT_BIN` (if set)
2. `godot4` in `PATH`
3. `godot` in `PATH`
4. `Godot` in `PATH`
5. `/Applications/Godot.app/Contents/MacOS/Godot` (macOS app install)
6. `/ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64` (legacy team Linux path)

You can still force a specific binary:

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/check.sh
```

## Controls

1. `LMB`: set move target (floor/ramp).
2. `RMB + drag`: orbit camera.
3. `Q` / `E`: keyboard orbit.
4. Mouse wheel: zoom camera.
5. `Esc`: toggle in-game menu.

## Validate

Run the unified check script:

```bash
./scripts/check.sh
```

## Docs Map

1. Session workflow and dev rules: `docs/PROCEDURES.md`
2. Runtime/code structure: `docs/ARCHITECTURE.md`
3. Running change history: `docs/DEVLOG.md`
4. Manual + automated test checklist: `docs/TESTING.md`
5. Gameplay implementation notes: `docs/misc/STAIRS.md`
6. Canonical game design document (active project version): `docs/GDD.md`
7. Editable game task backlog: `docs/TASK_LIST.md`

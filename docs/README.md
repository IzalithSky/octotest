# Octotest Prototype

Godot `4.6.1` 3D isometric prototype with:

1. Point-and-click movement.
2. Orbit camera rig (`SpringArm3D`).
3. Gravity and slope traversal ramps.
4. Authored room geometry with window openings and transparent collidable glass.

## Canonical Branch

Use `main` as the default stable branch.

## Run

```bash
cd /ssd2/projects/godot/octotest
/ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --path /ssd2/projects/godot/octotest
```

## Controls

1. `LMB`: set move target (floor/ramp).
2. `RMB + drag`: orbit camera.
3. `Q` / `E`: keyboard orbit.
4. Mouse wheel: zoom camera.

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

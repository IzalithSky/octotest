# AI Agent Session Procedures

This file defines how to initialize and run AI-assisted dev sessions for this project.

## Project Facts

- Project root: `/ssd2/projects/godot/octotest`
- Godot binary: `/ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64`
- Main scene: `res://scenes/main.tscn`
- Logic tests: `res://tests/movement_math_test.gd`
- Dev log: `DEVLOG.md`

## Session Initialization Checklist

Run these steps at the start of every session.

1. Confirm current directory is project root.
2. Read `DEVLOG.md` from top to bottom and note the latest completed step.
3. Check git status and branch.
4. Run baseline sanity checks before changing code.
5. Create a dedicated feature/fix branch before implementation.

Suggested commands:

```bash
cd /ssd2/projects/godot/octotest
git status -sb
git branch --show-current
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --quit-after 5
HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp /ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --headless --path /ssd2/projects/godot/octotest --script res://tests/movement_math_test.gd
```

## Branching Rules

Use a separate branch for each new feature or fix.

1. Keep `main` stable.
2. Branch names:
- `feat/<short-topic>`
- `fix/<short-topic>`
- `chore/<short-topic>`
3. One focused change per branch.
4. Rebase/merge only after tests pass.

Example:

```bash
git checkout main
git checkout -b feat/camera-target-indicator
```

## Testing Rules

Every behavior change must include tests where possible.

1. If logic can be isolated, place it in a pure script and add/update a headless test under `tests/`.
2. At minimum, run:
- Headless boot smoke check (`--quit-after 5`)
- Logic test script(s)
3. If a change is hard to unit test, document manual verification steps in `DEVLOG.md`.

## Dev Log Rules

Keep `DEVLOG.md` updated continuously so work can resume after interruption.

1. Add a new dated step for each meaningful implementation chunk.
2. Record:
- What changed
- Why it changed
- Commands run
- Results and failures
- Follow-up tasks
3. Never leave a session without a final status entry.

## Godot Execution Rules

Use consistent commands to avoid environment-specific failures.

1. Prefer running Godot with writable temp environment in headless checks:
- `HOME=/tmp XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp`
2. Use absolute binary path:
- `/ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64`
3. Interactive run command:

```bash
/ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64 --path /ssd2/projects/godot/octotest
```

## Known Pitfalls (Observed)

1. Runtime-generated mesh/collision does not appear as authored scene content in editor and can produce missing-shape warnings.
2. Fully enclosed room can look black without interior light.
3. In restricted environments, headless Godot can fail creating `user://logs` unless HOME/XDG paths are writable.
4. `class_name` registration can be unreliable in bare headless script workflows; `preload()` is safer in tests/tool scripts.
5. GDScript strict typing can fail on Variant inference; explicitly type values from raycasts/dictionaries.

## Implementation Preferences

1. Keep room/player geometry and collision authored in scene files when editor visibility matters.
2. Keep gameplay math in pure scripts when possible for headless testability.
3. Avoid touching `.godot/` generated cache.
4. Keep `.uid` files committed with scripts/scenes to reduce resource ID churn.

## End-of-Session Checklist

1. Run tests and smoke checks again.
2. Update `DEVLOG.md` with final status.
3. Ensure `git status` reflects only intentional changes.
4. Commit with a clear, scoped message.

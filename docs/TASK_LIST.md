# Gone Exploring Development Task List

Derived from the original roadmap in `GDD.md`.

This file is intentionally editable and project-specific.

## Current Baseline (Already in this repo)

- [x] Godot 4.6 project bootstrapped.
- [x] 3D authored test room with ramps and collisions.
- [x] Point-and-click movement prototype.
- [x] Orbit camera (`SpringArm3D`) with zoom.
- [x] Gravity + slope traversal behavior.
- [x] Headless checks and movement tests in place.
- [x] Focus-mode interaction framework for precision objects.
- [x] Card reader prototype with card insertion/ejection + LED validation feedback.
- [x] Headless card-reader interaction integration test in check pipeline.

## Working Rules

- [ ] Every new mechanic includes at least one automated or reproducible manual test task before marking done.
- [ ] Keep a short implementation note for each completed risk item in `docs/DEVLOG.md`.
- [ ] If a task slips more than 2 sessions, either split it or defer it explicitly.

## Milestone 1: Core Prototype (Octo Feel)

### R&D Spikes (time-boxed)

- [ ] Spike: evaluate `SkeletonIK3D` vs plugin approach for arm IK (time-box: 1 day). `[RISK]`
- [ ] Spike: choose arm rig strategy for 8-arm scalability before full integration (time-box: 0.5 day). `[RISK]`

### Implementation

- [ ] Replace cube player with Octo placeholder body (blob + 8 arm stubs).
- [ ] Add subtle idle bob and movement tilt.
- [ ] Add eye nodes that track cursor/tap world target.
- [ ] Implement one-arm IK reach to target.
- [ ] Add arm retract to rest pose.
- [ ] Scale from one arm to eight arms with role categories.
- [ ] Implement automatic arm selection priority.
- [x] Add interaction base class for all interactables.
- [x] Build first interactable button (interaction SFX pending).

### Tests

- [ ] Test: verify one-arm reach/retract in isolated test scene.
- [ ] Test: verify arm priority order with 3+ simultaneous candidate targets.
- [ ] Test: confirm no regressions in existing movement/camera checks.

### Milestone 1 Done Criteria

- [ ] Octo placeholder can move, look-at target, and reach/press at least one interactable reliably.
- [ ] Arm selection is deterministic and documented.
- [ ] A new tester can perform reach + press interaction without explanation.

## Milestone 2: Mechanics Prototype (Grey-box Game)

### Implementation

- [x] Implement one-object-per-arm carrying.
- [ ] Implement valid object placement on surfaces.
- [x] Block movement when all arms are occupied.
- [ ] Add two-arm heavy object behavior.
- [ ] Persist object positions across room transitions. `[RISK]`
- [x] Implement code-lock node with sequence validation.
- [x] Implement light switch mechanic and room group toggles.
- [ ] Implement camouflage hold mechanic and interaction lockout.
- [ ] Implement first human NPC with patrol and soft catch/reset. `[RISK]`
- [ ] Implement device interactions: terminal, intercom, security panel.

### Tests

- [ ] Test: carrying/placement matrix (single arm, all arms, heavy objects).
- [ ] Test: code-lock success/fail reset behavior.
- [ ] Test: camouflage disables interaction while active.
- [ ] Test: catch/reset returns Octo and leaves dropped objects at catch point.

### Milestone 2 Done Criteria

- [ ] All core systems can be demonstrated in grey-box rooms without placeholder-only scripting hacks.
- [ ] At least one playable puzzle uses code + carrying + stealth/distraction in one flow.
- [ ] Soft fail/catch loop is functional and non-punishing.

## Milestone 3: Vertical Slice (Zone 1)

### Implementation

- [ ] Build Zone 1 grey-box rooms and puzzle flow.
- [ ] Implement opening Friday lock-up scene with voiced beats.
- [ ] Add OCT-05 tank framing and first visible desk-note code.
- [ ] Add first art pass for Zone 1 style consistency.
- [ ] Add first animation pass for Octo locomotion and interaction.
- [ ] Add first audio pass for ambience, interactions, and muffled humans.
- [ ] Validate that a new player can complete Zone 1 without prompts.

### Tests

- [ ] Test: full Zone 1 progression from opening to exit with no debug tools.
- [ ] Test: at least 3 fresh-player sessions, record blockers/time-to-complete.
- [ ] Test: regression pass on all Milestone 2 mechanics inside Zone 1 content.

### Milestone 3 Done Criteria

- [ ] Zone 1 is start-to-finish playable and representative of final game loop.
- [ ] Fresh players complete Zone 1 with minimal intervention.
- [ ] Zone 1 quality bar is stable enough to reuse patterns in later zones.

## Milestone 4: Full Game (Zones 2-5)

### Implementation

- [ ] Build Zone 2 work area with heavy-object puzzle usage.
- [ ] Build Zone 3 common areas with optional curiosity content.
- [ ] Build Zone 4 public facilities with stronger stealth pressure.
- [ ] Build Zone 5 outdoor traversal and ending sequence.
- [ ] Implement collectible "fancy things" emotional payoff in ending.
- [ ] Implement epilogue scene and credits.

### Tests

- [ ] Test: full playthrough from opening to ending in one session.
- [ ] Test: verify cross-zone persistence for objects and key puzzle state.
- [ ] Test: verify all mandatory progression gates can be bypassed only by intended solutions.

### Milestone 4 Done Criteria

- [ ] Complete game loop works across all zones with coherent difficulty progression.
- [ ] Narrative beats (opening, meeting, epilogue) are implemented and connected.

## Milestone 5: Ship

### Implementation

- [ ] Run structured internal and external playtests.
- [ ] Fix top friction points from observed sessions.
- [ ] Stabilize save/load under repeated quit scenarios. `[RISK]`
- [ ] Finish platform exports (PC first, then Mac and iPad).
- [ ] Prepare store assets and launch materials.

### Tests

- [ ] Test: performance pass on target iPad scenarios (minimum stable FPS target defined in advance).
- [ ] Test: save/load reliability under repeated force-quit scenarios.
- [ ] Test: platform smoke test checklist for iPad, Mac, PC exports.

### Milestone 5 Done Criteria

- [ ] Release candidate build is stable, performant on target hardware, and store-ready.

## Defer for First Ship (Scope Guard)

- [ ] Full tangle system (state tracking, untangle sequence, persistence coupling) as post-MVP enhancement.
- [ ] Advanced octopus skin simulation/complex shader systems beyond readability.
- [ ] Highly dynamic human AI behaviors beyond predictable patrol + reaction states.
- [ ] Extra optional zones not required for core narrative arc.
- [ ] Non-essential polish interactions that do not improve readability or core loop.

## Post-MVP Nice-to-Have: Tangle System

- [ ] Implement first-pass tangle detection and state tracking. `[RISK]`
- [ ] Implement untangle sequence mechanic. `[RISK]`
- [ ] Add visual tangle feedback and readable untangle affordances.
- [ ] Test: tangle enter/exit paths including auto-untangle reset.
- [ ] Test: at least one optional puzzle using tangle in a non-blocking path.

## Next Up (Recommended Order)

- [ ] Implement eye tracking.
- [ ] Decide IK approach (`SkeletonIK3D` vs plugin).
- [ ] Build one-arm reach prototype in an isolated test scene.
- [ ] Add interaction SFX pass for button/pickup/drop.

# Puzzle Plan

Use this document before implementing rooms. Keep it short and practical.

## 1) Puzzle Archetypes Used In This Game

List the puzzle types you will reuse.

- [ ] Code Entry
- [ ] Sequence Input
- [ ] Multi-Step Unlock (A -> B -> C)
- [ ] Carry/Place Object
- [ ] Light-State Dependent Clue

Notes:
- Avoid one-off puzzle logic unless necessary.
- Reuse archetypes with different room context and clue style.

## 2) Global Rules

- No camouflage puzzles.
- No tangle puzzles.
- Indoor only progression.
- Ending cutscene is the only open-water moment.

## 3) Critical Path Overview

Define only the mandatory route to credits.

| Step | Room ID | Main Goal | Unlock Result |
|---|---|---|---|
| 1 | ROOM_01 |  |  |
| 2 | ROOM_02 |  |  |
| 3 | ROOM_03 |  |  |
| 4 | ROOM_04 |  |  |
| 5 | ROOM_05 |  |  |
| 6 | ROOM_06 |  |  |

## 4) Optional Path Overview

Optional rooms, detours, and curiosity moments.

| Optional Room ID | Entry Condition | Reward/Payoff | Returns To |
|---|---|---|---|
|  |  |  |  |

## 5) Room-by-Room Puzzle Plan

Copy this block for each room.

---

### Room: `ROOM_ID`

**One-line room goal:**


**Puzzle archetype:**


**Required clues:**
- 

**Required modules/interactables:**
- 

**Puzzle flow (player actions):**
1. 
2. 
3. 

**Unlock result:**


**Dependencies (must be solved first):**
- 

**Difficulty:** `easy / medium / hard`

**Stuck prevention:**
- Extra clue: 
- Shortcut/reset help: 

**Catch/reset behavior in this room:**
- What is kept: 
- What resets: 

**Optional content in this room:**
- 

---

## 6) Difficulty Curve Check

Make sure difficulty rises gradually.

| Room ID | Difficulty | Why this level is fair now |
|---|---|---|
| ROOM_01 | easy |  |
| ROOM_02 | easy |  |
| ROOM_03 | medium |  |
| ROOM_04 | medium |  |
| ROOM_05 | hard |  |
| ROOM_06 | hard |  |

## 7) Dependency Safety Check

Use this to prevent softlocks.

- [ ] Every mandatory door has at least one reachable clue path.
- [ ] No mandatory item can be permanently lost.
- [ ] Catch/reset cannot erase critical global progression.
- [ ] At least one obvious next step exists after each solved puzzle.

## 8) Implementation Handoff Checklist

Before building rooms in-engine:

- [ ] Critical path table filled.
- [ ] Room-by-room blocks filled for all planned rooms.
- [ ] Difficulty curve reviewed.
- [ ] Dependency safety checklist completed.
- [ ] Map references added (link to station map images in `docs/misc/`).

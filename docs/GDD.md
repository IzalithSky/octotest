🐙

**GONE EXPLORING**

*Game Design Document  •  Living Draft*

*Smart. Curious. Always watching.*

| Game Title | Gone Exploring |
| :---- | :---- |
| **Engine** | Godot 4 (3D) |
| **Platform** | iPad, PC, Mac |
| **Developer** | 2-person indie team |
| **Tone** | Cute, curious, grounded — Stray underwater |
| **Stage** | Pre-prototype / active design |

# **1\. Core Concept**

*A curious octopus escapes her research tank on a Friday evening and explores an underwater science station — solving puzzles, avoiding the skeleton crew, and eventually finding her way to open ocean.*

Inspired by Stray: the player inhabits a small, intelligent creature in a world built for someone else. No handholding. No combat. Just observation, curiosity, and the satisfaction of figuring things out.

Puzzles emerge from mechanics, not arbitrary logic. The octopus's arms are the puzzle — how you use them, in what order, and what state they end up in. Every room has a way forward. Finding it is the game.

# **2\. Octo**

*No name. No dialogue. Just a real animal doing real animal things — and the player feels every bit of her intelligence.*

## **Personality**

* Smart and observant — studies a room before acting, notices everything

* Deeply curious — will investigate something interesting even if it has nothing to do with escaping

* Unhurried — moves with purpose, not panic. This is a Friday evening adventure, not a thriller.

* Has preferences — drawn to certain objects, colours, textures for no puzzle reason. Lingers. Has opinions.

## **Identity**

She has no formal name — she is a research subject. Her tank is labelled OCT-05. The scientists call her Octo out loud, which the player hears in the opening scene. It's informal, affectionate, unofficial. It suits her.

Her colour shifts tell her story. Octopuses change colour not just for camouflage but as emotional expression — curious, alert, pleased, startled. No dialogue needed.

## **Relationship with Humans**

The scientists are not enemies. They're busy, absorbed in their work, entirely oblivious. If they notice Octo outside her tank they simply pick her up and return her — mildly inconvenient, no drama, no punishment. They're not unkind. They just don't notice.

*Getting caught is a mild indignity, not a fail state. Octo gets returned to the tank and tries again — exactly as real octopuses do.*

# **3\. Setting**

## **The Station**

An underwater research station studying climate change, ocean currents, and local marine life. Not secretive or sinister — just normal scientists doing normal science in an unusual place. The kind of facility that runs public tours on weekday mornings.

## **Atmosphere**

Sterile and functional in the working areas, lived-in and personal in the common spaces. Sticky notes, coffee mugs, half-eaten Friday lunches, photos on desks. The station has texture and history that rewards curious players without blocking anyone.

Time of day shifts across the game — Friday afternoon light fading to evening, then night. The outdoor sections especially feel different as it gets darker.

# **4\. Story**

## **Opening**

*No tutorial text. The entire setup is delivered through overheard dialogue.*

Friday afternoon. Two scientists wrap up for the weekend. The player watches from inside the tank — Octo's POV, glass faintly distorting the room.

* Scientist A: "It's Friday\! Finally. You good to lock up?"

* Scientist B: "Yep — oh, do you remember the new security code?"

* Scientist A: "I wrote it on my desk, just grab it before you leave."

* They wave at the tank. "Bye Octo\!" — and they're gone.

The station goes quiet. Octo looks at the tank wall. Looks at the desk, visible through the glass. The first puzzle is already in front of her.

*The desk note is the first code. The whole game loop is demonstrated before the player touches a single button.*

## **The Journey**

Octo moves through the station from back to front — from the most private and restricted spaces toward the public-facing ones, and eventually outside.

* Zone 1 — The Back Lab: Octo's tank. Someone's personal office and research space. Cluttered, intimate. First puzzles, tutorial energy without being a tutorial.

* Zone 2 — The Work Area: Shared workstations, server room, equipment storage, maintenance corridors. The station's infrastructure. Vents appear.

* Zone 3 — Common Areas: Break room, meeting rooms, lounge. Personal and lived-in — leftovers in the fridge, a book on the couch, a corkboard of photos.

* Zone 4 — Public Facilities: Reception, cafeteria, gift shop. Cheesy educational posters. A little plushie octopus on the gift shop shelf. Octo walks past it.

* Zone 5 — Open Water: Between buildings, then beyond. The ocean.

*Scope target: 4–5 zones, 4–6 rooms each. Small enough to ship, deep enough to be satisfying.*

## **The Ending**

*No fanfare. Octo swims out into open water — and finds she is not alone.*

Another octopus. Wild, free, curious. They meet. They exchange objects — small, interesting things — the way octopuses actually do. A gesture of curiosity and connection.

The whole game has been about Octo interacting with objects. The ending recontextualises all of it. She wasn't just solving puzzles. She was practicing a language she finally gets to use with someone who speaks it.

* The 'fancy things' Octo collected for no puzzle reason become the emotional payload of the ending

* A player who carried something beautiful the whole way, and offers it here, gets the full moment

## **Epilogue**

Monday morning. A scientist walks in with coffee. Sees the empty tank. Stands there a moment. Then smiles — sticks a note on the glass. 'Gone exploring.' Roll credits.

# **5\. Game Loop**

When Octo enters a new space the loop is natural and player-driven. There is no objective marker, no waypoint — just a room to read.

* Orient — What is this room? Is there anyone here? Where does it lead?

* Observe — How does the exit open? What's written on the walls? What's interesting?

* Plan — What's needed to proceed? Where might the code be? Which arms are free?

* Execute — Gather useful items, find the code, open the way forward.

* Move on — and detour for anything interesting along the way.

*Not every room is a puzzle. Some doors are unlocked. Some rooms are just rooms. Breathing space makes the actual puzzles feel earned.*

## **Optional Moments**

Curious players are rewarded. None of it is required — all of it is delightful:

* A vending machine openable with coins found under a bench

* Lore in the environment — evacuation posters, staff schedules, a whiteboard with half-erased notes

* Objects with no puzzle purpose that are simply interesting to pick up and carry

* Small interactions that exist purely because Octo would do them

# **6\. Mechanics**

## **6.1 The Arm System**

Octo has 8 appendages, each with a distinct role based on real octopus biology:

| Type | Count & Role | Function in Game |
| :---- | :---- | :---- |
| Arms | ×2 — primary interaction | Press buttons, input codes, grab objects. Most expressive — carry visible personality. |
| Legs | ×2 — propulsion | Movement, swimming, squeezing through vents and tight gaps. |
| Multipurpose | ×4 — wild cards | Extended reach, can perform arm or leg tasks but less precisely. Optional tangle behavior can be enabled later as an advanced layer. |

## **6.2 The Tangle System (Nice-to-Have / Post-MVP)**

*Puzzle difficulty comes from arm state management — not from arbitrary item matching or colour pairing.*

Arms can cross over each other in 3D space. In the enhanced version of the game, this can create a tangle — a visible constraint the player must consider before acting further.

For MVP, this system is optional and can be deferred without breaking the core game loop (explore, observe, solve, evade, progress).

If implemented post-MVP:

* Tangle state can persist between rooms — you live with your choices

* Arms only tangle when holding objects — dropping items or getting caught auto-untangles

* Some rooms can require entering already tangled in a specific configuration

* Untangling means tapping/clicking interactions in the correct sequence to unwind crossed arms

* Visual feedback: arms visibly cross, tangle points highlighted — exact visual approach deferred until 3D model exists

## **6.3 Code & Sequence Puzzles**

Every room has a way forward — usually a locked door or hatch. Opening it requires a code: a sequence or combination discovered through exploration, then executed physically with arms.

* Discovery phase: find the code through observation — a note on a desk, a pattern on the wall, something a fish is doing, a sequence visible on a screen

* Execution phase: use arms to input the code — which arm goes where matters

Code variety keeps rooms distinct:

* Hold 3 points simultaneously while a 4th arm pulls a lever

* Press a sequence in order — which arm you use last determines what's free next

* Timed inputs combined with specific arm positions

* Environmental patterns — lights flickering in sequence, water flow, animal behaviour

## **6.4 Camouflage**

Hold to blend into surroundings. Octo becomes invisible to nearby humans and creatures.

* While camouflaged: arms cannot be extended — no interaction

* Core tension: sneak past the guard to reach the observation point, then uncloak to act

* Lights off \+ camouflage: double cover, but Octo also loses visual clarity

* Colour shifts as mood expression are separate from active camouflage

## **6.5 Object Carrying**

*One object per arm. Fill all arms and Octo cannot move. Physical, believable, occasionally very funny.*

* Primary arms occupied \= all interaction falls to multipurpose arms — clumsier and less precise

* Heavy objects require two arms — immediately halves available interactions

* Setting objects down matters — placement has consequences for what comes next

* Objects persist exactly where left, across all rooms and zones — the station is one connected space

Design rules for persistence:

* Nothing droppable somewhere Octo cannot return to — no permanent losses

* Required objects have subtle visual distinction so players treat them carefully without being told to

## **6.6 Light Switches**

Octo can turn room lights on and off. Simple interaction, deep combinations:

* Lights off: humans react — window to move or interact unobserved

* Lights on: reveals hidden things — codes on walls, patterns on floors

* Screen glare: some codes only readable on monitors with room lights off

* Chain reaction: lights off → human goes to check the switch → Octo slips through the door they just walked away from

## **6.7 Interactable Devices**

Octo can operate computers, terminals, intercoms, and lab equipment:

* Computers: door controls, staff notes with codes, disable cameras

* Security panels: override locks, check camera feeds

* Intercoms and speakers: audio distractions that move humans to other rooms

* Phones and tablets on desks: messages between scientists often contain codes or hints

*Device interactions should require arm management — a computer might need two arms simultaneously (keyboard \+ cursor), creating natural coordination pressure.*

## **6.8 Human Presence**

It's a weekend. The station is nearly empty — a skeleton crew at most. Not a military base. Just scientists who went home for the weekend.

* A security guard making slow, predictable rounds

* A researcher who forgot something and came back

* A night janitor working through the building

Because humans are rare, each encounter is an event, not a routine obstacle. Their reactions are predictable and can be chained:

* Intercom in the break room → researcher wanders over → their desk is clear

* Open a far door → guard goes to investigate → corridor unblocked

* Lights off \+ camouflage → both systems active simultaneously

## **6.9 Outdoor Traversal**

The research station is a campus — multiple buildings connected by open water. At key points Octo leaves the safety of indoors entirely.

* Massive tonal shift — from sterile corridors to open dark ocean

* No walls to hide behind — camouflage becomes essential

* Underwater paths between buildings: pipes, guide lights, familiar landmarks

* Some buildings locked from outside — Octo finds alternate entry: broken vent, open hatch, gap in a panel

* The final outdoor section is the emotional climax — open ocean visible, tantalizingly close

# **7\. Controls**

*Platforms: iPad, PC, Mac. Identical interaction model across all — point-and-click/tap. No meaningful difference between platforms.*

## **Movement & Camera**

* Click or tap to move — Octo walks or swims to that point relative to the current camera view

* Player-controlled camera — swipe (iPad) or click-drag (PC/Mac) to rotate freely, Stray-style

* Camera locked from clipping through walls or floor — Godot collision handles this

* Tight spaces and vents: camera automatically switches to a fixed angle — returns to free control when Octo exits

## **Interaction**

* Click or tap an object to interact — automatic arm selection, invisible until it matters

* All interactable objects are highlighted (subtle glow or dot) — the player decides what is worth picking up or using

* Hold to camouflage, release to uncloak

* Pinch to zoom (iPad) / scroll wheel (PC/Mac) — examine codes on notes, labels on equipment

## **Arm State — No UI Needed**

Arm status is communicated through Octo's body language, not an interface panel:

* Arms visibly occupied when holding objects — the player can see what each arm is doing

* All arms busy: Octo nudges her head slightly toward the tap point — 'I see it, I just can't reach it'

* This keeps the screen clean and the feedback characterful

## **Tangle Rules (Optional System)**

If enabled, arms only tangle when they are holding objects and cross in space. Dropping items or getting caught by a human auto-untangles — objects fall, arms return to rest.

*Getting caught has a soft mechanical cost: you lose your arm state and have to re-collect items. No punishment screen — just a quiet reset.*

## **Object Placement**

* Tap/click a surface to place a held object there

* Tapping empty water or a wall with an object: nothing happens — Octo holds on

# **8\. Aesthetic Direction**

## **Visual Style**

* Bright, saturated but grounded — not candy-coloured, more like a beautifully lit aquarium

* Chunky, readable geometry — works well at tablet scale, no tiny details that need a mouse to spot

* Reference: Stray (atmosphere, small creature / big world), Alba: A Wildlife Adventure (warmth)

* The research station feels functional and real — beauty comes from light and water, not decoration

## **Octo's Animation**

* Big, expressive eyes — react to discovering a code, noticing something interesting, and key puzzle progress

* Colour shifts for mood: curious (warm), startled (pale flash), pleased (deep rich hue), camouflaged (environment-matched)

* Arms have weight and physicality — they drag slightly, coil naturally, don't snap around

## **Sound**

* Ambient underwater texture throughout — present but not intrusive

* Satisfying tactile clicks and sounds for interactions

* Humans have muffled, distant voices — heard but not understood, the way Octo hears them

* Music: ambient only, no melody. The soundscape is texture, not score. Swells reserved for the very end.

# **9\. Prototype Roadmap**

*First 3D game in Godot — prototype mechanics before building any rooms or story. The core feel must work in grey boxes first.*

* Step 1 — Basic 3D movement: a blob navigating a flat space  ✅

* Step 2 — Click-to-move with camera follow  ✅

* Step 3 — One arm reaching toward a tap target

* Step 4 — Multiple arms, observe spatial behaviour

* Step 6 — First interactable: an arm presses a button

* Step 7 — Simple code lock: tap A, then B, then C to open a door

* Optional Step 8 — First tangle: two arms cross — does it feel like anything?

By step 7 the core game exists. Everything after is content and refinement.

## **Key Godot Technology to Research Early**

* Skeleton3D \+ Inverse Kinematics (IK) for arm movement — research community plugins before writing arm code

* SpringArm3D for camera collision — use from the start, retrofitting is painful

* 3D collision/proximity checks for optional tangle detection (post-MVP)

* AnimationTree for body and eye expression

* Touch input handling on iPad via Godot's InputEventScreenTouch

*— Gone Exploring  •  Game Design Document  •  Living draft —*

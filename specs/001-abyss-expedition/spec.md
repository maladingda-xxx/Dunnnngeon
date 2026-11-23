# Feature Specification — Abyss Expedition

**Status** In development | **Created** 2026-11-23

## User Scenarios & Testing

- **US1, P1** Start a seeded run, choose a hero, enter a connected battle node, select a skill and enemy, claim victory rewards, and return to the map. Complete a final boss or reach defeat and start again. Verify through the main scene.
- **US2, P2** Recruit up to four members and manage distinct skills, status, stress and equipment. Verify through a recruitment node, party controls, and an encounter.
- **US3, P2** Choose different routes and resolve every room type. Verify explicit room choices, costs, rewards and return to the previous map.
- **US4, P2** Resume a checkpoint with the same route, inventory and party. Verify a round trip and safe handling of malformed saves.
- **US5, P2** Read the map, plan a route and resolve battle at 1280 × 720. Verify native window rendering, hover labels, skill tooltips and feedback.

## Requirements

- **FR-001** Generate one region, with 2–4 nodes per branching floor and one final Boss. Edges must connect adjacent floors, with every node reachable and able to reach the Boss.
- **FR-002** Resolve speed-ordered combat, explicit skills and targets, lethal turns, post-battle rewards and run outcomes.
- **FR-003** Provide six roles, each with a basic attack, two skills and passive, plus seven timed status effects and stress.
- **FR-004** Provide ten room types, twelve events, eight pieces of equipment across three tiers and three consumables.
- **FR-005** Store a validated versioned local JSON checkpoint at safe boundaries.
- **FR-006** Render original archive-style map and side-view combat with nearest-filtered local sprites and readable input states.
- **FR-007** Preserve deterministic outcomes for the same seed and decisions.

## Clarifications

### Session 2026-11-23

- The supplied project actually contains six categories of individual PNGs. Use their verified alpha bounds as atlas regions.
- One region contains eleven branching floors and a twelfth Boss floor. The entry gate is a separate anchor.
- Preserve a pre-room checkpoint and resume from the map. A haunted or unexplored room reveals details when entered.
- Use Chinese UI and the original English title. The screenshots guide atmosphere and interaction layout.

## Success Criteria

- **SC-001** Same-seed map hashes match and every generated room has a legal path to the final boss across at least 100 test seeds.
- **SC-002** Smoke tests traverse menu, map, combat, reward, map, boss and both ending outcomes.
- **SC-003** Room, inventory, stress and status effects change runtime state and render in the UI.
- **SC-004** A saved checkpoint resumes with matching state and the runtime shows no blocking errors.

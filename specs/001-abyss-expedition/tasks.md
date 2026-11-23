# Tasks — Abyss Expedition

## Phase 0

- [x] T001 Establish constitution and acceptance criteria in specs/001-abyss-expedition/.
- [x] T002 Audit all six asset categories and create docs/asset_catalog.md.

## Phase 1 — Playable slice

- [x] T003 [US1] Generate and verify directed routes in scripts/core/map_generator.gd.
- [x] T004 [US1] Implement combat turns and rewards in scripts/core/combat_manager.gd and scripts/core/run_manager.gd.
- [x] T005 [US1] Wire the launch, map, combat, reward and end screens in scenes/main/main.tscn.
- [x] T006 [US1] Exercise the full gameplay loop in tests/run_tests.gd.

## Phases 2–3 — Party and rooms

- [x] T007 [US2] Provide class actions, passives, stress, statuses and party management.
- [x] T008 [US3] Add the full event roster, room choices, shop and loot in data/ and scripts/core/.

## Phases 4–5 — Presentation and persistence

- [x] T009 [US5] Validate map and battle composition and feedback in an active Godot runtime.
- [x] T010 [US4] Verify a versioned checkpoint and malformed-save handling.
- [x] T011 Run headless regression and document known limitations.

## Dependencies

T001–T002 precede T003. T003–T005 precede T006. T006 precedes T007–T008. T009–T010 precede T011.

## Analyze

FR-001 and FR-007 map to T003 and T011. FR-002 maps to T004–T006. FR-003 maps to T007. FR-004 maps to T008. FR-005 maps to T010. FR-006 maps to T002, T005 and T009. Each requirement has an implementation task and a scenario or acceptance criterion.

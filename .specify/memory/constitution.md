<!-- Sync impact: template → 1.0.0. Feature spec, plan and tasks adopt initial principles. -->
# Abyss Expedition Constitution

## Core Principles

### I. Playable Milestones
Each gameplay milestone MUST be playable through the main scene and verified in Godot. The map, combat and reward loop precedes content expansion.

### II. Reproducible Runs
Run randomness MUST use a seed. Map topology, turn resolution, rewards and save restoration MUST have regression coverage.

### III. Original Pixel Presentation
Screens MUST use the project’s original composition and local sprite assets. Sprite bounds MUST be verified and rendered with nearest-neighbor filtering.

### IV. Independent Systems
Static definitions MUST be separate from runtime state. The map, battle, rooms and persistence MUST each have testable entry points.

### V. Honest Verification
Release notes MUST distinguish automated, runtime and visual checks. A defect blocking the core loop MUST be fixed before a milestone is accepted.

## Governance
The constitution applies to every feature plan. Amendments require a version update and review of affected specifications.

**Version** 1.0.0 | **Ratified** 2026-11-23 | **Last Amended** 2026-11-23

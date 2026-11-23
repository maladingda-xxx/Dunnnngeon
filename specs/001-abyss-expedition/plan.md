# Implementation Plan — Abyss Expedition

## Technical Context

Godot 4.x with GDScript, native Controls and AtlasTexture. Target 1280 × 720. Local JSON checkpoints and seeded Godot RNG. No external artwork or runtime services.

## Constitution Check

The first playable path is implemented before expanded rooms. Core logic has headless tests. Visuals are original and use cropped local sprites. Godot editor MCP verifies the actual scene and runtime.

## Execution

1. Audit the project and review RGBA assets with contact sheets and alpha bounds. Store source rectangles in a catalog.
2. Build pure map and combat logic, then wire menus, node selection, skills, rewards, boss and endings into the main scene. Verify the gameplay path before extending rooms.
3. Add six class definitions, timed combat effects, recruitment, events, shopping and inventory through independent systems.
4. Verify real rendering and interaction, then check repeatability, save recovery and victory/defeat.

## Structure

- `data/` holds static content and constraints.
- `scripts/core/` holds run, map, combat, event, inventory and storage logic.
- `scripts/ui/` holds screen and drawing components.
- `scenes/main/` contains the game entry point.
- `tests/` verifies map and gameplay invariants.

# Minebreak — Godot voxel sandbox

Minebreak is a from-scratch Godot 4 GDScript voxel sandbox. Open this repository's root `project.godot` in Godot 4.3+ and press Play.

## Current implementation

- Chunked voxel storage (16 × 48 × 16), seeded height-map terrain, coherent underground cave carving, simple deterministic trees, and a bounded chunk streaming radius.
- Greedy-free exposed-face mesh generation with shared atlas material and generated pixel-art-style atlas.
- Static triangle-mesh collision per chunk, first-person movement, jumping, sprinting, mouse look, ray-stepped block targeting, mining and placement.
- Nine-slot hotbar selection, basic block stacks, survival/creative toggle (F3), creative flight (F), sky/lighting, pause UI, and JSON persistence for block edits and world seed.
- Cross-chunk block edits request neighboring mesh rebuilds.
- Atlas tiles are generated deterministically in GDScript at startup; no third-party or Minecraft-owned art is redistributed.
- Basic fall damage, hunger depletion, starvation damage, low-hunger regeneration, and a simple respawn are implemented. Health and hunger are shown in the HUD.
- Player position, orientation, mode, health/hunger values, selected hotbar slot, inventory counts, world seed and edited blocks are included in the local save.

## Controls

- WASD: move; mouse: look; Space: jump (creative flight up); Ctrl: creative flight down; Shift: sprint.
- Left click: mine; right click: place; number keys 1–9: choose hotbar block.
- F3: toggle survival/creative; F: toggle flight while creative; Esc: pause.
- Pause menu includes save and quit.

## Known limitations (not represented as completed)

This is an early playable engine foundation, not the full acceptance target yet. Biome selection, water bodies, background chunk generation, full inventory UI and stack manipulation, recipe crafting, tools/hardness, food consumption, entities, audio, settings, world list management, multiple named world slots, and multiplayer are not implemented yet. Save/load currently uses one local save slot. Chunk meshing rebuilds the whole chunk and should be optimized before scaling the render distance. Runtime validation requires a local Godot 4 installation; this session's repository edits are made through GitHub APIs and the game has not been launched in a graphical Godot runtime here.

## Smoke test

With Godot 4 installed, run `godot --headless --editor --path . --quit` once to import and register project classes, then run `godot --headless --path . --script res://tests/core_smoke.gd`. The smoke test checks the block registry, generated atlas dimensions, and chunk storage bounds. It has been added to the repository but could not be executed in this environment because the Godot executable is unavailable.

## Save location

The local save file is `user://minebreak_world.json`. This is separate from the Git repository.

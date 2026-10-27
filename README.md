# Minebreak — Godot voxel sandbox

Minebreak is a from-scratch Godot 4 GDScript voxel sandbox. Open this repository's root `project.godot` in Godot 4.3+ and press Play.

## Current implementation

- Chunked voxel storage (16 × 48 × 16), seeded height-map terrain and a bounded chunk streaming radius.
- Greedy-free exposed-face mesh generation with shared atlas material and generated pixel-art-style atlas.
- Static triangle-mesh collision per chunk, first-person movement, jumping, sprinting, mouse look, ray-stepped block targeting, mining and placement.
- Nine-slot hotbar selection, basic block stacks, survival/creative toggle (F3), creative flight (F), sky/lighting, pause UI, and JSON persistence for block edits and world seed.
- Cross-chunk block edits request neighboring mesh rebuilds.
- Atlas tiles are generated deterministically in GDScript at startup; no third-party or Minecraft-owned art is redistributed.

## Controls

- WASD: move; mouse: look; Space: jump (creative flight up); Ctrl: creative flight down; Shift: sprint.
- Left click: mine; right click: place; number keys 1–9: choose hotbar block.
- F3: toggle survival/creative; F: toggle flight while creative; Esc: pause.
- Pause menu includes save and quit.

## Known limitations (not represented as completed)

This is the initial playable engine foundation, not the full acceptance target yet. Terrain is a basic seeded height map; caves/biomes/trees/water bodies, background chunk generation, full inventory UI and stack manipulation, recipe crafting, tools/hardness, health/hunger damage, entities, audio, settings, world list management, robust per-world save slots, and multiplayer are not implemented yet. Save/load currently uses one local save slot. Chunk meshing rebuilds the whole chunk and should be optimized before scaling the render distance. Runtime validation requires a local Godot 4 installation; this session's repository edits are made through GitHub APIs and the game has not been launched in a graphical Godot runtime here.

## Save location

The local save file is `user://minebreak_world.json`. This is separate from the Git repository.

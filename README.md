# Minebreak — Godot Edition

This is the new Godot 4 version of Minebreak, separate from the original browser prototype.

## Current prototype

- First-person mouse-look and WASD movement
- Jumping and collision
- Small procedurally generated voxel landscape
- Basic directional lighting and sky
- Terrain mesh generated with exposed faces only

## Run it

1. Install Godot 4.3 or newer from https://godotengine.org/download/
2. Download this repository as a ZIP, or clone it.
3. In Godot Project Manager, choose **Import** and select the `project.godot` file.
4. Open the project and press **F6** only if you open the main scene directly; otherwise press **F6** or **F5** to run the project (F5 runs the main project).

## Controls

- WASD: Move
- Mouse: Look around
- Space: Jump
- Escape: Release the mouse; click the game to capture it again

## Next development steps

1. Add selectable blocks, breaking and placing.
2. Replace prototype vertex colors with a block texture atlas.
3. Split terrain into chunks for efficient loading and editing.
4. Add inventory/hotbar, then entities and animations.
5. Add save/load and resource-pack ZIP support.

This is an early prototype, not a finished Minecraft clone.

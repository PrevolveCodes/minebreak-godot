extends Node3D
class_name VoxelWorld

const ChunkScript = preload("res://scripts/voxel_chunk.gd")
var chunks: Dictionary = {}
var noise := FastNoiseLite.new()
var atlas_material: StandardMaterial3D
var seed_value := 48271
var modified: Dictionary = {}
var saved_player_state: Dictionary = {}
var load_radius := 2

func initialize(world_seed: int) -> void:
	seed_value = world_seed
	noise.seed = seed_value
	noise.frequency = 0.018
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	var material := StandardMaterial3D.new()
	material.albedo_texture = TextureAtlas.create_atlas()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	atlas_material = material

func load_around(position: Vector3) -> void:
	var center := Vector2i(floori(position.x / 16.0), floori(position.z / 16.0))
	for ring in range(load_radius + 1):
		for cz in range(center.y - ring, center.y + ring + 1):
			for cx in range(center.x - ring, center.x + ring + 1):
				if max(abs(cx - center.x), abs(cz - center.y)) != ring:
					continue
				var key := Vector2i(cx, cz)
				if not chunks.has(key):
					_generate_chunk(key)
	var remove_keys: Array = []
	for key in chunks.keys():
		if max(abs(key.x - center.x), abs(key.y - center.y)) > load_radius + 1:
			remove_keys.append(key)
	for key in remove_keys:
		chunks[key].queue_free()
		chunks.erase(key)

func _generate_chunk(key: Vector2i) -> void:
	var chunk: VoxelChunk = ChunkScript.new()
	chunk.name = "Chunk_%d_%d" % [key.x, key.y]
	chunk.chunk_coord = key
	chunk.world_ref = self
	chunk.atlas_material = atlas_material
	chunk.position = Vector3(key.x * 16, 0, key.y * 16)
	add_child(chunk)
	chunks[key] = chunk
	for z in range(16):
		for x in range(16):
			var wx := key.x * 16 + x
			var wz := key.y * 16 + z
			var h := clampi(12 + int(noise.get_noise_2d(wx, wz) * 10.0) + int(noise.get_noise_2d(wx * 2.7, wz * 2.7) * 3.0), 3, 38)
			for y in range(h + 1):
				var id := BlockDB.STONE
				if y == 0:
					id = BlockDB.BEDROCK
				elif y == h:
					id = BlockDB.SAND if h <= 13 else BlockDB.GRASS
				elif y >= h - 3:
					id = BlockDB.SAND if h <= 13 else BlockDB.DIRT
				elif y > 3 and y < h - 3 and noise.get_noise_3d(wx * 0.085, y * 0.11, wz * 0.085) > 0.48:
					id = BlockDB.AIR
				elif y < 8 and abs(noise.get_noise_3d(wx * 0.12, y * 0.12, wz * 0.12)) > 0.72:
					id = BlockDB.COAL_ORE if (wx + y + wz) % 4 == 0 else BlockDB.STONE
				chunk.set_local(x, y, z, id)
	for z in range(3, 13):
		for x in range(3, 13):
			var wx := key.x * 16 + x
			var wz := key.y * 16 + z
			var h := clampi(12 + int(noise.get_noise_2d(wx, wz) * 10.0) + int(noise.get_noise_2d(wx * 2.7, wz * 2.7) * 3.0), 3, 38)
			var roll := posmod(abs(wx * 73856093 + wz * 19349663 + seed_value * 83492791), 113)
			if roll != 0 or h <= 15 or chunk.get_local(x, h, z) != BlockDB.GRASS:
				continue
			for ty in range(h + 1, mini(h + 5, VoxelChunk.HEIGHT)):
				chunk.set_local(x, ty, z, BlockDB.WOOD)
			for ly in range(h + 3, mini(h + 6, VoxelChunk.HEIGHT)):
				for lz in range(max(0, z - 2), mini(16, z + 3)):
					for lx in range(max(0, x - 2), mini(16, x + 3)):
						if abs(lx - x) + abs(lz - z) + abs(ly - (h + 4)) <= 4 and chunk.get_local(lx, ly, lz) == BlockDB.AIR:
							chunk.set_local(lx, ly, lz, BlockDB.LEAVES)
	for pos in modified.keys():
		var p: Vector3i = pos
		if floori(float(p.x) / 16.0) == key.x and floori(float(p.z) / 16.0) == key.y:
			chunk.set_local(posmod(p.x, 16), p.y, posmod(p.z, 16), int(modified[pos]))
	chunk.rebuild()
	for neighbor_key in [key + Vector2i(1, 0), key + Vector2i(-1, 0), key + Vector2i(0, 1), key + Vector2i(0, -1)]:
		_rebuild_if_loaded(neighbor_key)

func get_block(wx: int, y: int, wz: int, create_if_missing := true) -> int:
	if y < 0:
		return BlockDB.BEDROCK
	if y >= VoxelChunk.HEIGHT:
		return BlockDB.AIR
	var key := Vector2i(floori(float(wx) / 16.0), floori(float(wz) / 16.0))
	if not chunks.has(key):
		if not create_if_missing:
			return BlockDB.AIR
		_generate_chunk(key)
	return chunks[key].get_local(posmod(wx, 16), y, posmod(wz, 16))

func set_block(wx: int, y: int, wz: int, id: int) -> void:
	if y < 1 or y >= VoxelChunk.HEIGHT:
		return
	var key := Vector2i(floori(float(wx) / 16.0), floori(float(wz) / 16.0))
	if not chunks.has(key):
		_generate_chunk(key)
	var chunk: VoxelChunk = chunks[key]
	chunk.set_local(posmod(wx, 16), y, posmod(wz, 16), id)
	modified[Vector3i(wx, y, wz)] = id
	chunk.rebuild()
	if posmod(wx, 16) == 0: _rebuild_if_loaded(key + Vector2i(-1, 0))
	if posmod(wx, 16) == 15: _rebuild_if_loaded(key + Vector2i(1, 0))
	if posmod(wz, 16) == 0: _rebuild_if_loaded(key + Vector2i(0, -1))
	if posmod(wz, 16) == 15: _rebuild_if_loaded(key + Vector2i(0, 1))

func _rebuild_if_loaded(key: Vector2i) -> void:
	if chunks.has(key):
		chunks[key].rebuild()

func save_world(player_state: Dictionary = {}) -> void:
	var payload := {"seed": seed_value, "modified": [], "player": player_state}
	for p in modified.keys():
		payload.modified.append([p.x, p.y, p.z, int(modified[p])])
	var file := FileAccess.open("user://minebreak_world.json.tmp", FileAccess.WRITE)
	if file == null:
		push_error("Could not open temporary world save.")
		return
	file.store_string(JSON.stringify(payload))
	file.close()
	if FileAccess.file_exists("user://minebreak_world.json"):
		DirAccess.remove_absolute("user://minebreak_world.json")
	var err := DirAccess.rename_absolute("user://minebreak_world.json.tmp", "user://minebreak_world.json")
	if err != OK:
		push_error("World save rename failed: %s" % error_string(err))

func load_world() -> bool:
	if not FileAccess.file_exists("user://minebreak_world.json"):
		return false
	var file := FileAccess.open("user://minebreak_world.json", FileAccess.READ)
	if file == null: return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY: return false
	seed_value = int(parsed.get("seed", seed_value))
	saved_player_state = parsed.get("player", {})
	noise.seed = seed_value
	modified.clear()
	for row in parsed.get("modified", []):
		if row is Array and row.size() == 4:
			modified[Vector3i(int(row[0]), int(row[1]), int(row[2]))] = int(row[3])
	for key in chunks.keys():
		chunks[key].queue_free()
	chunks.clear()
	return true

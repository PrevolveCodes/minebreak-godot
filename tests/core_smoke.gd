extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	assert(BlockDB.name_of(BlockDB.GRASS) == "Grass")
	assert(BlockDB.solid(BlockDB.STONE))
	assert(not BlockDB.solid(BlockDB.AIR))
	var atlas := TextureAtlas.create_atlas()
	assert(atlas != null)
	assert(atlas.get_width() == 64 and atlas.get_height() == 64)
	var chunk := VoxelChunk.new()
	chunk.set_local(2, 7, 3, BlockDB.GRASS)
	assert(chunk.get_local(2, 7, 3) == BlockDB.GRASS)
	assert(chunk.get_local(-1, 7, 3) == BlockDB.AIR)
	assert(chunk.get_local(2, VoxelChunk.HEIGHT, 3) == BlockDB.AIR)
	print("Minebreak core smoke tests passed.")
	quit(0)

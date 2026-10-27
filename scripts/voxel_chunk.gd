extends StaticBody3D
class_name VoxelChunk

const WIDTH := 16
const HEIGHT := 48
const DEPTH := 16
const FACE_DIRS := [
	Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
	Vector3i(0, 1, 0), Vector3i(0, -1, 0),
	Vector3i(0, 0, 1), Vector3i(0, 0, -1)
]
const FACE_VERTS := [
	[Vector3(1,0,1), Vector3(1,1,1), Vector3(1,1,0), Vector3(1,0,0)],
	[Vector3(0,0,0), Vector3(0,1,0), Vector3(0,1,1), Vector3(0,0,1)],
	[Vector3(0,1,1), Vector3(0,1,0), Vector3(1,1,0), Vector3(1,1,1)],
	[Vector3(0,0,0), Vector3(0,0,1), Vector3(1,0,1), Vector3(1,0,0)],
	[Vector3(1,0,1), Vector3(0,0,1), Vector3(0,1,1), Vector3(1,1,1)],
	[Vector3(0,0,0), Vector3(1,0,0), Vector3(1,1,0), Vector3(0,1,0)]
]
var chunk_coord := Vector2i.ZERO
var blocks := PackedByteArray()
var world_ref: Node
var atlas_material: StandardMaterial3D

func _init() -> void:
	blocks.resize(WIDTH * HEIGHT * DEPTH)
	blocks.fill(0)

func index_of(x: int, y: int, z: int) -> int:
	return x + WIDTH * (z + DEPTH * y)

func get_local(x: int, y: int, z: int) -> int:
	if x < 0 or x >= WIDTH or z < 0 or z >= DEPTH or y < 0 or y >= HEIGHT:
		return BlockDB.AIR
	return blocks[index_of(x, y, z)]

func set_local(x: int, y: int, z: int, id: int) -> void:
	if x < 0 or x >= WIDTH or z < 0 or z >= DEPTH or y < 0 or y >= HEIGHT:
		return
	blocks[index_of(x, y, z)] = id

func rebuild() -> void:
	for child in get_children():
		if child is MeshInstance3D or child is CollisionShape3D:
			child.queue_free()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var atlas_size := 4.0
	for y in range(HEIGHT):
		for z in range(DEPTH):
			for x in range(WIDTH):
				var id := int(get_local(x, y, z))
				if id == BlockDB.AIR:
					continue
				for face in range(6):
					var d: Vector3i = FACE_DIRS[face]
					var neighbor := _neighbor_id(x + d.x, y + d.y, z + d.z)
					if not _face_visible(id, neighbor):
						continue
					var tile := BlockDB.tile_for(id, face)
					var tx := tile % 4
					var ty := tile / 4
					var uv0 := Vector2(float(tx) / atlas_size, float(ty) / atlas_size)
					var uv1 := Vector2(float(tx + 1) / atlas_size, float(ty + 1) / atlas_size)
					var uv := [Vector2(uv0.x, uv1.y), uv0, Vector2(uv1.x, uv0.y), uv1]
					var verts: Array = FACE_VERTS[face]
					for tri in [[0, 1, 2], [0, 2, 3]]:
						for vi in tri:
							st.set_uv(uv[vi])
							st.add_vertex(Vector3(x, y, z) + verts[vi])
	st.generate_normals()
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = atlas_material
	add_child(mi)
	var collision := CollisionShape3D.new()
	var shape := mesh.create_trimesh_shape()
	collision.shape = shape
	add_child(collision)

func _neighbor_id(x: int, y: int, z: int) -> int:
	if y < 0:
		return BlockDB.BEDROCK
	if y >= HEIGHT:
		return BlockDB.AIR
	if x >= 0 and x < WIDTH and z >= 0 and z < DEPTH:
		return get_local(x, y, z)
	return world_ref.get_block(chunk_coord.x * WIDTH + x, y, chunk_coord.y * DEPTH + z, false)

func _face_visible(id: int, neighbor: int) -> bool:
	if neighbor == BlockDB.AIR:
		return true
	if id == BlockDB.WATER:
		return neighbor != BlockDB.WATER
	if BlockDB.transparent(id):
		return neighbor != id and neighbor != BlockDB.AIR
	return BlockDB.transparent(neighbor)

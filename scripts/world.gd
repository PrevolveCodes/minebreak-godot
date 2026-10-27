extends Node3D

const WORLD_SIZE := 32
const WORLD_DEPTH := 8
const BLOCK_SIZE := 1.0
const PLAYER_SCRIPT = preload("res://scripts/player.gd")

func _ready() -> void:
	_setup_environment()
	_generate_terrain()
	_spawn_player()
	_setup_controls()

func _setup_environment() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.18, 0.38, 0.72)
	sky_material.sky_horizon_color = Color(0.68, 0.82, 0.96)
	sky_material.ground_bottom_color = Color(0.18, 0.2, 0.18)
	sky_material.ground_horizon_color = Color(0.58, 0.66, 0.58)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.55
	world_env.environment = environment
	add_child(world_env)

func _generate_terrain() -> void:
	var blocks: Dictionary = {}
	var noise := FastNoiseLite.new()
	noise.seed = 1847
	noise.frequency = 0.055
	noise.fractal_octaves = 3

	for x in range(WORLD_SIZE):
		for z in range(WORLD_SIZE):
			var surface_y := 3 + int(round((noise.get_noise_2d(x, z) + 1.0) * 2.0))
			for y in range(surface_y + 1):
				blocks[Vector3i(x, y, z)] = 0 if y == surface_y else 1

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var face_dirs := [
		Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0), Vector3i(0, -1, 0),
		Vector3i(0, 0, 1), Vector3i(0, 0, -1)
	]
	var face_corners := [
		[Vector3(0.5,-0.5,-0.5), Vector3(0.5,0.5,-0.5), Vector3(0.5,0.5,0.5), Vector3(0.5,-0.5,0.5)],
		[Vector3(-0.5,-0.5,0.5), Vector3(-0.5,0.5,0.5), Vector3(-0.5,0.5,-0.5), Vector3(-0.5,-0.5,-0.5)],
		[Vector3(-0.5,0.5,0.5), Vector3(0.5,0.5,0.5), Vector3(0.5,0.5,-0.5), Vector3(-0.5,0.5,-0.5)],
		[Vector3(-0.5,-0.5,-0.5), Vector3(0.5,-0.5,-0.5), Vector3(0.5,-0.5,0.5), Vector3(-0.5,-0.5,0.5)],
		[Vector3(0.5,-0.5,0.5), Vector3(0.5,0.5,0.5), Vector3(-0.5,0.5,0.5), Vector3(-0.5,-0.5,0.5)],
		[Vector3(-0.5,-0.5,-0.5), Vector3(-0.5,0.5,-0.5), Vector3(0.5,0.5,-0.5), Vector3(0.5,-0.5,-0.5)]
	]
	var face_colors := [
		Color(0.48,0.38,0.23), Color(0.48,0.38,0.23),
		Color(0.32,0.68,0.24), Color(0.42,0.32,0.2),
		Color(0.42,0.58,0.25), Color(0.42,0.58,0.25)
	]

	for position in blocks.keys():
		for face_index in range(6):
			if blocks.has(position + face_dirs[face_index]):
				continue
			var corners: Array = face_corners[face_index]
			var points: Array[Vector3] = []
			for corner in corners:
				points.append((Vector3(position) + corner) * BLOCK_SIZE)
			var order := [0, 1, 2, 0, 2, 3]
			for index in order:
				surface.set_normal(Vector3(face_dirs[face_index]))
				surface.set_color(face_colors[face_index])
				surface.add_vertex(points[index])

	var terrain_mesh := surface.commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	terrain_mesh.surface_set_material(0, material)

	var terrain_body := StaticBody3D.new()
	terrain_body.name = "VoxelTerrain"
	terrain_body.collision_layer = 1
	terrain_body.collision_mask = 2
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = terrain_mesh
	terrain_body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	collision.shape = terrain_mesh.create_trimesh_shape()
	terrain_body.add_child(collision)
	add_child(terrain_body)
	terrain_body.position = Vector3(WORLD_SIZE / -2.0, 0, WORLD_SIZE / -2.0)

func _spawn_player() -> void:
	var player := CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0, 12, 0)
	add_child(player)

func _setup_controls() -> void:
	var defaults := {
		"move_forward": KEY_W,
		"move_back": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE
	}
	for action_name in defaults:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		var event := InputEventKey.new()
		event.physical_keycode = defaults[action_name]
		InputMap.action_add_event(action_name, event)

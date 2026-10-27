extends Node3D

var world: VoxelWorld
var player: VoxelPlayer
var hud: Label
var pause_layer: ColorRect
var paused := false
var world_seed := 48271

func _ready() -> void:
	_build_environment()
	world = VoxelWorld.new()
	world.name = "VoxelWorld"
	add_child(world)
	world.initialize(world_seed)
	world.load_world()
	world.load_around(Vector3(0, 30, 0))
	player = VoxelPlayer.new()
	player.name = "Player"
	player.world = world
	player.position = Vector3(8.0, 28.0, 8.0)
	add_child(player)
	_build_hud()
	player.hud = hud
	_make_pause_menu()
	player.world = world
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_environment() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#2865a8")
	sky_mat.sky_horizon_color = Color("#b6d9ef")
	sky_mat.ground_bottom_color = Color("#252c35")
	sky_mat.ground_horizon_color = Color("#9db7c5")
	sky.sky_material = sky_mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.72, 0.78, 0.86)
	e.ambient_light_energy = 0.8
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -35, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(18, 16)
	hud.add_theme_font_size_override("font_size", 16)
	hud.add_theme_color_override("font_color", Color.WHITE)
	hud.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	hud.add_theme_constant_override("shadow_offset_x", 2)
	hud.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(hud)
	var cross := Label.new()
	cross.text = "+"
	cross.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-8, -16)
	cross.add_theme_font_size_override("font_size", 28)
	cross.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(cross)
	var hint := Label.new()
	hint.text = "[1–9] Hotbar     [F3] Switch Survival/Creative     [Esc] Pause"
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.position.y = -34
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	layer.add_child(hint)

func _make_pause_menu() -> void:
	pause_layer = ColorRect.new()
	pause_layer.color = Color(0.02, 0.03, 0.05, 0.88)
	pause_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_layer.visible = false
	var canvas := CanvasLayer.new()
	canvas.name = "PauseUI"
	add_child(canvas)
	canvas.add_child(pause_layer)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	column.position = Vector2(-160, -110)
	column.size = Vector2(320, 220)
	column.add_theme_constant_override("separation", 12)
	pause_layer.add_child(column)
	var title := Label.new()
	title.text = "MINEBREAK — PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	var resume := Button.new()
	resume.text = "Resume"
	resume.custom_minimum_size.y = 44
	resume.pressed.connect(_resume)
	column.add_child(resume)
	var save := Button.new()
	save.text = "Save World"
	save.custom_minimum_size.y = 44
	save.pressed.connect(func(): world.save_world())
	column.add_child(save)
	var quit := Button.new()
	quit.text = "Save and Quit"
	quit.custom_minimum_size.y = 44
	quit.pressed.connect(func():
		world.save_world()
		get_tree().quit()
	)
	column.add_child(quit)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		paused = not paused
		pause_layer.visible = paused
		get_tree().paused = paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED

func _resume() -> void:
	paused = false
	pause_layer.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if world: world.save_world()

extends CharacterBody3D
class_name VoxelPlayer

var world: VoxelWorld
var camera: Camera3D
var speed := 5.0
var jump_velocity := 7.0
var sensitivity := 0.0022
var creative := false
var fly := false
var selected_block := BlockDB.DIRT
var selected_slot := 0
var hotbar := [BlockDB.GRASS, BlockDB.DIRT, BlockDB.STONE, BlockDB.SAND, BlockDB.WOOD, BlockDB.LEAVES, BlockDB.COBBLE, BlockDB.PLANKS, BlockDB.GLASS]
var inventory := {}
var health := 20.0
var hunger := 20.0
var target_block := Vector3i(0, -1, 0)
var place_block := Vector3i(0, -1, 0)
var has_target := false
var hud: Label
var mode_label: Label
var break_timer := 0.0
var hunger_clock := 0.0
var starvation_clock := 0.0
var regeneration_clock := 0.0
var fall_start_y := 0.0

func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	camera = Camera3D.new()
	camera.position.y = 1.62
	camera.current = true
	add_child(camera)
	for id in hotbar:
		inventory[id] = 64
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -1.54, 1.54)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			selected_slot = event.keycode - KEY_1
			selected_block = hotbar[selected_slot]
		if event.keycode == KEY_F:
			if creative: fly = not fly
		if event.keycode == KEY_F3:
			creative = not creative
			fly = creative
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_mine()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_place()

func _physics_process(delta: float) -> void:
	if world == null: return
	var direction := Vector3.ZERO
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	if Input.is_key_pressed(KEY_W): direction += forward
	if Input.is_key_pressed(KEY_S): direction -= forward
	if Input.is_key_pressed(KEY_D): direction += right
	if Input.is_key_pressed(KEY_A): direction -= right
	direction.y = 0
	direction = direction.normalized()
	var current_speed := speed * (1.6 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
	var grounded_before := is_on_floor()
	if grounded_before:
		fall_start_y = global_position.y
	elif fall_start_y <= 0.0:
		fall_start_y = global_position.y
	if creative and fly:
		velocity = direction * current_speed
		if Input.is_key_pressed(KEY_SPACE): velocity.y = current_speed
		elif Input.is_key_pressed(KEY_CTRL): velocity.y = -current_speed
	else:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if not is_on_floor(): velocity.y -= 20.0 * delta
		if Input.is_key_pressed(KEY_SPACE) and is_on_floor(): velocity.y = jump_velocity
	move_and_slide()
	if not creative and not grounded_before and is_on_floor():
		var fall_distance := fall_start_y - global_position.y
		if fall_distance > 3.0:
			health = maxf(0.0, health - floorf(fall_distance - 3.0))
		fall_start_y = global_position.y
	_update_survival(delta)
	world.load_around(global_position)
	_update_target()
	if hud:
		var mode := "CREATIVE" if creative else "SURVIVAL"
		hud.text = "Minebreak  |  %s  |  HP %d  |  Seed %d\nWASD move • Space jump/fly • Shift sprint • F3 toggle mode • Left mine • Right place • Esc pause\nSelected: %s × %d" % [mode, int(health), world.seed_value, BlockDB.name_of(selected_block), int(inventory.get(selected_block, 0))]

func _update_target() -> void:
	has_target = false
	var origin := camera.global_position
	var dir := -camera.global_transform.basis.z
	var previous := Vector3i(floori(origin.x), floori(origin.y), floori(origin.z))
	for step in range(1, 65):
		var point := origin + dir * (float(step) * 0.1)
		var cell := Vector3i(floori(point.x), floori(point.y), floori(point.z))
		if cell == previous: continue
		var id := world.get_block(cell.x, cell.y, cell.z)
		if id != BlockDB.AIR and id != BlockDB.WATER:
			target_block = cell
			place_block = previous
			has_target = true
			return
		previous = cell

func _mine() -> void:
	if not has_target: return
	var id := world.get_block(target_block.x, target_block.y, target_block.z)
	if id == BlockDB.BEDROCK: return
	world.set_block(target_block.x, target_block.y, target_block.z, BlockDB.AIR)
	if not creative: inventory[id] = mini(64, int(inventory.get(id, 0)) + 1)

func _place() -> void:
	if not has_target: return
	if not creative and int(inventory.get(selected_block, 0)) <= 0: return
	var center := global_position
	if abs(place_block.x + 0.5 - center.x) < 0.7 and abs(place_block.z + 0.5 - center.z) < 0.7 and place_block.y < center.y + 1.8 and place_block.y + 1 > center.y:
		return
	if world.get_block(place_block.x, place_block.y, place_block.z) != BlockDB.AIR: return
	world.set_block(place_block.x, place_block.y, place_block.z, selected_block)
	if not creative: inventory[selected_block] = int(inventory.get(selected_block, 0)) - 1

func _update_survival(delta: float) -> void:
	if creative:
		health = 20.0
		hunger = 20.0
		hunger_clock = 0.0
		starvation_clock = 0.0
		regeneration_clock = 0.0
		return
	hunger_clock += delta
	if hunger_clock >= 30.0:
		hunger_clock -= 30.0
		hunger = maxf(0.0, hunger - 1.0)
	if hunger <= 0.0:
		starvation_clock += delta
		if starvation_clock >= 5.0:
			starvation_clock -= 5.0
			health = maxf(0.0, health - 1.0)
	else:
		starvation_clock = 0.0
	if hunger >= 18.0 and health > 0.0 and health < 20.0:
		regeneration_clock += delta
		if regeneration_clock >= 4.0:
			regeneration_clock -= 4.0
			health = minf(20.0, health + 1.0)
	else:
		regeneration_clock = 0.0
	if health <= 0.0:
		global_position = Vector3(8.0, 30.0, 8.0)
		velocity = Vector3.ZERO
		health = 20.0
		hunger = 20.0
		fall_start_y = 0.0

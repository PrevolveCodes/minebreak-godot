extends RefCounted
class_name BlockDB

const AIR := 0
const GRASS := 1
const DIRT := 2
const STONE := 3
const SAND := 4
const WOOD := 5
const LEAVES := 6
const COBBLE := 7
const PLANKS := 8
const GLASS := 9
const BEDROCK := 10
const WATER := 11
const COAL_ORE := 12
const IRON_ORE := 13
const SNOW := 14

static func name_of(id: int) -> String:
	var names := ["Air", "Grass", "Dirt", "Stone", "Sand", "Log", "Leaves", "Cobblestone", "Planks", "Glass", "Bedrock", "Water", "Coal Ore", "Iron Ore", "Snow"]
	return names[id] if id >= 0 and id < names.size() else "Unknown"

static func solid(id: int) -> bool:
	return id != AIR and id != WATER

static func transparent(id: int) -> bool:
	return id == AIR or id == LEAVES or id == GLASS or id == WATER

static func tile_for(id: int, face: int) -> int:
	if id == GRASS:
		return 0 if face == 2 else (1 if face == 3 else 2)
	if id == WOOD:
		return 5 if face == 2 or face == 3 else 6
	match id:
		DIRT: return 2
		STONE: return 3
		SAND: return 4
		LEAVES: return 7
		COBBLE: return 8
		PLANKS: return 9
		GLASS: return 10
		BEDROCK: return 11
		WATER: return 12
		COAL_ORE: return 13
		IRON_ORE: return 14
		SNOW: return 15
	return 11

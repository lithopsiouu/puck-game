extends TileMapLayer

@onready var tileset = "res://assets/palette/didi4/greenWorld.tres"
@onready var smashParticlePrim = preload("res://particles/smash_particles.tscn")
@onready var smashParticleTert = preload("res://particles/smash_particles_tertiary.tscn")
@onready var bubbleParticle = preload("res://particles/bubbles.tscn")
@onready var toiletParticle = preload("res://particles/toilet.tscn")
@onready var flagParticle = preload("res://particles/flag.tscn")

var isExitGamemode = false
var isTimedGamemode = false

var hurtWalls = {}
const atlasNames = {
	#              colors: 3 = primary, 2 = secondary, 1 = tertiary, 0 = background
	#   special particles: 4 = TOILET, 5 = WIN
	"Rock": {"atlas": Vector2i(7, 7), "health": 0, "tileShiftDir": 0, "color": 1},
	
	"Toilet": {"atlas": Vector2i(7, 16), "health": 0, "tileShiftDir": 0, "color": 4},
	
	"Flag": {"atlas": Vector2i(0, 0), "health": 0, "tileShiftDir": 0, "color": 5},
	
	"Brick": {"atlas": Vector2i(4, 6), "health": 2, "tileShiftDir": -1, "color": 1}, #full brick tile
	"Brick1": {"atlas": Vector2i(3, 6), "health": 1, "tileShiftDir": -1, "color": 1}, #flowery brick tile
	"Brick2": {"atlas": Vector2i(2, 6), "health": 0, "tileShiftDir": 0, "color": 1}, #smaller flowery brick tile
	
	"Gem": {"atlas": Vector2i(23, 18), "health": 2, "tileShiftDir": 1, "color": 3}, #round gem
	"Gem1": {"atlas": Vector2i(24, 18), "health": 1, "tileShiftDir": 1, "color": 3}, #diamond gem
	"Gem2": {"atlas": Vector2i(25, 18), "health": 0, "tileShiftDir": 1, "color": 3}, #thin long gem
	
	"Bars": {"atlas": Vector2i(5, 12), "health": 1, "tileShiftDir": 1, "color": 3}, #full bars
	"Bars1": {"atlas": Vector2i(6, 12), "health": 0, "tileShiftDir": 0, "color": 3}, #broken bars
	
	"ChainFence": {"atlas": Vector2i(11, 12), "health": 2, "tileShiftDir": 1, "color": 3}, #full chainlink fence
	"ChainFence1": {"atlas": Vector2i(12, 12), "health": 0, "tileShiftDir": 0, "color": 3} #broken chainlink fence
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("wall_hurt", on_event_wall_hurt)
	EventController.connect("send_gamemode", checkGamemode)

func on_event_wall_hurt(tileRID: RID, playerPos: Vector2):
	var cellPos = get_coords_for_body_rid(tileRID)
	var cellPosGlobal = map_to_local(cellPos)
	do_wall_damage(tileRID, cellPos, playerPos)
	var nearCells = get_surrounding_cells(cellPos)
	if !nearCells.is_empty():
		#print(str(nearCells))
		for cell in nearCells:
			if get_is_tile_breakable(cell):
				var nearCellPosGlobal = map_to_local(cell)
				
		#do_wall_damage(tileRID, cellPos, playerPos)

#takes cellPos to get atlas coords and tileRID to compare to the hurtWalls array
func do_wall_damage(tileRID: RID, cellPos: Vector2i, playerPos: Vector2):
	var targetTileAtlasCoords = get_cell_atlas_coords(cellPos)
	var particleColor = get_subdict_key_from_tilename(get_tile_name_from_atlas(cellPos),"color")
	if particleColor != 4:
		makeNewParticle(cellPos, playerPos, true, particleColor)
	else:
		makeNewParticle(cellPos, playerPos, false, particleColor)
	if hurtWalls.has(tileRID): #if tile already has health
		hurtWalls[tileRID] -= 1
		if hurtWalls[tileRID] > 0: #change health if tile health is greater than zero
			print(str(get_tile_name_from_atlas(cellPos)) +" tile health: " + str(hurtWalls[tileRID]))
			shift_cell_atlas_x(cellPos, get_subdict_key_from_tilename(get_tile_name_from_atlas(cellPos),"tileShiftDir"), targetTileAtlasCoords)
		else: #delete tile if tile health is less than zero
			print(str(get_tile_name_from_atlas(cellPos)) +" tile deleted: " + str(tileRID))
			if get_tile_name_from_atlas(cellPos) == "Gem2":
				EventController.emit_signal("gem_smashed")
			elif get_tile_name_from_atlas(cellPos) == "Flag" and (isExitGamemode or isTimedGamemode):
				EventController.emit_signal("game_win")
			removeCell(cellPos)
	
	else: #if tile does not already have health
		hurtWalls[tileRID] = get_subdict_key_from_tilename(get_tile_name_from_atlas(cellPos),"health")
		if hurtWalls[tileRID] > 0: #create new health and change tile
			print("new "+ str(get_tile_name_from_atlas(cellPos)) +" tile health added: " + str(hurtWalls[tileRID]))
			shift_cell_atlas_x(cellPos, get_subdict_key_from_tilename(get_tile_name_from_atlas(cellPos),"tileShiftDir"), targetTileAtlasCoords)
		else: #destroy tile without creating health
			print("new "+ str(get_tile_name_from_atlas(cellPos)) +" tile deleted: " + str(tileRID))
			if get_tile_name_from_atlas(cellPos) == "Gem2":
				EventController.emit_signal("gem_smashed")
			elif get_tile_name_from_atlas(cellPos) == "Flag" and (isExitGamemode or isTimedGamemode):
				EventController.emit_signal("game_win")
			removeCell(cellPos)
	#print(str(get_child_count()))

#shifts cell's atlas coordinates by the direction and amount using the cell's location
func shift_cell_atlas_x(cellPos, changeDir: int, atlasCoords : Vector2i):
	if changeDir == 0:
		set_cell(cellPos, get_cell_source_id(cellPos), Vector2((atlasCoords.x + changeDir), atlasCoords.y))
	else:
		set_cell(cellPos, get_cell_source_id(cellPos), Vector2((atlasCoords.x + changeDir), atlasCoords.y))

#deletes the cell
func removeCell(cellPos: Vector2):
	erase_cell(cellPos)

func makeNewParticle(cellPos, playerPos, followPlayerDir : bool, color : int):
	var instance
	match color:
		3: instance = smashParticlePrim.instantiate()
		1: instance = smashParticleTert.instantiate()
		4: instance = toiletParticle.instantiate()
		5: instance = flagParticle.instantiate()
		_:
			push_warning("No particle exists for this color.")
	if instance:
		instance.position = map_to_local(cellPos)
		if followPlayerDir:
			#multiply cellPos by 4 because that's what the tilemap is scaled by
			instance.rotation = atan2((map_to_local(cellPos*4) - playerPos).normalized().y, (map_to_local(cellPos*4) - playerPos).normalized().x)
		
		add_child(instance)
		instance.emitting = true
		#print("emitting " + str(instance))
		await get_tree().create_timer(1.2).timeout
		instance.queue_free()

func get_tile_name_from_atlas(cellPos : Vector2i):
	var data = get_cell_tile_data(cellPos)
	if data:
		return str(data.get_custom_data("tileName"))
	else:
		return null

func get_is_tile_breakable(cellPos : Vector2i) -> bool:
	var data = get_cell_tile_data(cellPos)
	if data:
		return data.get_custom_data("breakable")
	else:
		return false

func get_subdict_key_from_tilename(tileName : String, subDictName : String):
	return atlasNames[tileName][subDictName]

func checkGamemode(mode) -> void:
	match mode:
		2:
			isTimedGamemode = true
		1:
			var totalGems: int = 0
			totalGems += get_used_cells_by_id(-1, atlasNames.Gem.atlas).size()
			totalGems += get_used_cells_by_id(-1, atlasNames.Gem1.atlas).size()
			totalGems += get_used_cells_by_id(-1, atlasNames.Gem2.atlas).size()
			EventController.emit_signal("send_total_gems", totalGems)
		0:
			isExitGamemode = true

extends TileMapLayer

@onready var tileset = "res://assets/palette/didi4/greenWorld.tres"

var hurtWalls = {}
const atlasNames = {
	"Rock": {"atlas": Vector2i(7, 7), "health": 0, "tileShiftDir": 0},
	
	"Brick": {"atlas": Vector2i(4, 6), "health": 2, "tileShiftDir": -1}, #full brick tile
	"Brick1": {"atlas": Vector2i(3, 6), "health": 1, "tileShiftDir": -1}, #flowery brick tile
	"Brick2": {"atlas": Vector2i(2, 6), "health": 0, "tileShiftDir": 0}, #smaller flowery brick tile
	
	"Bars": {"atlas": Vector2i(5, 12), "health": 1, "tileShiftDir": 1}, #full bars
	"Bars1": {"atlas": Vector2i(6, 12), "health": 0, "tileShiftDir": 0}, #broken bars
	
	"ChainFence": {"atlas": Vector2i(11, 12), "health": 2, "tileShiftDir": 1}, #full chainlink fence
	"ChainFence1": {"atlas": Vector2i(12, 12), "health": 0, "tileShiftDir": 0} #broken chainlink fence
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("wall_hurt", on_event_wall_hurt)

func on_event_wall_hurt(tileRID: RID):
	var cellPos = get_coords_for_body_rid(tileRID)
	do_wall_damage(tileRID, cellPos)

#takes cellPos to get atlas coords and tileRID to compare to the hurtWalls array
func do_wall_damage(tileRID: RID, cellPos: Vector2):
	var targetTileAtlasCoords = get_cell_atlas_coords(cellPos)
	if hurtWalls.has(tileRID): #if tile already has health
		hurtWalls[tileRID] -= 1
		if hurtWalls[tileRID] > 0: #change health if tile health is greater than zero
			print(str(get_tile_name_from_atlas(cellPos)) +" tile health: " + str(hurtWalls[tileRID]))
			shift_cell_atlas_x(cellPos, get_subdict_key_from_tilename(get_tile_name_from_atlas(cellPos),"tileShiftDir"), targetTileAtlasCoords)
		else: #delete tile if tile health is less than zero
			print(str(get_tile_name_from_atlas(cellPos)) +" tile deleted: " + str(tileRID))
			removeCell(cellPos)
	
	else: #if tile does not already have health
		hurtWalls[tileRID] = get_subdict_key_from_tilename(get_tile_name_from_atlas(cellPos),"health")
		if hurtWalls[tileRID] > 0: #create new health and change tile
			print("new "+ str(get_tile_name_from_atlas(cellPos)) +" tile health added: " + str(hurtWalls[tileRID]))
			shift_cell_atlas_x(cellPos, get_subdict_key_from_tilename(get_tile_name_from_atlas(cellPos),"tileShiftDir"), targetTileAtlasCoords)
		else: #destroy tile without creating health
			print("new "+ str(get_tile_name_from_atlas(cellPos)) +" tile deleted: " + str(tileRID))
			removeCell(cellPos)

#shifts cell's atlas coordinates by the direction and amount using the cell's location
func shift_cell_atlas_x(cellPos, changeDir: int, atlasCoords : Vector2i):
	if changeDir == 0:
		set_cell(cellPos, get_cell_source_id(cellPos), Vector2((atlasCoords.x + changeDir), atlasCoords.y))
	else:
		set_cell(cellPos, get_cell_source_id(cellPos), Vector2((atlasCoords.x + changeDir), atlasCoords.y))

#deletes the cell
func removeCell(cellPos: Vector2):
	erase_cell(cellPos)

func get_tile_name_from_atlas(cellPos : Vector2i):
	var data = get_cell_tile_data(cellPos)
	if data:
		return str(data.get_custom_data("tileName"))
	else:
		return null

func get_subdict_key_from_tilename(tileName : String, subDictName : String):
	return atlasNames[tileName][subDictName]

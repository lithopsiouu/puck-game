extends TileMapLayer

var hurtWalls = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("wall_hurt", on_event_wall_hurt)

func on_event_wall_hurt(tileRID: RID):
	var tilePos = get_coords_for_body_rid(tileRID)
	do_wall_damage(tileRID, tilePos)

func do_wall_damage(tileRID: RID, tilePos: Vector2):
	var targetTileAtlasCoords = get_cell_atlas_coords(tilePos)
	if hurtWalls.has(tileRID):
		hurtWalls[tileRID] -= 1
		if hurtWalls[tileRID] > 0:
			print("tile health: " + str(hurtWalls[tileRID]))
		else:
			removeTile(tilePos)
			print("tile deleted: " + str(tileRID))
	else:
		hurtWalls[tileRID] = getTileHealthFromAtlas(tilePos)
		print("new tile health added: " + str(hurtWalls[tileRID]))
	
	change_wall_tile_x(tilePos, increment_or_decrement_health(targetTileAtlasCoords), targetTileAtlasCoords)

func change_wall_tile_x(tilePos, direciton: int, atlasCoords : Vector2i):
	set_cell(tilePos, get_cell_source_id(tilePos), Vector2((atlasCoords.x + direciton), atlasCoords.y))

func removeTile(tilePos: Vector2):
	erase_cell(tilePos)

func increment_or_decrement_health(atlasCoords : Vector2i):
	var numberToUse : int
	match atlasCoords:
		Vector2i(4, 6): #full brick tile
			numberToUse = -1
		Vector2i(3, 6): #flowery brick tile
			numberToUse = -1
		Vector2i(2, 6): #smaller flowery brick tile
			numberToUse = -1
			
		Vector2i(5, 12): #bar fence
			numberToUse = 1
		Vector2i(6, 12): #bar fence with hole
			numberToUse = 1
			
		Vector2i(7, 7): #rock
			numberToUse = 0
	return numberToUse

func getTileHealthFromAtlas(atlasCoords : Vector2i):
	var health : int
	match atlasCoords:
		Vector2i(4, 6): #full brick tile
			health = 2
		Vector2i(3, 6): #flowery brick tile
			health = 1
		Vector2i(2, 6): #smaller flowery brick tile
			health = 0
			
		Vector2i(5, 12): #bar fence
			health = 1
		Vector2i(6, 12): #bar fence with hole
			health = 0
			
		Vector2i(7, 7): #rock
			health = 0
	return health

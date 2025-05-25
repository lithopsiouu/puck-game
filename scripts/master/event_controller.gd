extends Node

signal coin_collected(value: int)

signal gem_smashed()

signal send_gamemode(mode: int)

signal send_timer(time: int)

signal get_current_time(time: float)

signal game_win()

signal send_total_gems(gems: int)

signal wall_hurt(targetTile: RID, puckPos)

signal player_under_cam_snap(value: bool)

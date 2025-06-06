extends Node

signal coin_collected(value: int)

signal gem_smashed()

signal send_gamemode(mode: int)

signal send_timer(time: int)

signal get_current_time(time: float)

signal send_final_time(time: float)

signal game_win()

signal save_level_stats()

signal reset_game_shit()

signal send_total_gems(gems: int)

signal send_total_coins(coins: int)

signal total_coins_from_screen_effects(coins: int)

signal wall_hurt(targetTile: RID, puckPos)

signal player_under_cam_snap(value: bool)

signal restart_level()

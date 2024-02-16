extends Node

@onready var music_player=$music_player
@onready var audio_player=$sound_player

var music_enabled=GameDataManager.level_info[0]["music_enabled"]
var sound_enabled=GameDataManager.level_info[0]["sound_enabled"]
var vibration_enabled=GameDataManager.level_info[0]["vibration_enabled"]

func check_dict():
	music_enabled=GameDataManager.level_info[0]["music_enabled"]
	sound_enabled=GameDataManager.level_info[0]["sound_enabled"]
	vibration_enabled=GameDataManager.level_info[0]["vibration_enabled"]
	if music_enabled:
		turn_on_music()
	else:
		turn_off_music()

func _ready():
	music_enabled=GameDataManager.level_info[0]["music_enabled"]
	sound_enabled=GameDataManager.level_info[0]["sound_enabled"]
	vibration_enabled=GameDataManager.level_info[0]["vibration_enabled"]
	randomize()

var sound_direct=preload("res://scenes/ui_scenes/sound_direct.tscn")
var music_direct=preload("res://scenes/ui_scenes/music_direct.tscn")

var old_match_enabled=true
var old_move_enabled=true

var fixed_sounds= {
	#button sfx
	"button_pressed":preload("res://Assets/artwork/sfx/button/button_press.wav"),
	"button_released":preload("res://Assets/artwork/sfx/button/button_release.wav"),
	"main_menu_button_pressed":preload("res://Assets/artwork/sfx/button/main_menu.wav"),
	
	#switch sfx
	"swap_pieces":preload("res://Assets/artwork/sfx/switch/switch_sound.wav"),
	"swap_back":preload("res://Assets/artwork/sfx/switch/negative_switch.wav"),
	
	#match sfx
	"match":preload("res://Assets/artwork/sfx/match/match_3.wav"),
	
	#old match sfx
	"match_1":preload("res://Assets/artwork/sfx/old/match/pop_match.wav"),
	"match_2":preload("res://Assets/artwork/sfx/old/match/pop_match_2.wav"),
	"match_3":preload("res://Assets/artwork/sfx/old/match/pop_match_3.wav"),
	
#	#refill sfx
	"refill_1":preload("res://Assets/artwork/sfx/refill/land_1.wav"),
	"refill_2":preload("res://Assets/artwork/sfx/refill/land_2.wav"),
	"refill_3":preload("res://Assets/artwork/sfx/refill/land_3.wav"), 
	"refill_4":preload("res://Assets/artwork/sfx/refill/land_4.wav"),
	
	#old refill sfx
#	"refill_1":preload("res://Assets/artwork/sfx/old/refill/refill_sound (1).wav"),
#	"refill_2":preload("res://Assets/artwork/sfx/old/refill/refill_sound (2).wav"),
#	"refill_3":preload("res://Assets/artwork/sfx/old/refill/refill_sound (3).wav"),
	
	#old move sfx
	"move_1":preload("res://Assets/artwork/sfx/old/move/piece_move (1).wav"),
	"move_2":preload("res://Assets/artwork/sfx/old/move/piece_move (2).wav"),
	"move_3":preload("res://Assets/artwork/sfx/old/move/piece_move (3).wav"),
	"move_4":preload("res://Assets/artwork/sfx/old/move/piece_move (4).wav"),
	"move_5":preload("res://Assets/artwork/sfx/old/move/piece_move (5).wav"),
	"move_6":preload("res://Assets/artwork/sfx/old/move/piece_move (6).wav"),
	"move_7":preload("res://Assets/artwork/sfx/old/move/piece_move (7).wav"),
	"move_8":preload("res://Assets/artwork/sfx/old/move/piece_move (8).wav"),
	"move_9":preload("res://Assets/artwork/sfx/old/move/piece_move (9).wav"),
	
	#old cascade sfx
	"cascade_1":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (1).wav"),
	"cascade_2":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (2).wav"),
	"cascade_3":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (3).wav"),
	"cascade_4":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (4).wav"),
	"cascade_5":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (5).wav"),
	"cascade_6":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (6).wav"),
	"cascade_7":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (7).wav"),
	"cascade_8":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (8).wav"),
	"cascade_9":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (9).wav"),
	"cascade_10":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (10).wav"),
	"cascade_11":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (11).wav"),
	"cascade_12":preload("res://Assets/artwork/sfx/old/cascade/casdace_xylophone (12).wav"),
	
#	#cascade sfx
#	"cascade_1":preload("res://Assets/artwork/sfx/cascade/cascade_1.wav"),
#	"cascade_2":preload("res://Assets/artwork/sfx/cascade/cascade_2.wav"),
#	"cascade_3":preload("res://Assets/artwork/sfx/cascade/cascade_3.wav"),
#	"cascade_4":preload("res://Assets/artwork/sfx/cascade/cascade_4.wav"),
#	"cascade_5":preload("res://Assets/artwork/sfx/cascade/cascade_5.wav"),
#	"cascade_6":preload("res://Assets/artwork/sfx/cascade/cascade_6.wav"),
#	"cascade_7":preload("res://Assets/artwork/sfx/cascade/cascade_7.wav"),
#	"cascade_8":preload("res://Assets/artwork/sfx/cascade/cascade_8.wav"),
#	"cascade_9":preload("res://Assets/artwork/sfx/cascade/cascade_9.wav"),
#	"cascade_10":preload("res://Assets/artwork/sfx/cascade/cascade_10.wav"),
#	"cascade_11":preload("res://Assets/artwork/sfx/cascade/cascade_11.wav"),
#	"cascade_12":preload("res://Assets/artwork/sfx/cascade/cascade_12.wav"),
	
	#win sfx
	"1_star":preload("res://Assets/artwork/sfx/win/1_star.wav"),
	"2_star":preload("res://Assets/artwork/sfx/win/2_star.wav"),
	"3_star":preload("res://Assets/artwork/sfx/win/3_star.wav"),
	"next_level_unlocked":preload("res://Assets/artwork/sfx/win/next_level_unlocked.wav"),
	"fairy_glitter":preload("res://Assets/artwork/sfx/win/fairy_glitter.wav"),
	"points_tick":preload("res://Assets/artwork/sfx/win/tick_looped.wav"),
	"points_tally":preload("res://Assets/artwork/sfx/win/tally.mp3.wav"),
	
	#booster sfx
	"booster_spawn_1":preload("res://Assets/artwork/sfx/booster/booster_spawn_1.wav"),
	"booster_spawn_2":preload("res://Assets/artwork/sfx/booster/booster_spawn_2.wav"),
	"booster_spawn_3":preload("res://Assets/artwork/sfx/booster/booster_spawn_3.wav"),
	"booster_spawn_4":preload("res://Assets/artwork/sfx/booster/booster_spawn_4.wav"),
	
	#obstacle sfx
	"damage_concrete":preload("res://Assets/artwork/sfx/obstacle/concrete_piece_destroyed.wav"), 
	"damage_ice":preload("res://Assets/artwork/sfx/obstacle/ice_piece_destroyed.wav"),
	"damage_lock":preload("res://Assets/artwork/sfx/obstacle/lock_piece_destroyed.wav"),
	"damage_sinker":preload("res://Assets/artwork/sfx/obstacle/sinker_piece_destroyed.wav"),
	"damage_slime":preload("res://Assets/artwork/sfx/obstacle/slime_piece_destroyed.wav"), 
	
	#bomb sfx
	"color_bomb_explode":preload("res://Assets/artwork/sfx/bomb/color_bomb_explode.wav"),
	"colrow_explode":preload("res://Assets/artwork/sfx/bomb/colrow_explode.wav"),
	"adj_explode":preload("res://Assets/artwork/sfx/bomb/adj_explode.wav"),
	"colrow_bomb_created":preload("res://Assets/artwork/sfx/bomb/colrow_created.wav"),
	"adjacent_bomb_created":preload("res://Assets/artwork/sfx/bomb/adj_created.wav"),
	"color_bomb_created":preload("res://Assets/artwork/sfx/bomb/color_bomb_created.wav"),
	"detonation":preload("res://Assets/artwork/sfx/bomb/detonation.wav"),
	"whoosh":preload("res://Assets/artwork/sfx/bomb/whoosh.wav"), #colrow+adj
	"colrow_adj":preload("res://Assets/artwork/sfx/bomb/colrow_adj.wav"),#colrow+adj
	"adjacent_combine":preload("res://Assets/artwork/sfx/bomb/adj_combine.wav"),
	
	#state sfx
	"lose":preload("res://Assets/artwork/sfx/state/failiure.wav"),
	"level_goal_achieved":preload("res://Assets/artwork/sfx/state/level_goal_achieved.wav"),
	"purchase":preload("res://Assets/artwork/sfx/state/purchase.wav"),
	"win":preload("res://Assets/artwork/sfx/state/win.wav"),
	"shuffle":preload("res://Assets/artwork/sfx/state/shuffle.wav"),
	"obtain":preload("res://Assets/artwork/sfx/state/obtain.wav"),
	"obtain_negative":preload("res://Assets/artwork/sfx/state/purchase_negative.wav"),
	
	
	#level select
	"walk":preload("res://Assets/artwork/sfx/level_select/walk.wav"),
	"climb":preload("res://Assets/artwork/sfx/level_select/climb.wav"),
	"portal":preload("res://Assets/artwork/sfx/level_select/portal.wav"),
}

var fixed_music = {
	"space_breeze":preload("res://Assets/artwork/sfx/music/space_breeeze.wav"),
	"level_select_1":preload("res://Assets/artwork/sfx/music/level_select_1.wav"),
	"loop_1":preload("res://Assets/artwork/sfx/music/loop_1.wav"),
	"main_menu":preload("res://Assets/artwork/sfx/music/main_menu.wav"),
}

func turn_on_music():
	music_player.set_volume_db(0)

func turn_off_music():
	music_player.set_volume_db(-100)


func play_fixed_sound(sound):
	if sound_enabled==true:
		if sound=="match" and old_match_enabled:
			play_random_match_sound()
		else:
			if sound=="swap_pieces" and old_move_enabled:
				play_random_move_sound()
			else:
				var sound_to_play=fixed_sounds[sound]
				var sound_player=sound_direct.instantiate()
				add_child(sound_player)
				sound_player.play_sound(sound_to_play)

func play_random_match_sound():
	var temp=floor(randf_range(1,4))
	var sound_to_play=fixed_sounds[str("match_")+str(temp)]
	var sound_player=sound_direct.instantiate()
	add_child(sound_player)
	sound_player.play_sound(sound_to_play)

func play_random_move_sound():
	var temp=floor(randf_range(1,10))
	var sound_to_play=fixed_sounds[str("move_")+str(temp)]
	var sound_player=sound_direct.instantiate()
	add_child(sound_player)
	sound_player.play_sound(sound_to_play)

func play_fixed_music(music):
	if music_enabled==true:
		var music_to_play=fixed_music[music]
		var musics_player=music_direct.instantiate()
		add_child(musics_player)
		musics_player.play_music(music_to_play)

func play_tracked_sound(sound):
	if sound_enabled:
		audio_player.stream=fixed_sounds[sound]
		audio_player.play()

func stop_tracked_sound():
	audio_player.stop()

func stop_fixed_music():
	music_player.stop()

func play_tracked_music(music):
	if music_enabled:
		music_player.stream=fixed_music[music]
		music_player.play()

func stop_tracked_music():
	music_player.stop()

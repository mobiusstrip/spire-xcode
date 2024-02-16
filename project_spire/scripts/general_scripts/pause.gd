extends Node2D

func _ready():
	if GameDataManager.level_info[0]["sound"]:
		$pause_menu/sounds_button.button_pressed=false
	else:
		$pause_menu/sounds_button.button_pressed=true

	if GameDataManager.level_info[0]["music"]:
		$pause_menu/music_button.button_pressed=false
	else:
		$pause_menu/music_button.button_pressed=true

	if GameDataManager.level_info[0]["vibration"]:
		$pause_menu/vibration_button.button_pressed=false
	else:
		$pause_menu/vibration_button.button_pressed=true


func _on_problems_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")


func _on_vibration_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")


func _on_sounds_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	GameDataManager.level_info[0]["sound"] =! GameDataManager.level_info[0]["sound"]
	GameDataManager.save_data()

func _on_music_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	GameDataManager.level_info[0]["music"] =! GameDataManager.level_info[0]["music"]
	GameDataManager.save_data()

func _on_quit_level_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	Transition.change_scene_to_file("res://scenes/level_select_scenes/level_select.tscn","fade_purple")


func _on_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	get_tree().paused=false
	$pause_menu.visible=false
	$blackout.visible=false
	
	
func _on_setting_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $ui/settings.visible==true:
		$settings.visible=false
		get_tree().paused=false
	else:
		$settings.visible=true
		$settings.visible=true
		get_tree().paused=true

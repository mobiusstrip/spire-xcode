extends Node2D

func _ready():
	if GameDataManager.level_info[0]["sound_enabled"]:
		$sound_button.button_pressed=false
	else:
		$sound_button.button_pressed=true

	if GameDataManager.level_info[0]["sound_enabled"]:
		$music_button.button_pressed=false
	else:
		$music_button.button_pressed=true

	if GameDataManager.level_info[0]["sound_enabled"]:
		$vibration_button.button_pressed=false
	else:
		$vibration_button.button_pressed=true

func _on_music_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if SoundManager.music_enabled:
		GameDataManager.modify_dict(0,"music_enabled",false)
		SoundManager.check_dict()
	else:
		GameDataManager.modify_dict(0,"music_enabled",true)
		SoundManager.check_dict()

func _on_sound_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if SoundManager.sound_enabled:
		GameDataManager.modify_dict(0,"sound_enabled",false)
		SoundManager.check_dict()
	else:
		GameDataManager.modify_dict(0,"sound_enabled",true)
		SoundManager.check_dict()
	
func _on_vibration_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if SoundManager.vibration_enabled:
		GameDataManager.modify_dict(0,"vibration_enabled",false)
		SoundManager.check_dict()
	else:
		GameDataManager.modify_dict(0,"vibration_enabled",true)
		SoundManager.check_dict()

func _on_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$".".visible=false

func _on_leave_button_pressed():
	$".".visible=false
	get_parent().get_node("quit_confirm").visible=true


func _on_confirm_leave_button_pressed():
	Transition.change_scene_to_file("res://scenes/level_select_scenes/level_select.tscn","fade_blue")


func _on_confim_cancel_button_pressed():
	get_parent().get_node("quit_confirm").visible=false

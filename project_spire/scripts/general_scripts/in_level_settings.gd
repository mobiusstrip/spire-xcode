extends Node2D

var quit_confirm=preload("res://scenes/ui_scenes/quit_confirm.tscn") 

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
	queue_free()

func _on_leave_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	queue_free()
	var current = quit_confirm.instantiate()
	get_tree().get_root().add_child(current)
	current.z_index=10
	

func _on_quit_cancel_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	queue_free()

func _on_quit_exit_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	print("exit")
	queue_free()

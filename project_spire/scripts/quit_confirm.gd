extends Node2D

func _on_quit_cancel_pressed():
	queue_free()


func _on_quit_exit_pressed():
	SoundManager.stop_tracked_music()
	SoundManager.stop_tracked_sound()
	SoundManager.play_fixed_sound("button_pressed")
	Transition.change_scene_to_file("res://scenes/level_select_scenes/level_select.tscn","fade_blue")

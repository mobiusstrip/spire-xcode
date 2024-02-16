extends Node2D

func _ready():
	SoundManager.play_tracked_music("main_menu")
	$Label.visible=true
	$play_button.visible=false
	$loading_button.visible=true
	$Timer.start()
	
func _on_play_button_pressed():
	SoundManager.play_fixed_sound("main_menu_button_pressed")
	SoundManager.stop_tracked_music()
	Transition.change_scene_to_file("res://scenes/level_select_scenes/level_select.tscn","fade_blue")

func _on_settings_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$settings.visible=true

func _on_ScrollContainer_scroll_started():
	$label.text="Part-2"
	
	
func _on_Timer_timeout():
	SoundManager.play_tracked_sound("obtain")
	$play_button.visible=true
	$loading_button.visible=false
	$Label.visible=false

func _on_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$settings.visible=false


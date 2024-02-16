extends Node2D

@onready var score_label = $gameover_menu/score_label
var current_score = 0

func _on_grid_update_score(amount_to_change):
	current_score += amount_to_change
	score_label.text = str(current_score)

func _on_grid_game_over():
	$".".visible=true
	SoundManager.play_fixed_sound("lose")
	$AnimationPlayer.play("game_over")

func _on_quit_button_pressed():
	SoundManager.stop_tracked_music()
	SoundManager.play_fixed_sound("button_pressed")
	Transition.change_scene_to_file("res://scenes/level_select_scenes/level_select.tscn","fade_blue")

var current_level
func current_level_finder():
	for i in GameDataManager.level_info:
		if i!=0:
			if GameDataManager.level_info[i]["unlocked"] == true and GameDataManager.level_info[i+1]["unlocked"] != true:
				current_level=i

var new_value
func _on_retry_button_pressed():
	SoundManager.stop_tracked_music()
	current_level_finder()
	SoundManager.play_fixed_sound("button_pressed")
	if GameDataManager.level_info[0]["lives"] is int:
		if GameDataManager.level_info[0]["lives"] !=0:
			new_value=GameDataManager.level_info[0]["lives"]-1
			Transition.change_scene_to_file("res://scenes/level_scenes/"+str(GameDataManager.current_level)+".tscn","fade_blue")
		else:
			get_parent().get_node("UI/lives_store").visible=true
	
	
	
	

extends Node2D

@onready var score_label = $gameover_menu/score_label
var current_score = 0
var level

func _on_grid_update_score(amount_to_change):
	current_score += amount_to_change
	score_label.text = str(current_score)

func _ready():
	SoundManager.play_fixed_sound("lose")
	$AnimationPlayer.play("game_over")

func _on_quit_button_pressed():
	SoundManager.stop_tracked_music()
	SoundManager.play_fixed_sound("button_pressed")
	Transition.change_scene_to_file("res://scenes/level_select_scenes/level_select.tscn","fade_blue")
	print("LOSE_QUIT_PRESSED")

var current_level
func current_level_finder():
	for i in GameDataManager.level_info:
		if i!=0:
			if GameDataManager.level_info[i]["unlocked"] == true and GameDataManager.level_info[i+1]["unlocked"] != true:
				current_level=i

var new_value
func _on_retry_button_pressed():
	print("LOSE_RETRY_PRESSED")
	SoundManager.play_fixed_sound("button_pressed")
	SoundManager.stop_tracked_music()
	if GameDataManager.level_info[0]["lives"] is int:
		if GameDataManager.level_info[0]["lives"] !=0:
			new_value=GameDataManager.level_info[0]["lives"]-1
			Transition.change_scene_to_file("res://scenes/level_scenes/"+str(get_parent().get_node("grid").level)+".tscn","fade_blue")
			print("RETRAYUU")
		else:
			get_parent().get_node("UI/lives_store").visible=true
	
	
	
	

extends Node2D

#star stuff
@onready var silver=preload("res://Assets/artwork/ui/win_state_ui/endgame_stars/silver_endgame_star.png")
@onready var gold=preload("res://Assets/artwork/ui/win_state_ui/endgame_stars/gold_endgame_star.png")
@onready var platinum=preload("res://Assets/artwork/ui/win_state_ui/endgame_stars/platinum_endgame_star.png")
@onready var rainbow=preload("res://Assets/artwork/ui/win_state_ui/endgame_stars/platinum_endgame_star.png")

#particle_stuff
@onready var silver_particle=$explosions/silver_explosion
@onready var gold_particle=$explosions/gold_explosion
@onready var platinum_particle=$explosions/platinum_explosion
@onready var rainbow_particle=$explosions/rainbow_explosion


func _ready():
	silver_particle.position=Vector2(405,945)
	gold_particle.position=Vector2(586,945)
	rainbow_particle.position=Vector2(766,945)

@onready var score_label = $complete_menu/score_label
var current_score = 0
	
func _on_grid_update_score(amount_to_change):
	current_score += amount_to_change
	
func score_draw():
	SoundManager.play_tracked_sound("points_tick")
	for i in range(0,current_score):
			while int($complete_menu/score_label.text)<current_score-100:
				i+=100
				$complete_menu/score_label.text=str(i)
				await get_tree().create_timer(.02).timeout
			while int($complete_menu/score_label.text)>=current_score-100 and int($complete_menu/score_label.text)<=current_score:
				i+=1
				$complete_menu/score_label.text=str(i)
				await get_tree().create_timer(.02).timeout
			
#	await get_tree().create_timer(.3).timeout
	await get_tree().create_timer(.1).timeout
	silver_particle.restart()
	await get_tree().create_timer(.1).timeout
	gold_particle.restart()
	await get_tree().create_timer(.1).timeout
	rainbow_particle.restart()
	SoundManager.stop_tracked_sound()
	SoundManager.play_fixed_sound("fairy_glitter")
#	SoundManager.play_fixed_sound("points_tally")
	
	
func _on_goal_holder_game_won():
	$".".visible=true
	if wait==false:
		wait=true
		var current_level=GameDataManager.level_info[0]["current_level"]
		$AnimationPlayer.play("game_won")
		SoundManager.play_fixed_sound("win")
		#updates current_level_star
		if star_1_unlocked==true:
			GameDataManager.modify_dict(current_level,"star","silver")
			SaveUpdates.current_transition="silver"
		if star_2_unlocked==true:
			GameDataManager.modify_dict(current_level,"star","gold")
			SaveUpdates.current_transition="gold"
		if star_3_unlocked==true:
			GameDataManager.modify_dict(current_level,"star","rainbow")
			SaveUpdates.current_transition="rainbow"
		SaveUpdates.current_index=current_level
		#unlocks next level
		GameDataManager.modify_dict(current_level+1,"unlocked",true)
		GameDataManager.modify_dict(current_level+1,"star","green")
		SaveUpdates.next_index=current_level+1
		$wait_timer.start()
	
func _on_continue_button_pressed():
	SoundManager.stop_tracked_music()
	SoundManager.stop_tracked_sound()
	SoundManager.play_fixed_sound("button_pressed")
	Transition.change_scene_to_file("res://scenes/level_select_scenes/level_select.tscn","fade_blue")
	
var new_value
func _on_retry_button_pressed():
	SoundManager.stop_tracked_music()
	SoundManager.play_fixed_sound("button_pressed")
	if GameDataManager.level_info[0]["lives"] is int:
		if GameDataManager.level_info[0]["lives"] !=0:
			new_value=GameDataManager.level_info[0]["lives"]-1
			Transition.change_scene_to_file("res://scenes/level_scenes/"+str(GameDataManager.level_info[0]["current_level"])+".tscn","fade_blue")
		else:
			get_parent().get_node("UI/lives_store").visible=true
			
var wait=false
func _on_wait_timer_timeout():
	wait=false

var star_1_unlocked
var star_2_unlocked
var star_3_unlocked
func _on_ui_star_1_unlocked():
	star_1_unlocked=true
	
func _on_ui_star_2_unlocked():
	star_2_unlocked=true
	
func _on_ui_star_3_unlocked():
	star_3_unlocked=true
	
func _on_animation_player_animation_finished(anim_name):
	#after game one not on map effects other is in world backdrop
	match anim_name:
		"game_won":
			if star_1_unlocked==true and star_2_unlocked==false:
				$AnimationPlayer.play("silver")
				await get_tree().create_timer(.3).timeout
				SoundManager.play_fixed_sound("1_star")
				silver_particle.emitting=true
			if star_2_unlocked==true and star_3_unlocked==false:
				$AnimationPlayer.play("gold")
				await get_tree().create_timer(.3).timeout
				SoundManager.play_fixed_sound("1_star")
				silver_particle.emitting=true
				await get_tree().create_timer(.3).timeout
				SoundManager.play_fixed_sound("2_star")
				gold_particle.emitting=true
			if star_3_unlocked==true:
				$AnimationPlayer.play("rainbow")
				await get_tree().create_timer(.3).timeout
				SoundManager.play_fixed_sound("1_star")
				silver_particle.emitting=true
				await get_tree().create_timer(.3).timeout
				SoundManager.play_fixed_sound("2_star")
				gold_particle.emitting=true
				await get_tree().create_timer(.3).timeout
				SoundManager.play_fixed_sound("3_star")
				rainbow_particle.emitting=true
			score_draw()



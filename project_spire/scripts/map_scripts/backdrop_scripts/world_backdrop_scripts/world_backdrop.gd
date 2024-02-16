extends Node2D 

#heart_stuff
@onready var full=preload("res://Assets/artwork/ui/main_ui/bottom_ui/heart_regular/heart_full.png")
@onready var full_pressed=preload("res://Assets/artwork/ui/main_ui/bottom_ui/heart_pressed/heart_full_pressed.png")
@onready var semi=preload("res://Assets/artwork/ui/main_ui/bottom_ui/heart_regular/heart_semi.png")
@onready var semi_pressed=preload("res://Assets/artwork/ui/main_ui/bottom_ui/heart_pressed/heart_semi_pressed.png")
@onready var empty=preload("res://Assets/artwork/ui/main_ui/bottom_ui/heart_regular/heart_empty.png")
@onready var empty_pressed=preload("res://Assets/artwork/ui/main_ui/bottom_ui/heart_pressed/heart_empty_pressed.png")

#star_stuff regular
@onready var silver=preload("res://Assets/artwork/animation/unlock/stars_regular/silver_star.png")
@onready var gold=preload("res://Assets/artwork/animation/unlock/stars_regular/gold_star.png")
@onready var green=preload("res://Assets/artwork/animation/unlock/stars_regular/green_star.png")
@onready var platinum=preload("res://Assets/artwork/animation/unlock/stars_regular/platinum_star.png")
@onready var rainbow=preload("res://Assets/artwork/animation/unlock/stars_regular/rainbow_star.png")

#star_stuff pressed
@onready var silver_pressed=preload("res://Assets/artwork/animation/unlock/stars_pressed/silver_star_pressed.png")
@onready var gold_pressed=preload("res://Assets/artwork/animation/unlock/stars_pressed/gold_star_pressed.png")
@onready var green_pressed=preload("res://Assets/artwork/animation/unlock/stars_pressed/green_star_pressed.png")
@onready var platinum_pressed=preload("res://Assets/artwork/animation/unlock/stars_pressed/platinum_star_pressed.png")
@onready var rainbow_pressed=preload("res://Assets/artwork/animation/unlock/stars_pressed/rainbow_star_pressed.png")

var current_world
signal walk

func _ready():
	currency_editor()
	$map_store/current_lives.text=str(GameDataManager.level_info[0]["lives"])
	$map_store/current_shards.text=str(GameDataManager.level_info[0]["shards"])
	current_world=GameDataManager.current_world
	$confirmation.visible=false
	lives()
	if GameDataManager.level_info[2]["unlocked"]!=true:
		introduction()
		await get_tree().create_timer(5).timeout
	button_texture_setter()
	button_texture_updater_and_walk()

var currency_labels=["map_store/buy_button_10_shards/currency","map_store/buy_button_50_shards/currency","map_store/buy_button_100_shards/currency","map_store/buy_button_250_shards/currency","map_store/buy_button_500_shards/currency","map_store/buy_button_1000_shards/currency"]

func currency_editor():
	match GameDataManager.level_info[0]["currency"]:
		"USD":
			for i in currency_labels:
				get_node(i).text="$"

#if i is in saveupdates pass else execute 
func button_texture_setter():
		for i in range(1,20):
			var current_star=get_node("levels/"+str(i))
			if i!=SaveUpdates.current_index and i!=SaveUpdates.next_index:
				match GameDataManager.level_info[i]["star"]:
					"silver":
						current_star.texture_normal=silver
						current_star.texture_pressed=silver_pressed
					"gold":
						current_star.texture_normal=gold
						current_star.texture_pressed=gold_pressed
					"green":
						current_star.texture_normal=green
						current_star.texture_pressed=green_pressed
					"rainbow":
						current_star.texture_normal=rainbow
						current_star.texture_pressed=rainbow_pressed
					"null":
						current_star.texture_normal=null

func button_texture_updater_and_walk():
	#current_level
	if SaveUpdates.current_index!=null:
		var current_button=get_node("levels/"+str(SaveUpdates.current_index))
		var next_button=get_node("levels/"+str(SaveUpdates.next_index))
		var silver_particle=$explosions/silver_explosion
		var gold_particle=$explosions/gold_explosion
		var platinum_particle=$explosions/platinum_explosion
		var green_particle=$explosions/green_explosion
		var rainbow_particle=$explosions/rainbow_explosion
		silver_particle.position=current_button.position+Vector2(502,+54)
		gold_particle.position=current_button.position+Vector2(+502,+54)
		platinum_particle.position=current_button.position+Vector2(+502,+54)
		rainbow_particle.position=current_button.position+Vector2(+502,+54)
		green_particle.position=next_button.position+Vector2(+502,+54)
		var level=GameDataManager.level_info[0]["current_level"]
		
		$portal_particles.position=current_button.position
		print(current_button.position)
		$portal_particles.emitting=true
		SoundManager.play_fixed_sound("portal")
		$AnimationPlayer.play_backwards("character_fade")
		
		emit_signal("walk")
		GameDataManager.modify_dict(0,"current_level",level+1)
		
		if SaveUpdates.current_transition=="silver":
			await get_tree().create_timer(1.5).timeout
			SoundManager.play_fixed_sound("1_star")
			silver_particle.emitting=true
			current_button.texture_normal=silver
			current_button.texture_pressed=silver_pressed
			
		if SaveUpdates.current_transition=="gold":
			await get_tree().create_timer(.75).timeout
			SoundManager.play_fixed_sound("1_star")
			silver_particle.emitting=true
			current_button.texture_normal=silver
			await get_tree().create_timer(.75).timeout
			SoundManager.play_fixed_sound("2_star")
			gold_particle.emitting=true
			current_button.texture_normal=gold
			current_button.texture_pressed=gold_pressed
			
		if SaveUpdates.current_transition=="rainbow":
			await get_tree().create_timer(0.5).timeout
			SoundManager.play_fixed_sound("1_star")
			silver_particle.emitting=true
			current_button.texture_normal=silver
			await get_tree().create_timer(0.5).timeout
			SoundManager.play_fixed_sound("2_star")
			gold_particle.emitting=true
			current_button.texture_normal=gold
			await get_tree().create_timer(0.5).timeout
			SoundManager.play_fixed_sound("3_star")
			rainbow_particle.emitting=true
			current_button.texture_normal=rainbow
			current_button.texture_pressed=rainbow_pressed
		
		#set to null
		SaveUpdates.current_index=null
		await get_tree().create_timer(0.5).timeout
		SoundManager.play_fixed_sound("next_level_unlocked")
		
	#next level
	if SaveUpdates.next_index!=null:
		var current_button=get_node("levels/"+str(SaveUpdates.next_index))
		var current_particle=$explosions/green_explosion
		current_particle.position=current_button.position+Vector2(+502,+54)
		current_particle.emitting=true
		current_button.texture_normal=green
		current_button.texture_pressed=green_pressed
		#set to null
		SaveUpdates.next_index=null
	
func introduction():
	if GameDataManager.level_info[2]["unlocked"]!=true:
		$introduction.visible=true
		$AnimationPlayer.play("introduction")

func lives():
	$bottom_ui/lives_store_button/lives_label.text=str(GameDataManager.level_info[0]["lives"])
	if GameDataManager.level_info[0]["lives"]=="∞" or GameDataManager.level_info[0]["lives"] is String:
		$bottom_ui/lives_store_button.texture_normal=full
		$bottom_ui/lives_store_button.texture_pressed=full_pressed
	else:
		if GameDataManager.level_info[0]["lives"]==5:
			$bottom_ui/lives_store_button.texture_normal=full
			$bottom_ui/lives_store_button.texture_pressed=full_pressed
		if GameDataManager.level_info[0]["lives"]==0:
			$bottom_ui/lives_store_button.texture_normal=empty
			$bottom_ui/lives_store_button.texture_pressed=empty_pressed
		else:
			$bottom_ui/lives_store_button.texture_normal=semi
			$bottom_ui/lives_store_button.texture_pressed=semi_pressed
		
func button_press(level):
	SoundManager.play_fixed_sound("button_pressed")
	if GameDataManager.level_info[0]["lives"] is int:
		if GameDataManager.level_info[0]["lives"]!=0:
			wait=true
			var current_button=get_node("levels/"+str(SaveUpdates.current_index))
			$portal_particles.position=current_button.position
			$portal_particles.emitting=true
			$AnimationPlayer.play("character_fade")
			SoundManager.play_fixed_sound("portal")
			await get_tree().create_timer(1).timeout
			if GameDataManager.level_info[0]["current_level"]!=level:
				GameDataManager.modify_dict("level_info",0,level)
			Transition.change_scene_to_file("res://scenes/level_scenes/"+str(level)+".tscn","fade_purple")
			print("loading_level"+str(level))
			$wait_resetter.start()
		else:
			$lives_store.visible=true
			return
	else:
		wait=true
		var current_button=get_node("levels/"+str(SaveUpdates.current_index))
		$portal_particles.position=current_button.position
		$portal_particles.emitting=true
		$AnimationPlayer.play("character_fade")
		SoundManager.play_fixed_sound("portal")
		await get_tree().create_timer(1).timeout
		if GameDataManager.level_info[0]["current_level"]!=level:
			GameDataManager.modify_dict("level_info",0,level)
		Transition.change_scene_to_file("res://scenes/level_scenes/"+str(level)+".tscn","fade_purple")
		print("loading_level"+str(level))
		$wait_resetter.start()
			
func _on_1_pressed():
	if $"levels/levels/1".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(1)
		
func _on_2_pressed():
	if $"levels/2".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(2)
	
func _on_3_pressed():
	if $"levels/3".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(3)
	
func _on_4_pressed():
	if $"levels/4".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(4)
	
func _on_5_pressed():
	if $"levels/5".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(5)
	
func _on_6_pressed():
	if $"levels/6".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(6)
	
func _on_7_pressed():
	if $"levels/7".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(7)
	
func _on_8_pressed():
	if $"levels/8".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(8)
	
func _on_9_pressed():
	if $"levels/9".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(9)
	
func _on_10_pressed():
	if $"levels/10".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(10)
	
func _on_11_pressed():
	if $"levels/11".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(11)
	
func _on_12_pressed():
	if $"levels/12".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(12)
	
func _on_13_pressed():
	if $"levels/13".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(13)
	
func _on_14_pressed():
	if $"levels/14".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(14)
	
func _on_15_pressed():
	if $"levels/15".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(15)
	
func _on_16_pressed():
	if $"levels/16".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(16)
	
func _on_17_pressed():
	if $"levels/17".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(17)
	
func _on_18_pressed():
	if $"levels/18".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(18)
	
func _on_19_pressed():
	if $"levels/19".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(19)
	
func _on_20_pressed():
	if $"levels/20".enabled==true and wait==false:
		SoundManager.play_fixed_sound("button_pressed")
		if $confirmation.visible==false:
			$confirmation.visible=true
		else:
			button_press(20)
	
func _on_settings_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $settings.visible==false:
		$settings.visible=true
	else:
		$settings.visible=false
	
var wait=false
func _on_wait_resetter_timeout():
	wait=false
	
func _on_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $leave.visible==true:
		$leave.visible=false
	else:
		$leave.visible=true


func _on_pause_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $bottom_ui.visible==true:
		$bottom_ui.visible=false
	else:
		$bottom_ui.visible=true


func _on_cancel_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $leave.visible==true:
		$leave.visible=false
	else:
		$leave.visible=true


func _on_leave_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	Transition.change_scene_to_file("res://scenes/main_menu.tscn","fade_purple")


func _on_exit_button_2_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $settings.visible==true:
		$settings.visible=false
	else:
		$settings.visible=true


func _on_confirm_cancel_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$confirmation.visible=false

var purchase_confirmed=true	 #placeholder for ipa
var new_shard_value
func _on_buy_button_10_shards_pressed():
	if purchase_confirmed==true:
		SoundManager.play_fixed_sound("purchase")
		new_shard_value=GameDataManager.level_info[0]["shards"]+10
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		purchase_celebration(10)
		await celebration_done
		$map_store.visible=false

func _on_buy_button_50_shards_pressed():
	if purchase_confirmed==true:
		SoundManager.play_fixed_sound("purchase")
		new_shard_value=GameDataManager.level_info[0]["shards"]+50
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		purchase_celebration(50)
		await celebration_done
		$map_store.visible=false

func _on_buy_button_100_shards_pressed():
	if purchase_confirmed==true:
		SoundManager.play_fixed_sound("purchase")
		new_shard_value=GameDataManager.level_info[0]["shards"]+100
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		purchase_celebration(100)
		await celebration_done
		$map_store.visible=false

func _on_buy_button_250_shards_pressed():
	if purchase_confirmed==true:
		SoundManager.play_fixed_sound("purchase")
		new_shard_value=GameDataManager.level_info[0]["shards"]+250
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		purchase_celebration(250)
		await celebration_done
		$map_store.visible=false

func _on_buy_button_500_shards_pressed():
	if purchase_confirmed==true:
		SoundManager.play_fixed_sound("purchase")
		new_shard_value=GameDataManager.level_info[0]["shards"]+500
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		purchase_celebration(500)
		await celebration_done
		$map_store.visible=false

func _on_buy_button_1000_shards_pressed():
	if purchase_confirmed==true:
		SoundManager.play_fixed_sound("purchase")
		new_shard_value=GameDataManager.level_info[0]["shards"]+1000
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		purchase_celebration(1000)
		await celebration_done
		$map_store.visible=false
		
func _on_lives_store_exit_button_pressed():
	$lives_store.visible=false

func _on_lives_store_6h_buy_button_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($lives_store/lives_store_6h_buy_button/lives_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($lives_store/lives_store_6h_buy_button/lives_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"lives","∞")
		bought_booster_fx()
		$lives_store.visible=false
		$bottom_ui/lives_store_button/lives_label.text=GameDataManager.level_info[0]["lives"]
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		$lives_store.visible=false
		await get_tree().create_timer(.2).timeout
		$map_store.visible=true
		map_store_wiggle()
	
func _on_exit_map_store_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$map_store.visible=false
	
signal celebration_done
func purchase_celebration(increase_value):
	new_shard_value=increase_value+int($map_store/current_shards.text)
	$confetti_sprites.visible=true
	$confetti_sprites.play("confetti")
	SoundManager.play_tracked_sound("points_tick")
	for i in range(0,new_shard_value):
			while int($map_store/current_shards.text)<new_shard_value-100:
				i+=100
				$map_store/current_shards.text=str(i)
				await get_tree().create_timer(.02).timeout
			while int($map_store/current_shards.text)>=new_shard_value-100 and int($map_store/current_shards.text)<=new_shard_value:
				i+=1
				$map_store/current_shards.text=str(i)
				await get_tree().create_timer(.02).timeout
	SoundManager.stop_tracked_sound()
	SoundManager.play_fixed_sound("points_tally")
	emit_signal("celebration_done")

func bought_booster_fx():
	$confetti_sprites.visible=true
	$confetti_sprites.play("confetti")
	SoundManager.play_fixed_sound("points_tally")
	await get_tree().create_timer(.5).timeout
	
func lives_store_wiggle():
	for i in 30:
		if $lives_store.visible==true:
			var tween1=get_tree().create_tween()
			tween1.set_trans(Tween.TRANS_BOUNCE)
			tween1.tween_property(
				$lives_store/lives_store_6h_buy_button,"scale",Vector2(1.05,.9),0.25)
			tween1.tween_property(
				$lives_store/lives_store_6h_buy_button,"scale",Vector2(1,1),0.25)
			await get_tree().create_timer(1).timeout
		else:
			return
	
func map_store_wiggle():
	for i in 30:
		if $map_store.visible==true:
			var tween1=get_tree().create_tween()
			var tween2=get_tree().create_tween()
			var tween3=get_tree().create_tween()
			var tween4=get_tree().create_tween()
			var tween5=get_tree().create_tween()
			var tween6=get_tree().create_tween()
			tween1.set_trans(Tween.TRANS_BOUNCE)
			tween2.set_trans(Tween.TRANS_BOUNCE)
			tween3.set_trans(Tween.TRANS_BOUNCE)
			tween4.set_trans(Tween.TRANS_BOUNCE)
			tween5.set_trans(Tween.TRANS_BOUNCE)
			tween6.set_trans(Tween.TRANS_BOUNCE)
	
			tween1.tween_property(
				$"map_store/buy_button_10_shards","scale",Vector2(1.05,.9),0.25)
			tween1.tween_property(
				$"map_store/buy_button_10_shards","scale",Vector2(1,1),0.25)
			
			tween2.tween_property(
				$"map_store/buy_button_50_shards","scale",Vector2(1.05,.9),0.25)
			tween2.tween_property(
				$"map_store/buy_button_50_shards","scale",Vector2(1,1),0.25)
			
			tween3.tween_property(
				$"map_store/buy_button_100_shards","scale",Vector2(1.05,.9),0.25)
			tween3.tween_property(
				$"map_store/buy_button_100_shards","scale",Vector2(1,1),0.25)
				
			tween4.tween_property(
				$"map_store/buy_button_250_shards","scale",Vector2(1.05,.9),0.25)
			tween4.tween_property(
				$"map_store/buy_button_250_shards","scale",Vector2(1,1),0.25)
				
			tween5.tween_property(
				$"map_store/buy_button_500_shards","scale",Vector2(1.05,.9),0.25)
			tween5.tween_property(
				$"map_store/buy_button_500_shards","scale",Vector2(1,1),0.25)
				
			tween6.tween_property(
				$"map_store/buy_button_1000_shards","scale",Vector2(1.05,.9),0.25)
			tween6.tween_property(
				$"map_store/buy_button_1000_shards","scale",Vector2(1,1),0.25)
				
			await get_tree().create_timer(1).timeout
		else:
			return


func _on_shard_store_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $map_store.visible==true:
		$map_store.visible=false
	else:
		$map_store.visible=true
		map_store_wiggle()


func _on_lives_store_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if $lives_store.visible==true:
		$lives_store.visible=false
	else:
		$lives_store.visible=true
	lives_store_wiggle()

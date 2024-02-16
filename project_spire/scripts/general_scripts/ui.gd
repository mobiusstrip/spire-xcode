extends TextureRect
#referencing a node
var game_lose=preload("res://scenes/ui_scenes/game_lose.tscn")
var game_won=preload("res://scenes/ui_scenes/game_won.tscn")
var in_level_settings=preload("res://scenes/ui_scenes/in_level_settings.tscn")
var quit_confirm=preload("res://scenes/ui_scenes/quit_confirm.tscn")
var star=load("res://Assets/artwork/ui/main_ui/star.png")
@onready var score_label = $top_ui/score_label
@onready var counter_label = $top_ui/counter_label
@onready var score_bar = $top_ui/score_bar
@onready var goal_container = $top_ui/goal_container
@export var goal_prefab: PackedScene
var current_score = 0
var current_count = 0

func _ready():
	var level=get_parent().get_node("grid").level
	$map_store/current_lives.text=str(GameDataManager.level_info[0]["lives"])
	_on_grid_update_score(current_score)
	update_lives()
	update_booster_screen_labels()
	$top_ui/level_label.text=str(get_parent().get_node("grid").level)

func update_booster_screen_labels():
	#also update current_shards
	$map_store/current_shards.text=str(GameDataManager.level_info[0]["shards"])
	$booster_screens/blue_booster_screen/blue_booster_screen_inv.text=str(GameDataManager.level_info[0]["blue_booster_stock"])
	$booster_screens/green_booster_screen/green_booster_screen_inv.text=str(GameDataManager.level_info[0]["green_booster_stock"])
	$booster_screens/yellow_booster_screen/yellow_booster_screen_inv.text=str(GameDataManager.level_info[0]["yellow_booster_stock"])
	$booster_screens/red_booster_screen/red_booster_screen_inv.text=str(GameDataManager.level_info[0]["red_booster_stock"])
	$booster_screens/pink_booster_screen/pink_booster_screen_inv.text=str(GameDataManager.level_info[0]["pink_booster_stock"])
	$bottom_ui/blue_booster/blue_booster_label.text=str(GameDataManager.level_info[0]["blue_booster_stock"])
	$bottom_ui/green_booster/green_booster_label.text=str(GameDataManager.level_info[0]["green_booster_stock"])
	$bottom_ui/yellow_booster/yellow_booster_label.text=str(GameDataManager.level_info[0]["yellow_booster_stock"])
	$bottom_ui/red_booster/red_booster_label.text=str(GameDataManager.level_info[0]["red_booster_stock"])
	$bottom_ui/pink_booster/pink_booster_label.text=str(GameDataManager.level_info[0]["pink_booster_stock"])
	
func _on_grid_update_score(amount_to_change):
	current_score += amount_to_change
	update_score_bar()
	score_label.text = str(current_score)
	update_stars()

func _on_grid_update_counter(amount_to_change):
	current_count += amount_to_change
	$top_ui/counter_label.text = str(current_count)

func make_goal(new_max,new_texture,new_value):
	var current=goal_prefab.instantiate()
	goal_container.add_child(current)
	current.set_goal_values(new_max,new_texture,new_value)

func update_score_bar():
	score_bar.value=current_score

func update_lives():
	$top_ui/lives_label.text=str(GameDataManager.level_info[0]["lives"])

func _on_goal_holder_create_goal(new_max,new_texture,new_value):
	make_goal(new_max,new_texture,new_value)


func _on_grid_check_goal(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)
		
func _on_blue_booster_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	if tweenx==null:
		booster_wiggle("blue")
	if GameDataManager.level_info[0]["colrow_bomb_booster_unlocked"]==false:
		$bottom_ui/blue_booster/blue_booster_unlock_label.visible=true
		await get_tree().create_timer(2).timeout
		$bottom_ui/blue_booster/blue_booster_unlock_label.visible=false
	else:
		if GameDataManager.level_info[0]["blue_booster_stock"]>0:
			$booster_screens/blue_booster_screen.visible = !$booster_screens/blue_booster_screen.visible
			$booster_screens/blue_booster_screen/blue_booster_use_button.disabled=false
		else:
			$booster_screens/blue_booster_screen/blue_booster_use_button.disabled=true
			$booster_stores/blue_booster_store.visible=true

func _on_green_booster_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	booster_wiggle("green")
	if GameDataManager.level_info[0]["adj_bomb_booster_unlocked"]==false:
		$bottom_ui/green_booster/green_booster_unlock_label.visible=true
		await get_tree().create_timer(2).timeout
		$bottom_ui/green_booster/green_booster_unlock_label.visible=false
	else:
		if GameDataManager.level_info[0]["green_booster_stock"]>0:
			$booster_screens/green_booster_screen.visible = !$booster_screens/green_booster_screen.visible
			$booster_screens/green_booster_screen/green_booster_use_button.disabled=false
		else:
			$booster_screens/green_booster_screen/green_booster_use_button.disabled=true
			$booster_stores/green_booster_store.visible=true

func _on_yellow_booster_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	booster_wiggle("yellow")
	if GameDataManager.level_info[0]["hammer_booster_unlocked"]==false:
		$bottom_ui/yellow_booster/yellow_booster_unlock_label.visible=true
		await get_tree().create_timer(2).timeout
		$bottom_ui/yellow_booster/yellow_booster_unlock_label.visible=false
	else:
		if GameDataManager.level_info[0]["yellow_booster_stock"]>0:
			$booster_screens/yellow_booster_screen.visible = !$booster_screens/yellow_booster_screen.visible
			$booster_screens/yellow_booster_screen/yellow_booster_use_button.disabled=false
		else:
			$booster_screens/yellow_booster_screen/yellow_booster_use_button.disabled=true
			$booster_stores/yellow_booster_store.visible=true

func _on_red_booster_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	booster_wiggle("red")
	if GameDataManager.level_info[0]["free_switch_booster_unlocked"]==false:
		$bottom_ui/red_booster/red_booster_unlock_label.visible=true
		await get_tree().create_timer(2).timeout
		$bottom_ui/red_booster/red_booster_unlock_label.visible=false
	else:
		if GameDataManager.level_info[0]["red_booster_stock"]>0:
			$booster_screens/red_booster_screen.visible = !$booster_screens/red_booster_screen.visible
			$booster_screens/red_booster_screen/red_booster_use_button.disabled=false
		else:
			$booster_screens/red_booster_screen/red_booster_use_button.disabled=true
			$booster_stores/red_booster_store.visible=true

func _on_pink_booster_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	booster_wiggle("pink")
	if GameDataManager.level_info[0]["colrow_bomb_booster_unlocked"]==false:
		$bottom_ui/pink_booster/pink_booster_unlock_label.visible=true
		await get_tree().create_timer(2).timeout
		$bottom_ui/pink_booster/pink_booster_unlock_label.visible=false
	else:
		if GameDataManager.level_info[0]["pink_booster_stock"]>0:
			$booster_screens/pink_booster_screen.visible = !$booster_screens/pink_booster_screen.visible
			$booster_screens/pink_booster_screen/pink_booster_use_button.disabled=false
		else:
			$booster_screens/pink_booster_screen/pink_booster_use_button.disabled=true
			$booster_stores/pink_booster_store.visible=true

#temporary booster count modifier later will be for store -modify done ok ok 

func _on_booster_tween_timeout():
	if tweenx==null:
		booster_wiggle("all")

func _on_grid_break_lock(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)

func _on_grid_break_marmalade(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)

func _on_grid_break_ice(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)

func _on_grid_break_concrete(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)

func _on_grid_break_slime(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_values(goal_type)

@onready var max_score_star=get_parent().get_node("score_goal").max_score_star
signal star_1_unlocked
signal star_2_unlocked
signal star_3_unlocked

func update_stars():
	if current_score!=0 and max_score_star!=0:
		if current_score>=max_score_star:
			$star_3.texture=star
			emit_signal("star_3_unlocked")
		if current_score>=max_score_star*.5:
			$star_2.texture=star
			emit_signal("star_2_unlocked")
			$top_ui/score_label.label_settings.set_font_color(Color(1,1,1,1))
		if current_score>=max_score_star*0.3:
			$star_1.texture=star
			emit_signal("star_1_unlocked")

func _on_score_goal_setup_score_needed(score_needed):
	$top_ui/score_bar.max_value=score_needed
	max_score_star=score_needed

func _on_booster_store_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$booster_stores/blue_booster_store.visible=false
	$booster_stores/green_booster_store.visible=false
	$booster_stores/yellow_booster_store.visible=false
	$booster_stores/red_booster_store.visible=false
	$booster_stores/pink_booster_store.visible=false
	
func map_store_wiggle():
	var tween1=get_tree().create_tween()
	var tween2=get_tree().create_tween()
	var tween3=get_tree().create_tween()
	var tween4=get_tree().create_tween()
	var tween5=get_tree().create_tween()
	var tween6=get_tree().create_tween()
	var tween7=get_tree().create_tween()
	tween1.set_trans(Tween.TRANS_BOUNCE)
	tween2.set_trans(Tween.TRANS_BOUNCE)
	tween3.set_trans(Tween.TRANS_BOUNCE)
	tween4.set_trans(Tween.TRANS_BOUNCE)
	tween5.set_trans(Tween.TRANS_BOUNCE)
	tween6.set_trans(Tween.TRANS_BOUNCE)
	tween7.set_trans(Tween.TRANS_BOUNCE)
	for i in 30:
		if $map_store.visible==true:
			tween2.tween_property(
				$"map_store/buy_button_10_shards","scale",Vector2(1.05,.95),0.25)
			tween2.tween_property(
				$"map_store/buy_button_10_shards","scale",Vector2(1,1),0.25)
			
			tween3.tween_property(
				$"map_store/buy_button_50_shards","scale",Vector2(1.05,.95),0.25)
			tween3.tween_property(
				$"map_store/buy_button_50_shards","scale",Vector2(1,1),0.25)
			
			tween4.tween_property(
				$"map_store/buy_button_100_shards","scale",Vector2(1.05,.95),0.25)
			tween4.tween_property(
				$"map_store/buy_button_100_shards","scale",Vector2(1,1),0.25)
				
			tween5.tween_property(
				$"map_store/buy_button_250_shards","scale",Vector2(1.05,.95),0.25)
			tween5.tween_property(
				$"map_store/buy_button_250_shards","scale",Vector2(1,1),0.25)
				
			tween6.tween_property(
				$"map_store/buy_button_500_shards","scale",Vector2(1.05,.95),0.25)
			tween6.tween_property(
				$"map_store/buy_button_500_shards","scale",Vector2(1,1),0.25)
				
			tween7.tween_property(
				$"map_store/buy_button_1000_shards","scale",Vector2(1.05,.95),0.25)
			tween7.tween_property(
				$"map_store/buy_button_1000_shards","scale",Vector2(1,1),0.25)
		else:
			return
	
var tweenx=null
func booster_wiggle(booster_color):
	if booster_color=="all" and tweenx==null:
		tweenx=1
		var tween1=get_tree().create_tween()
		var tween2=get_tree().create_tween()
		var tween3=get_tree().create_tween()
		var tween4=get_tree().create_tween()
		var tween5=get_tree().create_tween()
		tween1.set_trans(Tween.TRANS_BOUNCE)
		tween2.set_trans(Tween.TRANS_BOUNCE)
		tween3.set_trans(Tween.TRANS_BOUNCE)
		tween4.set_trans(Tween.TRANS_BOUNCE)
		tween5.set_trans(Tween.TRANS_BOUNCE)
		tween1.tween_property(
		$bottom_ui/blue_booster,"position",Vector2.UP*10,1).as_relative()
		tween1.tween_property(
		$bottom_ui/blue_booster, "position",Vector2.DOWN*10,1).as_relative()
		
		tween2.tween_property(
		$bottom_ui/green_booster,"position",Vector2.UP*10,1).as_relative()
		tween2.tween_property(
		$bottom_ui/green_booster, "position",Vector2.DOWN*10,1).as_relative()
		
		tween3.tween_property(
		$bottom_ui/yellow_booster,"position",Vector2.UP*10,1).as_relative()
		tween3.tween_property(
		$bottom_ui/yellow_booster, "position",Vector2.DOWN*10,1).as_relative()
		
		tween4.tween_property(
		$bottom_ui/red_booster,"position",Vector2.UP*10,1).as_relative()
		tween4.tween_property(
		$bottom_ui/red_booster, "position",Vector2.DOWN*10,1).as_relative()
		
		tween5.tween_property(
		$bottom_ui/pink_booster,"position",Vector2.UP*10,1).as_relative()
		tween5.tween_property(
		$bottom_ui/pink_booster, "position",Vector2.DOWN*10,1).as_relative()
	else:
		if tweenx==null:
			tweenx=1
			tweenx=get_tree().create_tween()
			tweenx.set_trans(Tween.TRANS_BACK)
			tweenx.set_ease(Tween.EASE_OUT)
			tweenx.tween_property(
			get_node("bottom_ui/"+str(booster_color)+"_booster"),"position",Vector2.UP*10,1).as_relative()
			tweenx.tween_property(
			get_node("bottom_ui/"+str(booster_color)+"_booster"), "position",Vector2.DOWN*10,1).as_relative()
			await get_tree().create_timer(2).timeout
			tweenx=null
		
		
func _on_pink_booster_screen_exit_button_pressed():
	$booster_screens/pink_booster_screen.visible = !$booster_screens/pink_booster_screen.visible


func _on_red_booster_screen_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$booster_screens/red_booster_screen.visible = !$booster_screens/red_booster_screen.visible


func _on_yellow_booster_screen_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$booster_screens/yellow_booster_screen.visible = !$booster_screens/yellow_booster_screen.visible


func _on_green_booster_screen_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$booster_screens/green_booster_screen.visible = !$booster_screens/green_booster_screen.visible


func _on_blue_booster_screen_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$booster_screens/blue_booster_screen.visible = !$booster_screens/blue_booster_screen.visible


func _on_blue_booster_use_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	GameDataManager.modify_dict(0,"blue_booster_stock",GameDataManager.level_info[0]["blue_booster_stock"]-1)
	$bottom_ui/blue_booster/blue_booster_label.text=str(GameDataManager.level_info[0]["blue_booster_stock"])
	$booster_screens/blue_booster_screen/blue_booster_screen_inv.text=str(GameDataManager.level_info[0]["blue_booster_stock"])
	$booster_screens/blue_booster_screen.visible = !$booster_screens/blue_booster_screen.visible

func _on_green_booster_use_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	GameDataManager.modify_dict(0,"green_booster_stock",GameDataManager.level_info[0]["green_booster_stock"]-1)
	$bottom_ui/green_booster/green_booster_label.text=str(GameDataManager.level_info[0]["green_booster_stock"])
	$booster_screens/green_booster_screen/green_booster_screen_inv.text=str(GameDataManager.level_info[0]["green_booster_stock"])
	$booster_screens/green_booster_screen.visible = !$booster_screens/green_booster_screen.visible

func _on_yellow_booster_use_button_pressed():
	SoundManager.play_fixed_sound("booster_spawn_4")
	$bottom_ui/rainbow_explosion.position=Vector2(400,-2170)
	$bottom_ui/rainbow_explosion.emitting=true
	GameDataManager.modify_dict(0,"yellow_booster_stock",GameDataManager.level_info[0]["yellow_booster_stock"]-1)
	$bottom_ui/yellow_booster/yellow_booster_label.text=str(GameDataManager.level_info[0]["yellow_booster_stock"])
	$booster_screens/yellow_booster_screen/yellow_booster_screen_inv.text=str(GameDataManager.level_info[0]["yellow_booster_stock"])
	$booster_screens/yellow_booster_screen.visible = !$booster_screens/yellow_booster_screen.visible

func _on_red_booster_use_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	GameDataManager.modify_dict(0,"red_booster_stock",GameDataManager.level_info[0]["red_booster_stock"]-1)
	$bottom_ui/red_booster/red_booster_label.text=str(GameDataManager.level_info[0]["red_booster_stock"])
	$booster_screens/red_booster_screen/red_booster_screen_inv.text=str(GameDataManager.level_info[0]["red_booster_stock"])
	$booster_screens/red_booster_screen.visible = !$booster_screens/red_booster_screen.visible

func _on_pink_booster_use_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	GameDataManager.modify_dict(0,"pink_booster_stock",GameDataManager.level_info[0]["pink_booster_stock"]-1)
	$bottom_ui/pink_booster/pink_booster_label.text=str(GameDataManager.level_info[0]["pink_booster_stock"])
	$booster_screens/pink_booster_screen/pink_booster_screen_inv.text=str(GameDataManager.level_info[0]["pink_booster_stock"])
	$booster_screens/pink_booster_screen.visible = !$booster_screens/pink_booster_screen.visible
	
func _on_exit_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$settings.visible=false

func _on_setting_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	var current = in_level_settings.instantiate()
	add_child(current)
	
#booster_store_buttons
func _on_blue_booster_buy_button_3x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/blue_booster_store/blue_booster_buy_button_3x/blue_booster_3x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/blue_booster_store/blue_booster_buy_button_3x/blue_booster_3x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"blue_booster_stock",+3)
		bought_booster_fx()
		$booster_stores/blue_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/blue_booster_screen.visible=true
		$booster_screens/blue_booster_screen/blue_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()
	
func _on_blue_booster_buy_button_10x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/blue_booster_store/blue_booster_buy_button_10x/blue_booster_10x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/blue_booster_store/blue_booster_buy_button_10x/blue_booster_10x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"blue_booster_stock",+10)
		bought_booster_fx()
		$booster_stores/blue_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/blue_booster_screen.visible=true
		$booster_screens/blue_booster_screen/blue_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()

func _on_blue_booster_buy_button_20x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/blue_booster_store/blue_booster_buy_button_20x/blue_booster_20x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/blue_booster_store/blue_booster_buy_button_20x/blue_booster_20x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"blue_booster_stock",+20)
		bought_booster_fx()
		$booster_stores/blue_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/blue_booster_screen.visible=true
		$booster_screens/blue_booster_screen/blue_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()

func _on_green_booster_store_buy_button_3x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/green_booster_store/green_booster_buy_button_3x/green_booster_3x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/green_booster_store/green_booster_buy_button_3x/green_booster_3x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"green_booster_stock",+3)
		bought_booster_fx()
		$booster_stores/green_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/green_booster_screen.visible=true
		$booster_screens/green_booster_screen/green_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()

func _on_green_booster_store_buy_button_10x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/green_booster_store/green_booster_buy_button_10x/green_booster_10x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/green_booster_store/green_booster_buy_button_10x/green_booster_10x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"green_booster_stock",+10)
		bought_booster_fx()
		$booster_stores/green_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/green_booster_screen.visible=true
		$booster_screens/green_booster_screen/green_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()

func _on_green_booster_store_buy_button_20x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/green_booster_store/green_booster_buy_button_20x/green_booster_20x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/green_booster_store/green_booster_buy_button_20x/green_booster_20x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"green_booster_stock",+20)
		bought_booster_fx()
		$booster_stores/green_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/green_booster_screen.visible=true
		$booster_screens/green_booster_screen/green_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()

func _on_yellow_booster_store_buy_button_3x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/yellow_booster_store/yellow_booster_buy_button_3x/yellow_booster_3x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/yellow_booster_store/yellow_booster_buy_button_3x/blue_booster_3x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"yellow_booster_stock",+3)
		bought_booster_fx()
		$booster_stores/yellow_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/yellow_booster_screen.visible=true
		$booster_screens/yellow_booster_screen/yellow_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()

func _on_yellow_booster_store_buy_button_10x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/yellow_booster_store/yellow_booster_buy_button_10x/yellow_booster_10x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/yellow_booster_store/yellow_booster_buy_button_10x/yellow_booster_10x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"yellow_booster_stock",+10)
		bought_booster_fx()
		$booster_stores/yellow_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/yellow_booster_screen.visible=true
		$booster_screens/yellow_booster_screen/yellow_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()

func _on_yellow_booster_store_buy_button_20x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/yellow_booster_store/yellow_booster_buy_button_20x/yellow_booster_20x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/yellow_booster_store/yellow_booster_buy_button_20x/yellow_booster_20x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"yellow_booster_stock",+20)
		bought_booster_fx()
		$booster_stores/yellow_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/yellow_booster_screen.visible=true
		$booster_screens/yellow_booster_screen/yellow_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()
	
	
func _on_red_booster_store_buy_button_3x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/red_booster_store/red_booster_buy_button_3x/red_booster_3x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/red_booster_store/red_booster_buy_button_3x/red_booster_3x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"red_booster_stock",+3)
		bought_booster_fx()
		$booster_stores/red_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/red_booster_screen.visible=true
		$booster_screens/red_booster_screen/red_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()
	
func _on_red_booster_store_buy_button_10x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/red_booster_store/red_booster_buy_button_10x/red_booster_10x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/red_booster_store/red_booster_buy_button_10x/red_booster_10x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"red_booster_stock",+10)
		bought_booster_fx()
		$booster_stores/red_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/red_booster_screen.visible=true
		$booster_screens/red_booster_screen/red_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()


func _on_red_booster_store_buy_button_20x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/red_booster_store/red_booster_buy_button_20x/red_booster_20x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/red_booster_store/red_booster_buy_button_20x/red_booster_20x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"red_booster_stock",+20)
		bought_booster_fx()
		$booster_stores/red_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/red_booster_screen.visible=true
		$booster_screens/red_booster_screen/red_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()


func _on_pink_booster_store_buy_button_3x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/pink_booster_store/pink_booster_buy_button_3x/pink_booster_3x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/pink_booster_store/pink_booster_buy_button_3x/pink_booster_3x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"pink_booster_stock",+3)
		bought_booster_fx()
		$booster_stores/pink_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/pink_booster_screen.visible=true
		$booster_screens/pink_booster_screen/pink_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()


func _on_pink_booster_store_buy_button_10x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/pink_booster_store/pink_booster_buy_button_10x/pink_booster_10x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/pink_booster_store/pink_booster_buy_button_10x/pink_booster_10x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"pink_booster_stock",+10)
		bought_booster_fx()
		$booster_stores/pink_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/pink_booster_screen.visible=true
		$booster_screens/pink_booster_screen/pink_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()


func _on_pink_booster_store_buy_button_20x_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($booster_stores/pink_booster_store/pink_booster_buy_button_20x/pink_booster_20x_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($booster_stores/pink_booster_store/pink_booster_buy_button_20x/pink_booster_20x_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"pink_booster_stock",+20)
		bought_booster_fx()
		$booster_stores/pink_booster_store.visible=false
		await get_tree().create_timer(.2).timeout
		update_booster_screen_labels()
		$booster_screens/pink_booster_screen.visible=true
		$booster_screens/pink_booster_screen/pink_booster_use_button.disabled=false
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		_on_booster_store_exit_button_pressed()
		$map_store.visible=true
		map_store_wiggle()
	
func bought_booster_fx():
	$confetti_sprites.visible=true
	$confetti_sprites.play("confetti")
	SoundManager.play_fixed_sound("points_tally")
	await get_tree().create_timer(.5).timeout
	
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
	
var life_value
var new_life_value
func _on_lives_store_1_life_buy_button_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($lives_store/lives_store_6h_buy_button/infinite_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($lives_store/lives_store_6h_buy_button/infinite_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		life_value=GameDataManager.level_info[0]["lives"]
		new_life_value=life_value+1
		GameDataManager.modify_dict(0,"lives",new_life_value)
		bought_booster_fx()
		$lives_store.visible=false
		update_lives()
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		$lives_store.visible=false
		await get_tree().create_timer(.2).timeout
		$map_store.visible=true
		map_store_wiggle()
	
func _on_lives_store_5_life_buy_button_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($lives_store/lives_store_5life_buy_button/fivelife_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($lives_store/lives_store_5life_buy_button/fivelife_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		life_value=GameDataManager.level_info[0]["lives"]
		new_life_value=life_value+5
		GameDataManager.modify_dict(0,"lives",new_life_value)
		bought_booster_fx()
		$lives_store.visible=false
		update_lives()
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		$lives_store.visible=false
		await get_tree().create_timer(.2).timeout
		$map_store.visible=true
		map_store_wiggle()
		
func _on_exit_map_store_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$map_store.visible=false
	
func _on_lives_store_6h_buy_button_pressed():
	if GameDataManager.level_info[0]["shards"]>=int($lives_store/lives_store_6h_buy_button/infinite_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($lives_store/lives_store_6h_buy_button/infinite_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		GameDataManager.modify_dict(0,"lives","∞")
		bought_booster_fx()
		$lives_store.visible=false
		update_lives()
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		$lives_store.visible=false
		await get_tree().create_timer(.2).timeout
		$map_store.visible=true
		map_store_wiggle()
		
signal confetti_finished
func _on_confetti_sprites_animation_finished():
	emit_signal("confetti_finished")
	$confetti_sprites.visible=false
	
	
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


func _on_top_ui_lives_button_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	$lives_store.visible=true

var current_moves
var new_moves
signal booster_bought
func _on_buy_moves_button_pressed():
	print("buy_moves_pressed")
	if GameDataManager.level_info[0]["shards"]>=int($moves_store/buy_moves_button/moves_price.text):
		SoundManager.play_fixed_sound("obtain")
		new_shard_value=GameDataManager.level_info[0]["shards"]-int($moves_store/buy_moves_button/moves_price.text)
		GameDataManager.modify_dict(0,"shards",new_shard_value)
		current_moves=get_parent().get_node("grid").current_counter_value
		new_moves=current_moves+5
		get_parent().get_node("grid").current_counter_value=new_moves
		_on_grid_update_counter(+5)
		bought_booster_fx()
		$moves_store.visible=false
		emit_signal("booster_bought",true)
	else:
		SoundManager.play_fixed_sound("obtain_negative")
		await get_tree().create_timer(.2).timeout
		$map_store.visible=true
		map_store_wiggle()
		
func _on_moves_store_exit_button_pressed():
	var current = game_lose.instantiate()
	get_tree().get_root().add_child(current)
	current.z_index=10
	emit_signal("booster_bought",false)


func _on_grid_bounce():
	get_node("top_ui/AnimationPlayer").play("ui_bounce")

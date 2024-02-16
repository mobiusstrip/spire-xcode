extends TextureRect


func _ready():
	#booster unlocked stuff
	if GameDataManager.level_info[0]["free_switch_booster_unlocked"]==false:
		$red_booster.modulate=Color(.8,.8,.8,1)
	else:
		$red_booster.modulate=Color(1,1,1,1)
	if GameDataManager.level_info[0]["hammer_booster_unlocked"]==false:
		$yellow_booster.modulate=Color(.8,.8,.8,1)
	else:
		$yellow_booster.modulate=Color(1,1,1,1)
	if GameDataManager.level_info[0]["colrow_bomb_booster_unlocked"]==false:
		$pink_booster.modulate=Color(.8,.8,.8,1)
	else:
		$pink_booster.modulate=Color(1,1,1,1)
	if GameDataManager.level_info[0]["adj_bomb_booster_unlocked"]==false:
		$green_booster.modulate=Color(.8,.8,.8,1)
	else:
		$green_booster.modulate=Color(1,1,1,1)
	if GameDataManager.level_info[0]["color_bomb_booster_unlocked"]==false:
		$blue_booster.modulate=Color(.8,.8,.8,1)
	else:
		$blue_booster.modulate=Color(1,1,1,1)
	#booster count stuff
	$blue_booster/blue_booster_label.text=str(GameDataManager.level_info[0]["blue_booster_stock"])
	$green_booster/green_booster_label.text=str(GameDataManager.level_info[0]["green_booster_stock"])
	$yellow_booster/yellow_booster_label.text=str(GameDataManager.level_info[0]["yellow_booster_stock"])
	$red_booster/red_booster_label.text=str(GameDataManager.level_info[0]["red_booster_stock"])
	$pink_booster/pink_booster_label.text=str(GameDataManager.level_info[0]["pink_booster_stock"])

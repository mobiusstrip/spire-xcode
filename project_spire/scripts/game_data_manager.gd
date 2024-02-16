extends Node

@onready var path = "user://savegame.dat"

var current_level

func _ready():
	if FileAccess.file_exists(path):
		level_info = load_data()
	else:
		return
	which_world()
	which_level()
#	shows level_info
#	print(load_data())

var current_world=1
var j=1
func which_world():
	for i in range(8,70,9):
		j+=1
		if GameDataManager.level_info[i]["unlocked"] == true:
			current_world=j
			

var reached_level
func which_level():
	for i in range(1,55):
		if GameDataManager.level_info[i]["unlocked"] == true and GameDataManager.level_info[i]["unlocked"] == false:
			reached_level=i
		
func modify_dict(key,subkey,value):
	level_info[key][str(subkey)] = value
	save_data()
	
func save_data():
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_var(level_info)
	if not FileAccess.file_exists(path):
		print("something_went_wrong_saving")
		return
	file.close()
	
func load_data():
	var file = FileAccess.open(path,FileAccess.READ)
	if not FileAccess.file_exists(path):
		print("something_went_wrong_loading")
		return
	var content=file.get_var()
	return content
	
var level_info = {
	0:{
		"currency":"USD",
		"reached_level":1,
		"lives":5,
		"shards":500,
		"music_enabled":true,
		"sound_enabled":true,
		"vibration_enabled":true,
		"blue_booster_stock":3,
		"green_booster_stock":3,
		"yellow_booster_stock":3,
		"red_booster_stock":3,
		"pink_booster_stock":3,
		"free_switch_booster_unlocked":true, #7
		"hammer_booster_unlocked":false, #12
		"colrow_bomb_booster_unlocked":false, #34
		"adj_bomb_booster_unlocked":false, #44
		"color_bomb_booster_unlocked":false, #50
	},
	1:{
		"unlocked":true,
		"star":"green",
		},
	2:{
		"unlocked":false,
		"star":"null",
		},
	3:{
		"unlocked":false,
		"star":"null",
		},
	4:{
		"unlocked":false,
		"star":"null",
		},
	5:{
		"unlocked":false,
		"star":"null",
		},
	6:{
		"unlocked":false,
		"star":"null",
		},
	7:{
		"unlocked":false,
		"star":"null",
		},
	8:{
		"unlocked":false,
		"star":"null",
		},
	9:{
		"unlocked":false,
		"star":"null",
		},
	10:{
		"unlocked":false,
		"star":"null",
		},
	11:{
		"unlocked":false,
		"star":"null",
		},
	12:{
		"unlocked":false,
		"star":"null",
		},
	13:{
		"unlocked":false,
		"star":"null",
		},
	14:{
		"unlocked":false,
		"star":"null",
		},
	15:{
		"unlocked":false,
		"star":"null",
		},
	16:{
		"unlocked":false,
		"star":"null",
		},
	17:{
		"unlocked":false,
		"star":"null",
		},
	18:{
		"unlocked":false,
		"star":"null",
		},
	19:{
		"unlocked":false,
		"star":"null",
		},
	20:{
		"unlocked":false,
		"star":"null",
		},
	21:{
		"unlocked":false,
		"star":"null",
		},
	22:{
		"unlocked":false,
		"star":"null",
		},
	23:{
		"unlocked":false,
		"star":"null",
		},
	24:{
		"unlocked":false,
		"star":"null",
		},
	25:{
		"unlocked":false,
		"star":"null",
		},
	26:{
		"unlocked":false,
		"star":"null",
		},
	27:{
		"unlocked":false,
		"star":"null",
		},
	28:{
		"unlocked":false,
		"star":"null",
		},
	29:{
		"unlocked":false,
		"star":"null",
		},
	30:{
		"unlocked":false,
		"star":"null",
		},
	31:{
		"unlocked":false,
		"star":"null",
		},
	32:{
		"unlocked":false,
		"star":"null",
		},
	33:{
		"unlocked":false,
		"star":"null",
		},
	34:{
		"unlocked":false,
		"star":"null",
		},
	35:{
		"unlocked":false,
		"star":"null",
		},
	36:{
		"unlocked":false,
		"star":"null",
		},
	37:{
		"unlocked":false,
		"star":"null",
		},
	38:{
		"unlocked":false,
		"star":"null",
		},
	39:{
		"unlocked":false,
		"star":"null",
		},
	40:{
		"unlocked":false,
		"star":"null",
		},
	41:{
		"unlocked":false,
		"star":"null",
		},
	42:{
		"unlocked":false,
		"star":"null",
		},
	43:{
		"unlocked":false,
		"star":"null",
		},
	44:{
		"unlocked":false,
		"star":"null",
		},
	45:{
		"unlocked":false,
		"star":"null",
		},
	46:{
		"unlocked":false,
		"star":"null",
		},
	47:{
		"unlocked":false,
		"star":"null",
		},
	48:{
		"unlocked":false,
		"star":"null",
		},
	49:{
		"unlocked":false,
		"star":"null",
		},
	50:{
		"unlocked":false,
		"star":"null",
		},
	51:{
		"unlocked":false,
		"star":"null",
		},
	52:{
		"unlocked":false,
		"star":"null",
		},
	53:{
		"unlocked":false,
		"star":"null",
		},
	54:{
		"unlocked":false,
		"star":"null",
		},
	55:{
		"unlocked":false,
		"star":"null",
		},
	56:{
		"unlocked":false,
		"star":"null",
		},
	57:{
		"unlocked":false,
		"star":"null",
		},
	58:{
		"unlocked":false,
		"star":"null",
		},
	59:{
		"unlocked":false,
		"star":"null",
		},
	60:{
		"unlocked":false,
		"star":"null",
		},
	61:{
		"unlocked":false,
		"star":"null",
		},
	62:{
		"unlocked":false,
		"star":"null",
		},
	63:{
		"unlocked":false,
		"star":"null",
		},
	64:{
		"unlocked":false,
		"star":"null",
		},
}

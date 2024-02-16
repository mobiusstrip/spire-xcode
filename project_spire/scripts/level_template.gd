extends Node2D

func _ready():
	SoundManager.play_tracked_music("loop_1")
	currency_editor()

var currency_labels=["UI/map_store/buy_button_10_shards/currency","UI/map_store/buy_button_50_shards/currency","UI/map_store/buy_button_100_shards/currency","UI/map_store/buy_button_250_shards/currency","UI/map_store/buy_button_500_shards/currency","UI/map_store/buy_button_1000_shards/currency"]

func currency_editor():
	match GameDataManager.level_info[0]["currency"]:
		"USD":
			for i in currency_labels:
				get_node(i).text="$"
			

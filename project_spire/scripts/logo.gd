extends Node2D

func _ready():
	$Timer.start()
	progress()
	
func _on_Timer_timeout():
	Transition.change_scene_to_file("res://scenes/main_menu.tscn","fade_yellow")
	
func progress():
	$progress_bar.max_value=100
	for _i in range(0,101):
		await get_tree().create_timer(.03).timeout
		$progress_bar.value+=1

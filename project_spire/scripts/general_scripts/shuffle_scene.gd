extends Node2D

func _on_grid_deadlocked():
	SoundManager.play_fixed_sound("shuffle")
	$AnimationPlayer.play("shuffle_board_2")

extends CanvasLayer


func change_scene_to_file(target,animation):
	if animation=="fade_red":
		$AnimationPlayer.play("fade_red")
		await finished

		get_tree().change_scene_to_file(target)
		$AnimationPlayer.play_backwards("fade_red")
		await finished
		
	if animation=="fade_purple":
		$AnimationPlayer.play("fade_purple")
		await finished

		get_tree().change_scene_to_file(target)
		$AnimationPlayer.play_backwards("fade_purple")
		await finished
		
	if animation=="fade_blue":
		$AnimationPlayer.play("fade_blue")
		await finished

		get_tree().change_scene_to_file(target)
		$AnimationPlayer.play_backwards("fade_blue")
		await finished
		
	if animation=="fade_yellow":
		$AnimationPlayer.play("fade_yellow")
		await finished

		get_tree().change_scene_to_file(target)
		$AnimationPlayer.play_backwards("fade_yellow")
		await finished
		
	if animation=="fade_beige":
		$AnimationPlayer.play("fade_beige")
		await finished

		get_tree().change_scene_to_file(target)
		$AnimationPlayer.play_backwards("fade_beige")
		await finished

signal finished
func _on_animation_player_animation_finished(_anim_name):
	emit_signal("finished")

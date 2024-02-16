extends AudioStreamPlayer

func remove_self():
	queue_free()
	
func play_music(music):
	set_stream(music)
	play()
	
func _on_finished():
	remove_self()

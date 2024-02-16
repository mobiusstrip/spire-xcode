extends AudioStreamPlayer

func remove_self():
	queue_free()
	
func play_sound(sound):
	set_stream(sound)
	play()
	
func _on_finished():
	remove_self()
